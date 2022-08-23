{ fetchurl, runKaem, tcc, gnumake, sed, coreutils }:
let
  version = "1.2.3";
  src = builtins.fetchTarball {
    url = "https://musl.libc.org/releases/musl-${version}.tar.gz";
    sha256 = "00r0pcawgid6bfm8l7vhls3zs1ksca3vs58vjjjq9asarnwyfg31";
  };

  alltypes_h = runKaem {
    name = "alltypes.h-${version}";
    buildInputs = [ sed ];
    scriptText = ''
      catm ''${out} ${src}/arch/i386/bits/alltypes.h.in ${src}/include/alltypes.h.in
      sed -f ${src}/tools/mkalltypes.sed -i ''${out}
    '';
  };

  syscall_h = runKaem {
    name = "syscall.h-${version}";
    buildInputs = [ sed coreutils ];
    scriptText = ''
      cp --preserve="mode" ${src}/arch/i386/bits/syscall.h.in ./syscall.h
      sed -i -n -e s/__NR_/SYS_/p ./syscall.h
      catm ''${out} ${src}/arch/i386/bits/syscall.h.in syscall.h
    '';
  };
in
runKaem {
  name = "musl-${version}";
  buildInputs = [ tcc gnumake sed coreutils ];
  scriptText = ''
    cp -r ${src} src
    chmod -R a+rw ./src
    cd src/

    catm config.mak

    replace --file src/signal/i386/sigsetjmp.s --output src/signal/i386/sigsetjmp.s --match-on "jecxz 1f" --replace-with "cmp %ecx,0\nje 1f"
    replace --file src/include/features.h --output src/include/features.h --match-on "__weak__, " --replace-with ""
    rm -rf src/complex src/math/i386/ src/math/sqrtl.c

    mkdir -p obj/include/bits/ lib/
    cp --preserve="mode" ${alltypes_h} obj/include/bits/alltypes.h
    cp --preserve="mode" ${syscall_h} obj/include/bits/syscall.h

    make \
      prefix=''${out} \
      libdir=''${out}/lib \
      includedir=''${out}/include \
      CC=tcc \
      ARCH=i386 \
      CROSS_COMPILE= \
      AR="tcc -ar" \
      RANLIB=true \
      CFLAGS="-DSYSCALL_NO_TLS -static" \
      SHARED_LIBS= \
      TOOL_LIBS= \
      EMPTY_LIBS= \
      ALL_TOOLS=

    chmod -R a+r .
    make \
      prefix=''${out} \
      libdir=''${out}/lib \
      includedir=''${out}/include \
      CC=tcc \
      ARCH=i386 \
      CROSS_COMPILE= \
      AR="tcc -ar" \
      RANLIB=true \
      CFLAGS="-DSYSCALL_NO_TLS -static" \
      SHARED_LIBS= \
      TOOL_LIBS= \
      EMPTY_LIBS= \
      ALL_TOOLS= \
      install
  '';
  # Disable TOOL_LIBS, fails to build without /bin/sh
}
