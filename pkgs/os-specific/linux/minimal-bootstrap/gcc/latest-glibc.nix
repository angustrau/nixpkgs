{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, coreutils
, gcc
, glibc
, linux-headers
, binutils
, gnumake
, gnused
, gnugrep
, gawk
, diffutils
, findutils
, gnutar
, gzip
, bzip2
, xz
, musl
}:
let
  pname = "gcc-glibc";
  version = "13.2.0";

  src = fetchurl {
    url = "mirror://gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
    hash = "sha256-4nXnZEKmBnNBon8Exca4PYYTFEAEwEE1KIY9xrXHQ9o=";
  };

  gmpVersion = "6.3.0";
  gmp = fetchurl {
    url = "mirror://gnu/gmp/gmp-${gmpVersion}.tar.xz";
    hash = "sha256-o8K4AgG4nmhhb0rTC8Zq7kknw85Q4zkpyoGdXENTiJg=";
  };

  mpfrVersion = "4.2.1";
  mpfr = fetchurl {
    url = "mirror://gnu/mpfr/mpfr-${mpfrVersion}.tar.xz";
    hash = "sha256-J3gHNTpnJpeJlpRa8T5Sgp46vXqaW3+yeTiU4Y8fy7I=";
  };

  mpcVersion = "1.3.1";
  mpc = fetchurl {
    url = "mirror://gnu/mpc/mpc-${mpcVersion}.tar.gz";
    hash = "sha256-q2QkkvXPiCt0qgy3MM1BCoHtzb7IlRg86TDnBsHHWbg=";
  };

  islVersion = "0.24";
  isl = fetchurl {
    url = "https://gcc.gnu.org/pub/gcc/infrastructure/isl-${islVersion}.tar.bz2";
    hash = "sha256-/PeN2WVsEOuM+fvV9ZoLawE4YgX+GTSzsoegoYmBRcA=";
  };
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    gcc
    binutils
    gnumake
    gnused
    gnugrep
    gawk
    diffutils
    findutils
    gnutar
    gzip
    bzip2
    xz
  ];

  passthru.tests.hello-world = result:
    bash.runCommand "${pname}-simple-program-${version}" {
        nativeBuildInputs = [ binutils result ];
      } ''
        cat <<EOF >> test.c
        #include <stdio.h>
        int main() {
          printf("Hello World!\n");
          return 0;
        }
        EOF
        gcc \
          -Wl,--dynamic-linker=${glibc}/lib/ld-linux.so.2 \
          -B${glibc}/lib \
          -I${glibc}/include \
          -o test test.c
        ./test
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
  tar xf ${src}
  tar xf ${gmp}
  tar xf ${mpfr}
  tar xf ${mpc}
  tar xf ${isl}
  cd gcc-${version}

  ln -s ../gmp-${gmpVersion} gmp
  ln -s ../mpfr-${mpfrVersion} mpfr
  ln -s ../mpc-${mpcVersion} mpc
  ln -s ../isl-${islVersion} isl

  # Patch

  # Configure
  # export CC="gcc -Wl,-dynamic-linker -Wl,${glibc}/lib/ld-linux.so.2 -I${glibc}/include -I${linux-headers}/include"
  # export CXX="g++ -Wl,-dynamic-linker -Wl,${glibc}/lib/ld-linux.so.2 -I${glibc}/include -I${linux-headers}/include"
  # # export CC="gcc -Wl,--dynamic-linker=${glibc}/lib/ld-linux.so.2"
  # # export CXX="g++ -Wl,--dynamic-linker=${glibc}/lib/ld-linux.so.2"
  # # export CPP="gcc -E -I${gcc}/lib/gcc-lib/${hostPlatform.config}/${version}/include -I${glibc}/include -I${linux-headers}/include"
  # # export CPP="gcc -E -I${glibc}/include -I${linux-headers}/include"
  # # export CXXCPP="g++ -E -I${glibc}/include -I${linux-headers}/include"
  # export CFLAGS_FOR_TARGET="-Wl,-dynamic-linker -Wl,${glibc}/lib/ld-linux.so.2"
  # export CXXFLAGS_FOR_TARGET="$CFLAGS_FOR_TARGET"
  # # export C_INCLUDE_PATH="${glibc}/include:${linux-headers}/include:${gcc}/lib/gcc-lib/${hostPlatform.config}/${version}/include"
  # # export C_INCLUDE_PATH="${glibc}/include:${linux-headers}/include"
  # # export CXX_INCLUDE_PATH="$C_INCLUDE_PATH"
  # export LIBRARY_PATH="${glibc}/lib"

  export CC="gcc -Wl,-dynamic-linker -Wl,${glibc}/lib/ld-linux.so.2"
  export CXX="g++ -Wl,-dynamic-linker -Wl,${glibc}/lib/ld-linux.so.2"
  export CFLAGS_FOR_TARGET="-Wl,-dynamic-linker -Wl,${glibc}/lib/ld-linux.so.2"
  export LIBRARY_PATH="${glibc}/lib"

  export C_INCLUDE_PATH="${gcc}/lib/gcc-lib/${hostPlatform.config}/${version}/include:${glibc}/include:${linux-headers}/include"
  export CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH"
  export CXXFLAGS_FOR_TARGET="$CFLAGS_FOR_TARGET"

  export HOME=$(mktemp -d)
  bash ./configure \
    --prefix=$out \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --with-native-system-header-dir=/include \
    --with-build-sysroot=${glibc} \
    --enable-languages=c,c++ \
    --disable-bootstrap \
    --disable-libsanitizer \
    --disable-lto \
    --disable-multilib \
    --disable-plugin \
    --disable-fixincludes

  # Build
  make -j $NIX_BUILD_CORES

  # Install
  make -j $NIX_BUILD_CORES install
''
