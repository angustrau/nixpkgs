{ lib
, runCommand
, fetchurl
, tinycc
, gnumake
, gnupatch
, gnused
, coreutils
, bash
, heirloom-devtools
}:
let
  pname = "flex";
  version = "2.5.11";

  src = fetchurl {
    url = "http://download.nust.na/pub2/openpkg1/sources/DST/flex/flex-${version}.tar.gz";
    sha256 = "129nsxxhn5gzsmwfy45xri8iw4r6h9sy79l9zxk8v8swyf8bhydw";
  };

  # Thanks to the live-bootstrap project!
  # See https://github.com/fosslinux/live-bootstrap/blob/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/flex-2.5.11
  liveBootstrap = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/flex-2.5.11";

  makefile = fetchurl {
    url = "${liveBootstrap}/mk/main.mk";
    sha256 = "0nghqg6yibxwiiylcqsjyv0bdpdi8nfcf6k5hbbcq7054fcha3b4";
  };

  scan_lex_l = fetchurl {
    url = "${liveBootstrap}/files/scan.lex.l";
    sha256 = "0ilwrhvq02r6kf7rbf0c7b2664nwiaq0zd6g7waz0qmr27f1pij4";
  };

  patches = [
    # Comments are unsupported by our flex
    (fetchurl {
      url = "${liveBootstrap}/patches/scan_l.patch";
      sha256 = "0bs2af6wzi1ih10jyhmhcfplmqi1jcz0r3gsmimi14lh9lwmmama";
    })
    # yyin has an odd redefinition error in scan.l, so we ensure that we don't
    # acidentally re-declare it.
    (fetchurl {
      url = "${liveBootstrap}/patches/yyin.patch";
      sha256 = "01fhfi80pldw7wk52dswagc10xwbf78wxfnwllfb78mahzbwal1b";
    })
  ];
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
    gnupatch
    gnused
    coreutils
    bash
    heirloom-devtools
  ];

  meta = with lib; {
    description = "GNU Bourne-Again Shell, the de facto standard shell on Linux";
    homepage = "https://www.gnu.org/software/bash";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output flex.tar
  untar --file flex.tar
  rm flex.tar
  build=''${NIX_BUILD_TOP}/flex-${version}
  cd ''${build}

  # Patch
  ${lib.concatLines (map (f: "patch -Np0 -i ${f}") patches)}

  # Configure
  cp ${makefile} Makefile
  # Replace hardcoded /bin/sh with bash in PATH
  sed -i "s|/bin/sh|sh|g" Makefile
  cp ${scan_lex_l} scan.lex.l
  touch config.h
  rm parse.c parse.h scan.c skel.c

  # Build
  make LDFLAGS="-static -L${heirloom-devtools}/lib/lex"

  # Check
  ./flex --version

  # Install
  make install PREFIX=''${out}
''
