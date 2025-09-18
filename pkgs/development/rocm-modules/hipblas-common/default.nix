{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  rocm-cmake,
  rocmUpdateScript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hipblas-common";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "hipBLAS-common";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-NXSMVtfjei4vIjU9y4o3Px/fplq7C7ziY1R8YqnY2LQ=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    rocm-cmake
  ];

  strictDeps = true;

  passthru.updateScript = rocmUpdateScript {
    name = finalAttrs.pname;
    inherit (finalAttrs.src) owner;
    inherit (finalAttrs.src) repo;
  };
  meta = with lib; {
    description = "Common files shared by hipBLAS and hipBLASLt";
    homepage = "https://github.com/ROCm/hipBLASlt";
    license = with licenses; [ mit ];
    teams = [ teams.rocm ];
    platforms = platforms.linux;
  };
})
