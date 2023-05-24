{ lib
, runCommand
, fetchurl
, tinycc
, gnumake
, coreutils
, heirloom-devtools
, stage
}:
let
  pname = "bison";
  version = "3.4.1";

  src = fetchurl {
    url = "mirror://gnu/bison/bison-${version}.tar.gz";
    sha256 = "1c1zvcyrn0xpnzdjzm7h4iyri02yx5wzzhlqka5mldzl3zpmvhsw";
  };

  # Thanks to the live-bootstrap project!
  # See https://github.com/fosslinux/live-bootstrap/blob/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/bison-3.4.1
  makefile = fetchurl {
    url = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/gawk-3.0.4/mk/main.mk";
    sha256 = "05s66037p96rffdrlijp9x292iki813xkcm98c72qvk67zh9adi2";
  };
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
    coreutils
    heirloom-devtools
  ];

  meta = with lib; {
    description = "GNU implementation of the Unix grep command";
    homepage = "https://www.gnu.org/software/grep";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    mainProgram = "grep";
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output gawk.tar
  untar --file gawk.tar
  rm gawk.tar
  build=''${NIX_BUILD_TOP}/gawk-${version}
  cd ''${build}

  # Configure
  cp ${./Makefile} Makefile
  rm awktab.c

  # Build
  make CC="tcc -static"

  # Check
  ./awk --version

  # Install
  make install PREFIX=''${out}
''
