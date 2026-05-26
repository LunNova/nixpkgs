{
  lib,
  stdenv,
  fetchRocmSrc,
  sources,
  rocmUpdateScript,
  cmake,
  rocm-cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "half";
  version = sources.half.version;

  src = fetchRocmSrc "half";

  nativeBuildInputs = [
    cmake
    rocm-cmake
  ];

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "C++ library for half precision floating point arithmetics";
    homepage = "https://github.com/ROCm/half";
    license = with lib.licenses; [ mit ];
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.unix;
  };
})
