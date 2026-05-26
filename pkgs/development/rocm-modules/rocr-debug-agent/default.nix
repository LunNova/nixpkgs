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

stdenv.mkDerivation (finalAttrs: {
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
})
