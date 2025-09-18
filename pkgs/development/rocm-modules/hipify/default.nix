{
  lib,
  stdenv,
  fetchFromGitHub,
  rocmUpdateScript,
  cmake,
  clang,
  libxml2,
  rocm-merged-llvm,
  zlib,
  zstd,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hipify";
  version = "7.0.1";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "HIPIFY";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-xcWUYfZvbTHs4BvDiXAOLONfLiCq9uEGOHSK/hOWg7c=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libxml2
    rocm-merged-llvm
    zlib
    zstd
    perl
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "\''${LLVM_TOOLS_BINARY_DIR}/clang" "${clang}/bin/clang"
    chmod +x bin/*
  '';

  passthru.updateScript = rocmUpdateScript {
    name = finalAttrs.pname;
    inherit (finalAttrs.src) owner;
    inherit (finalAttrs.src) repo;
  };

  postInstall = ''
    rm $out/bin/hipify-perl
    chmod +x $out/bin/*
    chmod +x $out/libexec/*
    patchShebangs $out/bin/
    patchShebangs $out/libexec/
    ln -s $out/{libexec/hipify,bin}/hipify-perl
  '';

  meta = with lib; {
    description = "Convert CUDA to Portable C++ Code";
    homepage = "https://github.com/ROCm/HIPIFY";
    license = with licenses; [ mit ];
    teams = [ teams.rocm ];
    platforms = platforms.linux;
  };
})
