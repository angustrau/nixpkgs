{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, tinycc
, heirloom-devtools
}:
let
  pname = "binutils";
  version = "2.14";

  src = fetchurl {
    url = "https://github.com/bminor/binutils-gdb/archive/refs/tags/binutils-2_14.tar.gz";
    sha256 = "08dqxvqi55fzwxvhfcysgiwl58ndblicn5icbqby33vjbxb5ycab";
  };
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc heirloom-devtools ];

  meta = with lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    homepage = "https://www.gnu.org/software/binutils";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output binutils.tar
  untar --file binutils.tar
  rm binutils.tar
  cd binutils-gdb-binutils-2_14

  # Patch
  sed -i -e "s/doc po//g" gas/Makefile.in

  # Configure
  export CC="tcc -static -D __GLIBC_MINOR__=6"
  export AR="tcc -ar"
  export RANLIB=true
  bash ./configure \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --disable-nls \
    --disable-shared \
    --disable-werror \
    --prefix=$out
  make configure-host MAKEINFO=true PERL=true TEXI2POD=true POD2MAN=true
  # set
  # cp -r . $out

  # Build
  make MAKEINFO=true PERL=true TEXI2POD=true POD2MAN=true

  # Check

  # Install
  # make install
''
