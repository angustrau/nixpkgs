{ lib
, runCommand
, fetchurl
, tinycc
, gnumake
}:
let
  pname = "gnused";
  # last version that can be compiled with mes-libc
  version = "4.0.9";

  src = fetchurl {
    url = "mirror://gnu/sed/sed-${version}.tar.gz";
    sha256 = "0006gk1dw2582xsvgx6y6rzs9zw8b36rhafjwm288zqqji3qfrf3";
  };

  makefile = fetchurl {
    url = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/sed-4.0.9/mk/main.mk";
    sha256 = "0w1f5ri0g5zla31m6l6xyzbqwdvandqfnzrsw90dd6ak126w3mya";
  };
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc gnumake ];

  meta = with lib; {
    description = "GNU sed, a batch stream editor";
    homepage = "https://www.gnu.org/software/sed";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    mainProgram = "sed";
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output sed.tar
  untar --file sed.tar
  rm sed.tar
  build=''${NIX_BUILD_TOP}/sed-${version}
  cd ''${build}

  # Configure
  catm config.h
  cp ${makefile} Makefile

  # Build
  make LIBC=mes

  # Check
  ./sed/sed --version

  # Install
  mkdir -p ''${out}/bin
  cp sed/sed ''${out}/bin
  chmod 555 ''${out}/bin/sed
''
