{ lib
, buildPlatform
, hostPlatform
, targetPlatform
, fetchurl
, bash
, tinycc
, gnumake
, gnupatch
, gnugrep
, gnutar
, gzip
, heirloom
, binutils
, mes-libc
}:
let
  # Gcc-2.95.3 is the most recent GCC that is supported by what the Mes C
  # Library v0.16 offers.  Gcc-3.x (and 4.x) place higher demands on a C
  # library, such as dir.h/struct DIR/readdir, locales, signals...  Also,
  # with gcc-2.95.3, binutils (2.14.0, 2.20.1a) and glibc-2.2.5 we found a
  # GNU toolchain triplet "that works".
  #   - from guix/gnu/packages/commencement.scm
  pname = "gcc-mes";
  version = "2.95.3";

  src = fetchurl {
    url = "mirror://gnu/gcc/gcc-${version}/gcc-core-${version}.tar.gz";
    sha256 = "1xvfy4pqhrd5v2cv8lzf63iqg92k09g6z9n2ah6ndd4h17k1x0an";
  };

  patches = [
    (fetchurl {
      url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/gcc-boot-2.95.3.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
      sha256 = "03l3jaxch6d76mx4zkn6ky64paj58jk0biddck01qd4bnw9z8hiw";
    })
  ];
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc.compiler
    gnumake
    gnupatch
    gnugrep
    gnutar
    gzip
    heirloom.sed
    binutils
  ];

  passthru.tests.get-version = result:
    bash.runCommand "${pname}-get-version-${version}" {} ''
      ${result}/bin/gcc --version
      mkdir $out
    '';

  meta = with lib; {
    description = "GNU Compiler Collection, version ${version}";
    homepage = "https://gcc.gnu.org";
    license = licenses.gpl3Plus;
    maintainers = teams.minimal-bootstrap.members;
    platforms = platforms.unix;
  };
} ''
  # Unpack
  tar xzf ${src}
  cd gcc-${version}

  # Patch
  ${lib.concatMapStringsSep "\n" (f: "patch -Np1 -i ${f}") patches}
  replace --file gcc/gcc.c --output gcc/gcc.c --match-on '/usr/lib/' --replace-with '${tinycc.libs}/lib/'

  # Configure
  export CC="tcc -B ${tinycc.libs}/lib -D __GLIBC_MINOR__=6"
  export OLDCC="$CC"
  export CC_FOR_BUILD="$CC"
  export CPP="tcc -E"
  export AR=ar
  export RANLIB=ranlib
  export ac_cv_func_setlocale=no
  export ac_cv_c_float_format='IEEE (little-endian)'
  bash ./configure \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --target=${targetPlatform.config} \
    --enable-static \
    --disable-shared \
    --disable-werror \
    --prefix=$out
  # no info at this stage
  touch gcc/cpp.info gcc/gcc.info

  # Build
  make \
    LIBGCC2_INCLUDES="-I ${mes-libc}/include" \
    LANGUAGES=c \
    BOOT_LDFLAGS=" -B ${tinycc.libs}/lib" \
    includedir=${mes-libc}/include

  # Install
  make install
  mkdir tmp
  cd tmp
  ar x ../gcc/libgcc2.a
  ar x ${tinycc.libs}/lib/libtcc1.a
  ar r $out/lib/gcc-lib/${targetPlatform.config}/${version}/libgcc.a *.o
  cd ..
  cp gcc/libgcc2.a $out/lib/libgcc2.a
  ar x ${tinycc.libs}/lib/libtcc1.a
  ar x ${tinycc.libs}/lib/libc.a
  ar r $out/lib/gcc-lib/${targetPlatform.config}/${version}/libc.a libc.o libtcc1.o
''
