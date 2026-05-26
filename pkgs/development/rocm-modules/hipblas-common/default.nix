{
  lib,
  stdenv,
  cmake,
  fetchRocmSrc,
  sources,
  rocm-cmake,
  rocmUpdateScript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hipblas-common";
  version = sources.hipblas-common.version;

  src = fetchRocmSrc "hipblas-common";
  sourceRoot = "${finalAttrs.src.name}/projects/hipblas-common";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    rocm-cmake
  ];

  strictDeps = true;

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };
  meta = {
    description = "Common files shared by hipBLAS and hipBLASLt";
    homepage = "https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipblas-common";
    license = with lib.licenses; [ mit ];
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.linux;
  };
})
