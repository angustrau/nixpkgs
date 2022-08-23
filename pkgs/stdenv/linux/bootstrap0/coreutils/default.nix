# We don't build touch
{ fetchurl, runKaem, tcc, gnumake, sed, patch }:
let
  version = "5.0";
  src = fetchurl {
    url = "mirror://gnu/coreutils/coreutils-${version}.tar.gz";
    sha256 = "10wq6k66i8adr4k08p0xmg87ff4ypiazvwzlmi7myib27xgffz62";
  };
in
runKaem {
  name = "coreutils-${version}";
  buildInputs = [ tcc gnumake sed patch ];
  scriptText = ''
    ungz --file ${src} --output coreutils.tar
    untar --file coreutils.tar
    cd coreutils-${version}

    catm config.h
    cp lib/fnmatch_.h lib/fnmatch.h
    cp lib/ftw_.h lib/ftw.h
    cp lib/search_.h lib/search.h
    rm src/false.c

    patch -Np0 -i ${./patches/modechange.patch}
    patch -Np0 -i ${./patches/mbstate.patch}
    patch -Np0 -i ${./patches/ls-strcmp.patch}
    patch -Np0 -i ${./patches/touch-getdate.patch}
    patch -Np0 -i ${./patches/touch-dereference.patch}
    patch -Np0 -i ${./patches/tac-uint64.patch}

    mkdir -p ''${out}/bin
    make -f ${./Makefile} PREFIX=''${out}
    make -f ${./Makefile} PREFIX=''${out} install
  '';
}
