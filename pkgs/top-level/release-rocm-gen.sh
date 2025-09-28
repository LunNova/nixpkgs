#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#file nixpkgs#bintools nixpkgs#coreutils --command bash
set -euo pipefail

# FIXME: uh where should this live
# FIXME: tidy me up

diffAttrs=$(nix eval --impure --json --expr '
let
pkgs = import ./. { config.allowAliases = false; };
lib = pkgs.lib;
findAll =
  path: obj:
  let
    tryObj = builtins.tryEval obj;
  in
  if tryObj.success then
    let
      obj = tryObj.value;
    in
    if obj ? outPath then
      let
        tryOutPath = builtins.tryEval obj.outPath or null;
      in
      # filter out unavailable, broken packages, and drvs with broken deps
      if (obj ? meta) && (!obj.meta.available or false || obj.meta.broken) then
        [ ]
      else if (!tryOutPath.success) then
        [ ]  # drv has broken dependencies
      else
        [ { p = path; o = tryOutPath.value; } ]
    else if (obj.recurseForDerivations or false) || (obj.recurseForRelease or false) then
      lib.concatLists (
        lib.mapAttrsToList (
          name: value: findAll (if path == null then name else path + "." + name) value
        ) obj
      )
    else
      [ ]
  else
    [ ];
  def = findAll null (pkgs // { recurseForDerivations = true; });
  rocm = findAll null (pkgs.pkgsRocm // { recurseForDerivations = true; });
in
{
inherit def;
inherit rocm;
}
' | jq -r '
  (.def | map({(.p): .o}) | add) as $def_map |
  .rocm[] |
  select(
    ($def_map[.p] == null) or
    ($def_map[.p] != .o)
  ) |
  .p
' \
 | grep -v python312Packages)

echo "$diffAttrs" | sed 's/$/ = rocmPlatforms;/'
