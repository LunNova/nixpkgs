#!/usr/bin/env python3
"""Generate/regenerate a per-stream ROCm source-pin file under ./srcs.

Each ROCm package set version pins its sources in one data file
(srcs/<version>.nix). This tool produces such a file for a stream by taking an
existing srcs file as the package *inventory* (owner/repo/sparseCheckout/etc.,
which are stream-invariant), re-pointing each stream-tracking package at the new
tag, and re-deriving its hash via the actual fetchFromGitHub fetcher.

Usage:
  srcs-gen.py --from srcs/7.2.3.nix --tag-prefix rocm-    --version 7.2.4 --out srcs/7.2.4.nix
  srcs-gen.py --from srcs/7.2.3.nix --tag-prefix therock- --version 7.10  --out srcs/7.10.nix --minimal

A package "tracks the stream" iff its rev is exactly `<from-prefix><from rocmVersion>`
(default from-prefix "rocm-"). Those get rev=`<tag-prefix><version>` and a freshly
prefetched hash. Pinned outliers (fixed tags, raw commits, other repos) are kept
verbatim in a full file, or omitted with --minimal (a dev stream then inherits
them from its baseSrcs fallback). Packages whose tag does not exist on the target
stream (fetch 404) are omitted with a warning.
"""
import argparse
import json
import os
import re
import subprocess
import sys

# Packages whose final src hash depends on a recipe-local `postFetch` (which is
# build-input-dependent and lives in the recipe, not in srcs). The generator
# cannot reproduce their hash from fetch coordinates alone, so it omits them:
# with --minimal they fall back to baseSrcs; otherwise fill the hash manually
# (e.g. `nix build .#rocmPackages_<stream>.<pkg>.src`).
POSTFETCH_OMIT = {"hipblaslt"}

HERE = os.path.dirname(os.path.abspath(__file__))
# repo root: pkgs/development/rocm-modules -> ../../..
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))


def nix_eval_json(path):
    out = subprocess.run(
        ["nix", "eval", "--json", "--file", path],
        capture_output=True, text=True, check=True,
    )
    return json.loads(out.stdout)


def fetch_expr(spec, rev=None, tag=None, hashval="lib.fakeHash"):
    attrs = [
        f'owner = "{spec["owner"]}";',
        f'repo = "{spec["repo"]}";',
        f"hash = {hashval};",
    ]
    if tag is not None:
        attrs.append(f'tag = "{tag}";')
    else:
        attrs.append(f'rev = "{rev}";')
    if spec.get("sparseCheckout"):
        items = " ".join(f'"{x}"' for x in spec["sparseCheckout"])
        attrs.append(f"sparseCheckout = [ {items} ];")
    if spec.get("fetchSubmodules"):
        attrs.append("fetchSubmodules = true;")
    if spec.get("leaveDotGit"):
        attrs.append("leaveDotGit = true;")
    return (
        f"let pkgs = import {REPO_ROOT} {{ }}; lib = pkgs.lib; "
        f"in pkgs.fetchFromGitHub {{ {' '.join(attrs)} }}"
    )


def discover_hash(spec, rev=None, tag=None):
    """Compute the fetchFromGitHub hash with nurl (robust; handles submodules
    and sparseCheckout properly). Returns the sha256-... string, or None if the
    ref is absent on the stream. nurl pins via `tag=`, which is hash-equivalent
    to the recipes' `rev=` for fetchFromGitHub (verified against known pins)."""
    ref = rev if rev is not None else tag
    url = f"https://github.com/{spec['owner']}/{spec['repo']}"
    cmd = ["nurl", url, ref, "-H"]
    if spec.get("fetchSubmodules"):
        cmd.append("-S")
    if spec.get("leaveDotGit"):
        cmd += ["-a", "leaveDotGit", "true"]
    if spec.get("sparseCheckout"):
        items = " ".join(f'"{x}"' for x in spec["sparseCheckout"])
        cmd += ["-a", "sparseCheckout", f"[ {items} ]"]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode == 0:
        lines = proc.stdout.strip().splitlines()
        return lines[-1] if lines else None
    combined = proc.stdout + proc.stderr
    # Ref absent on this stream -> caller marks broken / falls back. nurl resolves
    # via the GitHub API, which returns 422 "No commit found" for a missing ref.
    if re.search(
        r"(No commit found|HTTP error 404|HTTP error 422|not found"
        r"|couldn't find remote ref|did not match|cannot download|no such)",
        combined,
        re.I,
    ):
        return None
    sys.stderr.write(combined[-2000:] + "\n")
    raise RuntimeError(f"nurl failed for {spec['owner']}/{spec['repo']} @ {ref}")


def realize_src(spec, rev=None, tag=None, hashval=None):
    """Build the fetch with its real hash and return the store path (so we can
    inspect whether a sparseCheckout actually produced any content)."""
    expr = fetch_expr(spec, rev=rev, tag=tag, hashval=f'"{hashval}"')
    proc = subprocess.run(
        ["nix", "build", "--impure", "--no-link", "--print-out-paths", "--expr", expr],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr[-1500:] + "\n")
        raise RuntimeError(f"realize failed for {spec['owner']}/{spec['repo']} @ {tag or rev}")
    return proc.stdout.strip().splitlines()[-1]


def sparse_path_empty(out_path, spec):
    """True if the package's (non-'shared') sparseCheckout path is absent/empty
    in the realized source — i.e. the project moved/was removed on this stream."""
    rel = next((p for p in spec.get("sparseCheckout", []) if p != "shared"), None)
    if rel is None:
        return False
    full = os.path.join(out_path, rel)
    return not (os.path.isdir(full) and os.listdir(full))


def try_relocate(key, rev):
    """A component may have migrated from its own repo into a monorepo
    (rocm-systems/rocm-libraries) on a newer stream. When the recorded repo has
    no source at `rev`, look for `projects/<key>` in the monorepos and, if found
    with content, return monorepo fetch coordinates (incl. sourceRoot)."""
    for repo in ("rocm-systems", "rocm-libraries"):
        spec = {
            "owner": "ROCm",
            "repo": repo,
            "sparseCheckout": [f"projects/{key}", "shared"],
        }
        h = discover_hash(spec, rev=rev)
        if h is None:
            continue
        out = realize_src(spec, rev=rev, hashval=h)
        if sparse_path_empty(out, spec):
            continue
        return {
            "owner": "ROCm",
            "repo": repo,
            "rev": rev,
            "hash": h,
            "sparseCheckout": [f"projects/{key}", "shared"],
            "sourceRoot": f"projects/{key}",
        }
    return None


def emit_entry(out, key, e, indent=4):
    sp = " " * indent
    isp = " " * (indent + 2)
    out.append(f"{sp}{key} = {{")
    out.append(f'{isp}version = "{e["version"]}";')
    out.append(f'{isp}owner = "{e["owner"]}";')
    out.append(f'{isp}repo = "{e["repo"]}";')
    if "tag" in e and e["tag"] is not None:
        out.append(f'{isp}tag = "{e["tag"]}";')
    else:
        out.append(f'{isp}rev = "{e["rev"]}";')
    if e.get("sparseCheckout"):
        out.append(f"{isp}sparseCheckout = [")
        for x in e["sparseCheckout"]:
            out.append(f'{isp}  "{x}"')
        out.append(f"{isp}];")
    if e.get("sourceRoot"):
        out.append(f'{isp}sourceRoot = "{e["sourceRoot"]}";')
    if e.get("fetchSubmodules"):
        out.append(f"{isp}fetchSubmodules = true;")
    if e.get("leaveDotGit"):
        out.append(f"{isp}leaveDotGit = true;")
    out.append(f'{isp}hash = "{e["hash"]}";')
    if e.get("rocmLlvmVersion"):
        out.append(f'{isp}rocmLlvmVersion = "{e["rocmLlvmVersion"]}";')
    if e.get("extraSrcs"):
        for ek, ev in e["extraSrcs"].items():
            out.append(f"{isp}extraSrcs.{ek} = {{")
            out.append(f'{isp}  owner = "{ev["owner"]}";')
            out.append(f'{isp}  repo = "{ev["repo"]}";')
            out.append(f'{isp}  rev = "{ev["rev"]}";')
            out.append(f'{isp}  hash = "{ev["hash"]}";')
            out.append(f"{isp}}};")
    out.append(f"{sp}}};")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--from", dest="src", required=True, help="inventory srcs file")
    ap.add_argument("--from-prefix", default="rocm-", help="tag prefix tracking packages use in --from (default rocm-)")
    ap.add_argument("--tag-prefix", required=True, help="tag prefix for the target stream, e.g. rocm- or therock-")
    ap.add_argument("--version", required=True, help="target ROCm version, e.g. 7.2.4 or 7.10")
    ap.add_argument("--out", required=True, help="output srcs file")
    ap.add_argument("--minimal", action="store_true", help="omit pinned/untracked packages (dev streams inherit them via baseSrcs)")
    ap.add_argument("--only", help="comma-separated package keys to process (debug)")
    args = ap.parse_args()

    data = nix_eval_json(args.src)
    from_version = data["rocmVersion"]
    tracking_rev = f"{args.from_prefix}{from_version}"
    only = set(args.only.split(",")) if args.only else None

    new_rev = f"{args.tag_prefix}{args.version}"
    packages = data["packages"]
    result = {}
    omitted = []  # fall back to baseSrcs (pinned outliers / postFetch)
    broken = []  # track the stream but have NO source on it -> mark broken in scope
    for key in sorted(packages):
        if only and key not in only:
            continue
        e = dict(packages[key])
        tracks = e.get("rev") == tracking_rev
        if not tracks:
            # pinned outlier (fixed tag / raw commit / other repo): version is
            # independent of the stream, so carry it (full file) or fall back (minimal).
            if args.minimal:
                omitted.append((key, "pinned/untracked"))
                continue
            result[key] = e
            continue
        if key in POSTFETCH_OMIT:
            # available on the stream, but its hash needs the recipe postFetch;
            # fall back rather than pin a wrong (pre-postFetch) hash.
            omitted.append((key, "postFetch hash; fill manually"))
            sys.stderr.write(f"  omit {key}: hash needs recipe postFetch; falling back\n")
            continue
        pin = None
        h = discover_hash(e, rev=new_rev)
        if h is not None:
            # A sparseCheckout of a missing project path doesn't 404 — it just
            # yields an empty tree. Realize and confirm the project path has
            # content before trusting the fetch.
            if e.get("sparseCheckout"):
                out_path = realize_src(e, rev=new_rev, hashval=h)
                if not sparse_path_empty(out_path, e):
                    pin = {**e, "rev": new_rev, "hash": h}
            else:
                pin = {**e, "rev": new_rev, "hash": h}
        if pin is None:
            # Maybe the component migrated into a monorepo on this stream.
            reloc = try_relocate(key, new_rev)
            if reloc is not None:
                pin = {**e, **reloc}
                sys.stderr.write(f"  relocate {key}: -> {reloc['repo']}/{reloc['sourceRoot']} @ {new_rev}\n")
        if pin is None:
            broken.append(key)
            sys.stderr.write(f"  broken {key}: no source at {new_rev} (no tag / project absent / not migrated)\n")
            continue
        pin["version"] = args.version
        if pin.get("rocmLlvmVersion"):
            sys.stderr.write(f"  NOTE {key}: rocmLlvmVersion carried over ({pin['rocmLlvmVersion']}); verify against the stream's llvm-project fork\n")
        result[key] = pin

    out = []
    out.append(f"# Source pins for the ROCm stream at version {args.version} ({args.tag_prefix}{args.version} tags).")
    out.append("# Generated by ./srcs-gen.py — do not edit by hand; re-run the generator.")
    if args.minimal:
        out.append("# Minimal dev file: packages not listed here inherit their pin from baseSrcs.")
    out.append("{")
    out.append(f'  rocmVersion = "{args.version}";')
    out.append(f'  tagPrefix = "{args.tag_prefix}";')
    if broken:
        items = " ".join(f'"{b}"' for b in sorted(broken))
        out.append("  # Components that track the ROCm version but have no source on this")
        out.append("  # stream (no tag / project removed). default.nix marks these broken in")
        out.append("  # the scope rather than silently serving the stable version.")
        out.append(f"  brokenPackages = [ {items} ];")
    out.append("  packages = {")
    for key in sorted(result):
        emit_entry(out, key, result[key], indent=4)
    out.append("  };")
    out.append("}")

    with open(args.out, "w") as f:
        f.write("\n".join(out) + "\n")

    # format
    subprocess.run(["nix", "fmt", "--", args.out], cwd=REPO_ROOT, capture_output=True)
    print(f"wrote {args.out}: {len(result)} pinned, {len(broken)} broken, {len(omitted)} fall-back")
    if broken:
        print("  broken (no source on stream):", " ".join(sorted(broken)))
    if omitted:
        print("  fall-back:", ", ".join(f"{k}({why})" for k, why in omitted))


if __name__ == "__main__":
    main()
