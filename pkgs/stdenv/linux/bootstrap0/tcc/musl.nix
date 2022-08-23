{ runKaem, tcc, musl }:
let
  inherit (tcc) src version bootstrapSrc bootstrapVersion tccdefs;
  musl-tcc = runKaem {
    name = "musl-tcc-${version}";
    buildInputs = [ musl ];
    scriptText = ''
      mkdir -p ''${out}/bin ''${out}/lib
      catm config.h

      ${tcc}/bin/tcc -c -D HAVE_CONFIG_H=1 -D TCC_TARGET_I386=1 -D TCC_MUSL=1 ${src}/lib/libtcc1.c
      ${tcc}/bin/tcc -ar cr "''${out}/lib/libtcc1.a" libtcc1.o

      ${tcc}/bin/tcc \
        -o ''${out}/bin/tcc \
        -D BOOTSTRAP=1 \
        -nostdinc \
        -nostdlib \
        -static \
        -I . \
        -I ${src} \
        -I ${musl}/include \
        -D TCC_TARGET_I386=1 \
        -D inline= \
        -D CONFIG_TCCDIR=\"''${out}/lib\" \
        -D CONFIG_SYSROOT=\"\" \
        -D CONFIG_TCC_CRTPREFIX=\"${musl}/lib\" \
        -D CONFIG_TCC_ELFINTERP=\"/musl/loader\" \
        -D CONFIG_TCC_LIBPATHS=\"${musl}/lib:''${out}/lib\" \
        -D CONFIG_TCC_SYSINCLUDEPATHS=\"${musl}/include:${src}/include\" \
        -D TCC_LIBGCC=\"${musl}/lib/libc.a\" \
        -D CONFIG_TCC_LIBTCC1_MES=0 \
        -D CONFIG_TCCBOOT=1 \
        -D CONFIG_TCC_STATIC=1 \
        -D CONFIG_USE_LIBGCC=1 \
        -D TCC_MES_LIBC=1 \
        -D TCC_MUSL=1 \
        -D TCC_VERSION=\"${version}\" \
        -D ONE_SOURCE=1 \
        -D __intptr_t_defined=1\
        -D CONFIG_TCC_PREDEFS=1 \
        -I ${tccdefs} \
        -L ${musl}/lib \
        ${src}/tcc.c \
        ${musl}/lib/crt1.o ${musl}/lib/crti.o ${musl}/lib/libc.a ${musl}/lib/crtn.o ''${out}/lib/libtcc1.a

      ''${out}/bin/tcc -v
    '';
  };
in
musl-tcc // {
  inherit (tcc) src version bootstrapSrc bootstrapVersion tccdefs;
}
