{
  lib,
  stdenv,
  fetchRocmSrc,
  sources,
  rocmUpdateScript,
  cmake,
  rocm-cmake,
  gfortran,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hipfort";
  version = sources.hipfort.version;

  src = fetchRocmSrc "hipfort";

  nativeBuildInputs = [
    cmake
    rocm-cmake
    gfortran
  ];

  cmakeFlags = [
    "-DHIPFORT_COMPILER=${gfortran}/bin/gfortran"
    "-DHIPFORT_AR=${gfortran.cc}/bin/gcc-ar"
    "-DHIPFORT_RANLIB=${gfortran.cc}/bin/gcc-ranlib"
    # Manually define CMAKE_INSTALL_<DIR>
    # See: https://github.com/NixOS/nixpkgs/pull/197838
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  postPatch = ''
    patchShebangs bin

    substituteInPlace bin/hipfc bin/mymcpu \
      --replace "/bin/cat" "cat"

    substituteInPlace bin/CMakeLists.txt \
      --replace "/bin/mkdir" "mkdir" \
      --replace "/bin/cp" "cp" \
      --replace "/bin/sed" "sed" \
      --replace "/bin/chmod" "chmod" \
      --replace "/bin/ln" "ln"
  '';

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Fortran interfaces for ROCm libraries";
    homepage = "https://github.com/ROCm/hipfort";
    license = with lib.licenses; [ mit ]; # mitx11
    teams = [ lib.teams.rocm ];
    platforms = lib.platforms.linux;
  };
})
