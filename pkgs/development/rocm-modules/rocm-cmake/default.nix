{
  lib,
  stdenv,
  fetchRocmSrc,
  sources,
  rocmUpdateScript,
  rocm-core,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocm-cmake";
  version = sources.rocm-cmake.version;

  src = fetchRocmSrc "rocm-cmake";

  nativeBuildInputs = [ cmake ];

  buildInputs = [ rocm-core ];

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "CMake modules for common build tasks for the ROCm stack";
    homepage = "https://github.com/ROCm/rocm-cmake";
    license = lib.licenses.mit;
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.unix;
  };
})
