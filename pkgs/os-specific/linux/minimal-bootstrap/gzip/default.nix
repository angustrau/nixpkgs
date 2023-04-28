{ lib
, runCommand
, fetchurl
, tinycc
, gnumake
}:
let
  pname = "gzip";
  version = "1.2.4";

  src = fetchurl {
    url = "mirror://gnu/gzip/gzip-${version}.tar.gz";
    sha256 = "0ryr5b00qz3xcdcv03qwjdfji8pasp0007ay3ppmk71wl8c1i90w";
  };

  # Thanks to the live-bootstrap project!
  # See https://github.com/fosslinux/live-bootstrap/blob/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/gzip-1.2.4/gzip-1.2.4.kaem
  makefile = fetchurl {
    url = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/gzip-1.2.4/mk/main.mk";
    sha256 = "06c9xl13ym41i2q7rb370kc7affwxbbm6lyqpgbpj6q83bv4dhkq";
  };
  stat_override_c = fetchurl {
    url = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/gzip-1.2.4/files/stat_override.c";
    sha256 = "1216xn1536mfjyx9j1b6128ynb3mfdmy68h7y0n656sk9p5rpf75";
  };
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
  ];

  meta = with lib; {
    description = "GNU zip compression program";
    homepage = "https://www.gnu.org/software/gzip";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output gzip.tar
  untar --file gzip.tar
  rm gzip.tar
  build=''${NIX_BUILD_TOP}/gzip-${version}
  cd ''${build}

  # Configure
  catm gzip.c.new ${stat_override_c} gzip.c
  cp gzip.c.new gzip.c

  # Build
  make -f ${makefile} PREFIX=''${out}

  # Check
  ./gzip --version

  # Install
  mkdir -p ''${out}/bin
  cp gzip ''${out}/bin/gzip
  cp gzip ''${out}/bin/gunzip
  chmod 555 ''${out}/bin/gzip
  chmod 555 ''${out}/bin/gunzip
''
