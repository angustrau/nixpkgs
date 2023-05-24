{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, tinycc
, gnumake
, gnupatch
, gnused
, gnugrep
, gnutar
, gawk
, coreutils
, gnused_4
, cheatingPkgs
}:
let
  pname = "binutils";
  version = "2.20.1";

  src = fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}a.tar.bz2";
    sha256 = "0r7dr0brfpchh5ic0z9r4yxqn4ybzmlh25sbp30cacqk8nb7rlvi";
  };

  patches = [
    (fetchurl {
      url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/binutils-boot-2.20.1a.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
      sha256 = "086sf6an2k56axvs4jlky5n3hs2l3rq8zq5d37h0b69cdyh7igpn";
    })
  ];
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
    gnupatch
    gnused
    gnugrep
    gnutar
    gawk
    # cheatingPkgs.gawk
    coreutils
  ];

  meta = with lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    homepage = "https://www.gnu.org/software/binutils";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  unbz2 --file ${src} --output binutils.tar
  tar xf binutils.tar
  rm binutils.tar
  cd binutils-${version}

  # Patch
  ${lib.concatLines (map (f: "patch -Np1 -i ${f}") patches)}
  # export MES_DEBUG=5

  # Configure
  export CC="tcc -static -DMES_BOOTSTRAP=1"
  export AR="tcc -ar"
  export RANLIB=true
  export SHELL=bash
  export CONFIG_SHELL=bash
  bash ./configure \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --disable-nls \
    --disable-shared \
    --disable-werror \
    --prefix=$out

  # Build
  make

  # Check

  # Install
  # make install
''
