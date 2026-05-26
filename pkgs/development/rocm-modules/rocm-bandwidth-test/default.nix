{
  lib,
  stdenv,
  fetchRocmSrc,
  sources,
  rocmPackages,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocm-bandwidth-test";
  version = sources.rocm-bandwidth-test.version;

  src = fetchRocmSrc "rocm-bandwidth-test";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [ rocmPackages.rocm-runtime ];

  cmakeFlags = [
    "-DROCT_INC_DIR=${rocmPackages.rocm-runtime}/include/libhsakmt"
  ];

  meta = {
    description = "Bandwidth test for AMD GPUs supported by ROCm";
    homepage = "https://github.com/ROCm/rocm_bandwidth_test";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fangpen ];
    teams = [ lib.teams.rocm ];
    platforms = [ "x86_64-linux" ];
  };
})
