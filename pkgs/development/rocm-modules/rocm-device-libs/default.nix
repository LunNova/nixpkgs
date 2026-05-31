{
  lib,
  stdenv,
  cmake,
  ninja,
  zlib,
  zstd,
  llvm,
  python3,
}:

let
  llvmNativeTarget =
    if stdenv.hostPlatform.isx86_64 then
      "X86"
    else if stdenv.hostPlatform.isAarch64 then
      "AArch64"
    else
      throw "Unsupported ROCm LLVM platform";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rocm-device-libs";
  # In-tree with ROCm LLVM
  inherit (llvm.llvm) version;
  src = llvm.llvm.monorepoSrc;
  sourceRoot = "${finalAttrs.src.name}/amd/device-libs";
  strictDeps = true;
  __structuredAttrs = true;

  postPatch =
    # Use our sysrooted toolchain instead of direct clang target
    ''
      substituteInPlace cmake/OCL.cmake \
        --replace-fail '$<TARGET_FILE:clang>' "${llvm.rocm-toolchain}/bin/clang"
    '';

  patches = [
    # cmake/Packages.cmake context drifted between the LLVM 22 and LLVM 23
    # forks of ROCm/llvm-project; pick the patch matching the fork.
    (
      if lib.versionAtLeast finalAttrs.version "23" then
        ./cmake-llvm23.patch
      else
        ./cmake.patch
    )
  ];

  nativeBuildInputs = [
    cmake
    ninja
    python3
    llvm.rocm-toolchain
  ];

  buildInputs = [
    llvm.llvm
    llvm.clang-unwrapped
    zlib
    zstd
  ];

  cmakeFlags = [
    "-DLLVM_TARGETS_TO_BUILD=AMDGPU;${llvmNativeTarget}"
  ];

  meta = {
    description = "Set of AMD-specific device-side language runtime libraries";
    homepage = "https://github.com/ROCm/ROCm-Device-Libs";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ lovesegfault ];
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.linux;
  };
})
