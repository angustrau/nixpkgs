{ lib
, buildPlatform
, hostPlatform
, fetchurl
, writeText
, bash
, tinycc
, heirloom-devtools
, gawk
, gnused
}:
let
  pname = "gawk";
  # latest version that can be configured with gawk 3.0.0
  version = "3.1.8";

  src = fetchurl {
    url = "mirror://gnu/gawk/gawk-${version}.tar.gz";
    sha256 = "03d5y7jabq7p2s7ys9alay9446mm7i5g2wvy8nlicardgb6b6ii1";
  };

  stub_c = writeText "stub.c" ''
    int main() {
      return 1;
    }
  '';
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc heirloom-devtools gawk gnused ];

  meta = with lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    homepage = "https://www.gnu.org/software/binutils";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output gawk.tar
  untar --file gawk.tar
  rm gawk.tar
  build=''${NIX_BUILD_TOP}/gawk-${version}
  cd ''${build}

  # Patch
  cp ${stub_c} awklib/eg/lib/pwcat.c

  # Configure
  export CC="tcc -static -D __GLIBC_MINOR__=6"
  export AR="tcc -ar"
  export LD="tcc"
  export RANLIB=true
  export ac_cv_header_locale_h=no
  export ac_cv_func_working_mktime=yes
  export ac_cv_func_tzset=yes
  export ac_cv_header_dlfcn_h=no
  bash ./configure \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --disable-nls \
    --disable-shared \
    --disable-werror \
    --prefix=$out || cat config.log

  # Build
  make

  # Check
  ./gawk --version

  # Install
  make install INSTALL=install
''
