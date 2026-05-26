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

HERE = os.path.dirname(os.path.abspath(__file__))
# repo root: pkgs/development/rocm-modules -> ../../..
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))


def nix_eval_json(path):
    out = subprocess.run(
        ["nix", "eval", "--json", "--file", path],
        capture_output=True, text=True, check=True,
    )
    return json.loads(out.stdout)


def discover_hash(spec, rev=None, tag=None):
    """Build fetchFromGitHub with a fake hash and read the real one from the
    mismatch error. Returns the sha256-... string, or None if the ref is missing.
    """
    attrs = [
        f'owner = "{spec["owner"]}";',
        f'repo = "{spec["repo"]}";',
        "hash = lib.fakeHash;",
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
    expr = (
        f"let pkgs = import {REPO_ROOT} {{ }}; lib = pkgs.lib; "
        f"in pkgs.fetchFromGitHub {{ {' '.join(attrs)} }}"
    )
    proc = subprocess.run(
        ["nix", "build", "--impure", "--no-link", "--expr", expr],
        capture_output=True, text=True,
    )
    combined = proc.stdout + proc.stderr
    if proc.returncode == 0:
        # fakeHash happened to match (essentially impossible) — bail loudly
        raise RuntimeError("build unexpectedly succeeded with fakeHash")
    m = re.search(r"got:\s*(sha256-\S+)", combined)
    if m:
        return m.group(1)
    if re.search(r"(Couldn't find remote ref|not found|fatal: .*(reference|ref)|HTTP error 404|did not match any)", combined, re.I):
        return None
    sys.stderr.write(combined[-2000:] + "\n")
    raise RuntimeError(f"could not determine hash for {spec['owner']}/{spec['repo']} @ {tag or rev}")


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

    packages = data["packages"]
    result = {}
    omitted = []
    for key in sorted(packages):
        if only and key not in only:
            continue
        e = dict(packages[key])
        tracks = e.get("rev") == tracking_rev
        if tracks:
            new_rev = f"{args.tag_prefix}{args.version}"
            h = discover_hash(e, rev=new_rev)
            if h is None:
                omitted.append((key, f"no tag {new_rev}"))
                sys.stderr.write(f"  omit {key}: tag {new_rev} not found on stream\n")
                continue
            e["version"] = args.version
            e["rev"] = new_rev
            e["hash"] = h
            if e.get("extraSrcs"):
                # extraSrcs are pinned to their own tags; keep verbatim
                pass
            if e.get("rocmLlvmVersion"):
                sys.stderr.write(f"  NOTE {key}: rocmLlvmVersion carried over ({e['rocmLlvmVersion']}); verify against the stream's llvm-project fork\n")
            result[key] = e
        else:
            if args.minimal:
                omitted.append((key, "pinned/untracked"))
                continue
            result[key] = e  # carry pinned outlier verbatim

    out = []
    out.append(f"# Source pins for the ROCm stream at version {args.version} ({args.tag_prefix}{args.version} tags).")
    out.append("# Generated by ./srcs-gen.py — do not edit by hand; re-run the generator.")
    if args.minimal:
        out.append("# Minimal dev file: packages not listed here inherit their pin from baseSrcs.")
    out.append("{")
    out.append(f'  rocmVersion = "{args.version}";')
    out.append("  packages = {")
    for key in sorted(result):
        emit_entry(out, key, result[key], indent=4)
    out.append("  };")
    out.append("}")

    with open(args.out, "w") as f:
        f.write("\n".join(out) + "\n")

    # format
    subprocess.run(["nix", "fmt", "--", args.out], cwd=REPO_ROOT, capture_output=True)
    print(f"wrote {args.out}: {len(result)} packages, {len(omitted)} omitted")
    if omitted:
        print("  omitted:", ", ".join(f"{k}({why})" for k, why in omitted))


if __name__ == "__main__":
    main()
