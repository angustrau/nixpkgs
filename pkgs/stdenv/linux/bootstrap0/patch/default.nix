{ fetchurl, runKaem, tcc, gnumake, sed }:
let
  version = "2.5.9";
  src = fetchurl {
    url = "mirror://gnu/patch/patch-${version}.tar.gz";
    sha256 = "12nv7jx3gxfp50y11nxzlnmqqrpicjggw6pcsq0wyavkkm3cddgc";
  };
in
runKaem {
  name = "patch-${version}";
  buildInputs = [ tcc gnumake sed ];
  scriptText = ''
    ungz --file ${src} --output patch.tar
    untar --file patch.tar
    cd patch-${version}

    catm config.h
    catm patchlevel.h
    cp pch.c pch_patched.c
    sed -i 841,848d pch_patched.c
    cp ${./mbstate_t.h} mbstate_t.h

    make -f ${./Makefile} PREFIX=''${out}
    mkdir -p ''${out}/bin
    cp patch ''${out}/bin/patch
    chmod 555 ''${out}/bin/patch
  '';
}
