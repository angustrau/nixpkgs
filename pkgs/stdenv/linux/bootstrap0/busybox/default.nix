{ fetchurl, runKaem, musl-tcc, gnumake, sed, coreutils, musl }:
let
  # Latest version we are able to decompress
  version = "1.35.0";
  src = builtins.fetchTarball {
    url = "https://busybox.net/downloads/busybox-${version}.tar.bz2";
    sha256 = "08zmdlzhwkmki7q2kysahnm5jprgw0gs9md6ryk4pv0q7afdrnaf";
  };
  # 0.25 1.00 1.40
in
runKaem {
  name = "busybox";
  buildInputs = [ musl-tcc gnumake sed coreutils musl ];
  scriptText = ''
    cp -r ${src} src/
    chmod -R a+rw src/
    cd src/

    # replace --file Makefile --output Makefile --match-on "-Wp,-MD," --replace-with "-Wp -MD "

    make \
      V=1 \
      BUILD_OUTPUT=''${TMPDIR} \
      SUBARCH=i386 \
      ARCH=i386 \
      CC=tcc \
      CFLAGS="-static" \
      HOSTCC=tcc \
      HOSTCFLAGS="-static" \
      c_flags="-static" \
      a_flags= \
      hostc_flags="-static -include ${musl}/include/stdlib.h -lc" \
      allnoconfig
    cp .config ''${out}
  '';
  # scriptText = ''
  #   CC=tcc
  #   CFLAGS="-include ${./autoconf.h}"
  #   make -f ${./Makefile} -C ${src}
  # '';
  # scriptText = ''
  #   tcc \
  #     -I ${src}/include \
  #     ${src}/shell/ash.c
  # '';
}
