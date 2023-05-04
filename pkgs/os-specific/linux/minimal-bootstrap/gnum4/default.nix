{ lib
, runCommand
, fetchurl
, tinycc
, gnumake
, coreutils
}:
let
  pname = "gnum4";
  version = "1.4.7";

  src = fetchurl {
    url = "mirror://gnu/m4/m4-${version}.tar.gz";
    sha256 = "00w3dp8l819x44g4r7b755qj8rch9rzqiky184ga2qzmcwvrjg09";
  };

  # Thanks to the live-bootstrap project!
  # See https://github.com/fosslinux/live-bootstrap/blob/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/m4-1.4.7
  makefile = fetchurl {
    url = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/m4-1.4.7/mk/main.mk";
    sha256 = "0lj6b3hyj6xpsfaih05swk6nzdnj3wwvw09pzm91ciqp6y2c7005";
  };
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc gnumake coreutils ];

  meta = with lib; {
    description = "GNU M4, a macro processor";
    homepage = "https://www.gnu.org/software/m4";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    mainProgram = "m4";
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output m4.tar
  untar --file m4.tar
  rm m4.tar
  build=''${NIX_BUILD_TOP}/m4-${version}
  cd ''${build}

  # Build
  cp ${./stubs.c} src/stubs.c
  make -f ${./Makefile}

  # Check
  ./src/m4 --version

  # Install
  make -f ${./Makefile} install PREFIX=''${out}
''
