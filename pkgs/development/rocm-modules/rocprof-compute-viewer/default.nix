{
  lib,
  stdenv,
  fetchRocmSrc,
  sources,
  cmake,
  ninja,
  nix-update-script,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocprof-compute-viewer";
  version = sources.rocprof-compute-viewer.version;

  src = fetchRocmSrc "rocprof-compute-viewer";

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  # tries to use qt_deploy_runtime_dependencies, but wrapQtAppsHook
  # handles that instead
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'install(SCRIPT ''${deploy_script})' ""
  '';

  cmakeFlags = [
    (lib.cmakeFeature "QT_VERSION_MAJOR" "6")
    (lib.cmakeBool "RCV_DISABLE_OPENGL" true)
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Visualization tool for AMD GPU thread traces from rocprofv3 --att";
    homepage = "https://github.com/ROCm/rocprof-compute-viewer";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "rocprof-compute-viewer";
  };
})
