{
  lib,
  stdenv,
  fetchFromGitHub,
  rocmUpdateScript,
  cmake,
  rocm-cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "half";
  version = "7.0.1";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "half";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-If9O5BEeymsLN+C0drZsPSxEWXpJTxeDBGNHNXSumm4=";
  };

  nativeBuildInputs = [
    cmake
    rocm-cmake
  ];

  passthru.updateScript = rocmUpdateScript {
    name = finalAttrs.pname;
    inherit (finalAttrs.src) owner;
    inherit (finalAttrs.src) repo;
  };

  meta = with lib; {
    description = "C++ library for half precision floating point arithmetics";
    homepage = "https://github.com/ROCm/half";
    license = with licenses; [ mit ];
    teams = [ teams.rocm ];
    platforms = platforms.unix;
  };
})
