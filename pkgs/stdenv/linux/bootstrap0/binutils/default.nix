{ fetchurl, stdenvNoCC, tcc, gnumake, coreutils, patch }:
let
  version = "2.14";
  src = fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.gz";
    sha256 = "1w8xp7k44bkijr974x9918i4p1sw4g2fcd5mxvspkjpg38m214ds";
  };
in
stdenvNoCC.mkDerivation {
  name = "binutils-${version}";
  nativeBuildInputs = [ tcc gnumake patch ];

  scriptText = ''
    # Manually unpack since we don't have access to tar
    ungz --file ${src} --output binutils.tar
    untar --file binutils.tar
    cd binutils-${version}

    # Create various .h files
    touch config.h
    touch include/version.h
    touch include/pipesize.h

    for dir in intl libiberty opcodes bfd binutils gas gprof ld; do
        cd $dir

        LD="true" AR="tcc -ar" RANLIB="true" CC="tcc -D __GLIBC_MINOR__=6 -DHAVE_SBRK=1" \
            ./configure \
            --disable-nls \
            --disable-shared \
            --disable-werror \
            --build=i386-unknown-linux-gnu \
            --host=i386-unknown-linux-gnu \
            --target=i386-unknown-linux-gnu \
            --with-sysroot="${PREFIX}" \
            --disable-64-bit-bfd \
            --prefix="${PREFIX}" \
            --libdir="${PREFIX}/lib/musl" \
            --srcdir=.
        cd ..
    done

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
