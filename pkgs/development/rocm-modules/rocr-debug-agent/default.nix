{
  lib,
  stdenv,
  fetchRocmSrc,
  sources,
  rocmUpdateScript,
  cmake,
  python3,
  clr,
  rocdbgapi,
  elfutils,
}:

stdenv.mkDerivation (
  finalAttrs:
  {
    pname = "rocr-debug-agent";
    version = sources.rocr-debug-agent.version;

    src = fetchRocmSrc "rocr-debug-agent";

    nativeBuildInputs = [
      cmake
      clr
      python3 # TODO: check for scripts that need patchShebangs in output
    ];

    buildInputs = [
      rocdbgapi
      elfutils
    ];

    cmakeFlags = [
      "-DCMAKE_MODULE_PATH=${clr}/lib/cmake/hip"
      "-DHIP_ROOT_DIR=${clr}"
      "-DHIP_PATH=${clr}"
    ];

    # Weird install target
    postInstall = ''
      rm -rf $out/src
    '';

    passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

    meta = {
      description = "Library that provides some debugging functionality for ROCr";
      homepage = "https://github.com/ROCm/rocr_debug_agent";
      license = with lib.licenses; [ ncsa ];
      teams = [ lib.teams.rocm ];
      platforms = lib.platforms.linux;
    };
  }
  # On streams where this component lives inside a monorepo (the preview stream
  # moved it under rocm-systems/projects/), srcs records a sourceRoot. Absent on
  # the stable stream, so this is a no-op there.
  // lib.optionalAttrs (sources.rocr-debug-agent ? sourceRoot) {
    sourceRoot = "${finalAttrs.src.name}/${sources.rocr-debug-agent.sourceRoot}";
  }
)
