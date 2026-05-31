{
  lib,
  stdenv,
  numactl,
  libpciaccess,
  libxml2,
  elfutils,
  glog,
  fmt,
  fetchRocmSrc,
  sources,
  rocmUpdateScript,
  cmake,
  clang,
  python3Packages,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocprofiler-register";
  version = sources.rocprofiler-register.version;

  src = fetchRocmSrc "rocprofiler-register";
  sourceRoot = "${finalAttrs.src.name}/projects/rocprofiler-register";

  patches =
    # Both are cherry-picks from later rocm-systems commits, already included
    # in the therock-7.1x preview fork. The stable rocm-7.x stream still needs
    # them (preview's minor is +10, so "< 7.10" cleanly identifies stable).
    lib.optionals (lib.versionOlder finalAttrs.version "7.10") [
      (fetchpatch {
        # [rocprofiler-sdk][rocprofiler-register] add CPackComponent
        url = "https://github.com/ROCm/rocm-systems/commit/ef7253365c420ca486f074b9e9119a222e30fea0.patch";
        hash = "sha256-dwqvZ4AaTcOk2mSnxgHp/NbhjlD8W6KVz1H5ZF4i/Tw=";
        relative = "projects/rocprofiler-register";
      })
      (fetchpatch {
        # [rocprofiler-register] Fix compilation with system fmt/glog
        url = "https://github.com/ROCm/rocm-systems/commit/c8ad2522083c6e00539ce5c1c22df766c20084fb.patch";
        hash = "sha256-VloRKV6kUzIfIInltx/bV1EM0FUfeQZrVAx6qgdsLyg=";
        relative = "projects/rocprofiler-register";
      })
    ];

  nativeBuildInputs = [
    cmake
    clang
  ];

  buildInputs = [
    numactl
    libpciaccess
    libxml2
    elfutils
    glog
    fmt

    python3Packages.lxml
    python3Packages.cppheaderparser
    python3Packages.pyyaml
    python3Packages.barectf
    python3Packages.pandas
  ];
  cmakeFlags = [
    "-DROCPROFILER_REGISTER_BUILD_TESTS=0"
    "-DROCPROFILER_REGISTER_BUILD_SAMPLES=0"
    "-DROCPROFILER_REGISTER_BUILD_GLOG=OFF"
    "-DROCPROFILER_REGISTER_BUILD_FMT=OFF"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Profiling with perf-counters and derived metrics";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/rocprofiler-register";
    license = with lib.licenses; [ mit ]; # mitx11
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.linux;
  };
})
