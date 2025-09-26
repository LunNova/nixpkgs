{
  lib,
  stdenv,
  llvm_meta,
  src ? null,
  monorepoSrc ? null,
  runCommand,
  cmake,
  ninja,
  libxml2,
  libllvm,
  libclang,
  release_version,
  version,
  python3,
  buildLlvmTools,
  fixDarwinDylibNames,
  devExtraCmakeFlags ? [ ],
  getVersionFile,
}:
let
  # TODO: drop when libclang stops having clang-tools-extra
  libclang' = libclang.override {
    enableClangToolsExtra = false;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "clang-tools-extra";
  inherit version;

  src =
    if monorepoSrc != null then
      runCommand "clang-src-${version}" { inherit (monorepoSrc) passthru; } (''
        mkdir -p "$out"
        cp -r ${monorepoSrc}/cmake "$out"
        cp -r ${monorepoSrc}/clang "$out"
        cp -r ${monorepoSrc}/clang-tools-extra "$out"
      '')
    else
      src;

  sourceRoot = "${finalAttrs.src.name}/clang-tools-extra";

  nativeBuildInputs = [
    cmake
    python3
    ninja
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [
    libxml2
    libllvm
    libclang'
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CLANG_INSTALL_PACKAGE_DIR" "${placeholder "dev"}/lib/cmake/clang")
    (lib.cmakeBool "CLANGD_BUILD_XPC" false)
    (lib.cmakeBool "LLVM_ENABLE_RTTI" true)
    (lib.cmakeFeature "LLVM_TABLEGEN_EXE" "${buildLlvmTools.tblgen}/bin/llvm-tblgen")
    (lib.cmakeFeature "CLANG_TABLEGEN_EXE" "${buildLlvmTools.tblgen}/bin/clang-tblgen")
    (lib.cmakeBool "LLVM_INCLUDE_TESTS" false)
    # Added in LLVM15:
    # `clang-tidy-confusable-chars-gen`: https://github.com/llvm/llvm-project/commit/c3574ef739fbfcc59d405985a3a4fa6f4619ecdb
    # `clang-pseudo-gen`: https://github.com/llvm/llvm-project/commit/cd2292ef824591cc34cc299910a3098545c840c7
    (lib.cmakeFeature "CLANG_TIDY_CONFUSABLE_CHARS_GEN" "${buildLlvmTools.tblgen}/bin/clang-tidy-confusable-chars-gen")
    (lib.cmakeFeature "CLANG_RESOURCE_DIR" "${libclang'.lib}/lib/clang/${lib.versions.major release_version}")
    (lib.cmakeFeature "EXTERNAL_CLANG_RESOURCE_DIR" "${libclang'.lib}/lib/clang/${lib.versions.major release_version}")
  ]
  ++ lib.optionals (lib.versionAtLeast release_version "20") [
    (lib.cmakeFeature "LLVM_DIR" "${libllvm.dev}/lib/cmake/llvm")
    (lib.cmakeFeature "CLANG_DIR" "${libclang'.dev}/lib/cmake/clang")
  ]
  ++ devExtraCmakeFlags;

  postPatch =
    # Manually apply gnu-install-dirs patch to ../clang, kinda jank
    ''
      chmod -R +rw ../clang/
      patch -p1 -d ../clang/ < ${getVersionFile "clang/gnu-install-dirs.patch"}
    ''
    # Make sure clang passes the correct location of libLTO to ld64
    + ''
      substituteInPlace ../clang/lib/Driver/ToolChains/Darwin.cpp \
        --replace-fail 'StringRef P = llvm::sys::path::parent_path(D.Dir);' 'StringRef P = "${lib.getLib libllvm}";'
    ''
    + lib.optionalString stdenv.hostPlatform.isMusl ''
      sed -i -e 's/lgcc_s/lgcc_eh/' ../clang/lib/Driver/ToolChains/*.cpp
    ''
    # Prepend clang-tools-extra with support for being the primary project
    + ''
      mv CMakeLists.txt CMakeLists.txt.orig
      cat ${./clang-tools-extra-external.cmake} CMakeLists.txt.orig > CMakeLists.txt
    ''
    # Add missing include on generated source in the current bin dir for Confusables.inc
    + ''
      substituteInPlace clang-tidy/misc/CMakeLists.txt \
        --replace-fail 'include_directories(BEFORE "''${CMAKE_CURRENT_SOURCE_DIR}/../../include-cleaner/include"' \
        'include_directories(BEFORE "''${CMAKE_CURRENT_SOURCE_DIR}/../../include-cleaner/include" "''${CMAKE_CURRENT_BINARY_DIR}"'
    '';

  outputs = [
    "out"
    "lib"
    "dev"
    "python"
  ];

  separateDebugInfo = true;

  postInstall = ''
    mkdir -p $python/share/clang
    mv $out/share/clang/*.py $python/share/clang
  '';

  passthru = {
    inherit libllvm;
    libclang = libclang';
  };

  # FIXME: Is this still big-parallel? I think it probably isn't
  # requiredSystemFeatures = [ "big-parallel" ];

  meta = llvm_meta // {
    homepage = "https://clang.llvm.org/extra/index.html";
    description = "Extra tools built using Clang's tooling APIs such as clangd and clang-tidy";
    # FIXME: Unsure whether to go with clangd or leave unset
    mainProgram = "clangd";
  };
})
