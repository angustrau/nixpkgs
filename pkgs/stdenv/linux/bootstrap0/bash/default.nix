{ fetchurl, runKaem, tcc, gnumake, coreutils, patch }:
let
  version = "2.05b";
  src = fetchurl {
    url = "https://mirrors.kernel.org/gnu/bash/bash-${version}.tar.gz";
    sha256 = "1r1z2qdw3rz668nxrzwa14vk2zcn00hw7mpjn384picck49d80xs";
  };
in
runKaem {
  name = "bash-${version}";
  buildInputs = [ tcc gnumake coreutils patch ];
  scriptText = ''
    ungz --file ${src} --output bash.tar
    untar --file bash.tar
    cd bash-${version}

    cp --preserve=mode ${./mk/main.mk} Makefile
    cp --preserve=mode ${./mk/builtins.mk} builtins/Makefile
    cp --preserve=mode ${./mk/common.mk} common.mk

    # Create various .h files
    touch config.h
    touch include/version.h
    touch include/pipesize.h

    # Patch
    patch -Np0 -i ${./patches/mes-libc.patch}
    patch -Np0 -i ${./patches/tinycc.patch}
    patch -Np0 -i ${./patches/missing-defines.patch}
    patch -Np0 -i ${./patches/locale.patch}
    patch -Np0 -i ${./patches/dev-tty.patch}

    # Compile
    cat Makefile
    make mkbuiltins
    cd builtins
    make libbuiltins.a
    cd ..
    make

    # Install
    install -D bash ''${out}/bin/bash
    ln -s ''${out}/bin/bash ''${out}/bin/sh
  '';
}
