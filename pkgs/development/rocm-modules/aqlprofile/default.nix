{
  lib,
  stdenv,
  clr,
  cmake,
  fetchRocmSrc,
  sources,
  rocmUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aqlprofile";
  version = sources.aqlprofile.version;

  src = fetchRocmSrc "aqlprofile";
  sourceRoot = "${finalAttrs.src.name}/projects/aqlprofile";

  env.CXXFLAGS = "-DROCP_LD_AQLPROFILE=1";

  nativeBuildInputs = [
    cmake
    clr
  ];

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "AQLPROFILE library for AMD HSA runtime API extension support";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/aqlprofile";
    license = with lib.licenses; [ mit ];
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.linux;
  };
})
