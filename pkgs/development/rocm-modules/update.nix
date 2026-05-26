{
  lib,
  writeScript,
  # Stream metadata, baked per-scope from default.nix. A "stream" is one
  # srcs/<version>.nix file; updating means re-pointing it at that stream's
  # latest tag and regenerating it with ./srcs-gen.py.
  tagPrefix ? "rocm-",
  srcsFileName ? "7.2.3.nix",
  # Dev/preview streams omit pinned outliers (they fall back via baseSrcs).
  minimal ? false,
}:

{
  finalAttrs ? { },
  name ? finalAttrs.pname or "rocm",
  # The umbrella monorepo carries the coordinated stream tags
  # (rocm-X.Y.Z for stable, therock-7.1x for the preview stream); discover the
  # stream's latest version from it regardless of which package triggered us.
  owner ? "ROCm",
  repo ? "rocm-systems",
  page ? "releases?per_page=20",
  # Select the newest tag for THIS stream by its prefix. The prefix is what
  # keeps streams from bleeding into each other (no more hardcoded version
  # ceiling): the stable stream only ever sees `rocm-` tags, the preview stream
  # only `therock-` tags.
  filter ? "map(.tag_name // .name) | map(select(test(\"^${tagPrefix}[0-9]+\\\\.[0-9]+(\\\\.[0-9]+)?$\"))) | first | ltrimstr(\"${tagPrefix}\")",
}:

let
  updateScript = writeScript "update-rocm-${srcsFileName}" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq nix python3
    set -euo pipefail

    # Triggered by rocmPackages.${name}.updateScript; regenerates the whole
    # stream (all components share one ROCm version). NOTE: pinned outliers
    # (fixed tags / raw commits, e.g. aotriton, hiprt, rocm-bandwidth-test) are
    # not version-coupled to the stream and must be bumped manually.

    fetch_releases() {
      local api_url="https://api.github.com/repos/${owner}/${repo}/${page}"
      >&2 echo "$api_url"
      curl ''${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -sL "$api_url"
    }

    releases="$(fetch_releases)"
    version="$(echo "$releases" | jq -r 'if type == "array" then . else [.] end | ${filter}')"

    if [ -z "$version" ] || [ "$version" = "null" ]; then
      echo "No '${tagPrefix}' version found for stream 'srcs/${srcsFileName}'." >&2
      exit 1
    fi

    >&2 echo "Regenerating srcs/${srcsFileName} -> ${tagPrefix}$version"

    exec python3 pkgs/development/rocm-modules/srcs-gen.py \
      --from "pkgs/development/rocm-modules/srcs/${srcsFileName}" \
      --tag-prefix "${tagPrefix}" \
      --version "$version" \
      --out "pkgs/development/rocm-modules/srcs/${srcsFileName}"${lib.optionalString minimal " \\\n      --minimal"}
  '';
in
[ updateScript ]
