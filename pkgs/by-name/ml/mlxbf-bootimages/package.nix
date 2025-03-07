{
  stdenv,
  lib,
  fetchurl,
  dpkg,
}:

stdenv.mkDerivation rec {
  pname = "mlxbf-bootimages";
  version = "4.8.0-13249";

  src = fetchurl {
    url = "https://linux.mellanox.com/public/repo/bluefield/${version}/bootimages/prod/${pname}-signed_${version}_arm64.deb";
    hash = "sha256-VwbngA2UpHtvhCmL21qrebVSNG6/4PbkhnVAmERpek0=";
  };

  nativeBuildInputs = [
    dpkg
  ];

  unpackCmd = "dpkg -x $curSrc src";

  # Only install /lib. /usr only contains the licenses which are also available
  # in /lib.
  installPhase = ''
    find lib -type f -exec install -D {} $out/{} \;
  '';

  meta = with lib; {
    description = "BlueField boot images";
    homepage = "https://github.com/Mellanox/bootimages";
    # It is unclear if the bootimages themselves are Open Source software. They
    # never explicitly say they are. They contain Open Source software licensed
    # under bsd2, bsd2Patent, bsd3. However, it is probably safer to assume
    # they are unfree. See https://github.com/Mellanox/bootimages/issues/3
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
    maintainers = with maintainers; [
      nikstur
      thillux
    ];
  };
}
