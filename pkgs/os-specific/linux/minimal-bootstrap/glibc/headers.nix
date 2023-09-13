{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, gcc
, gnumake
, gnupatch
, gnused
, gnugrep
, gnutar
, gzip
, gawk
, binutils
, linux-headers
, findutils
, glibc22
}:
let
  inherit (import ./common.nix { inherit lib; }) pname meta;

  version = "2.16.0";

  src = fetchurl {
    url = "mirror://gnu/glibc/glibc-${version}.tar.gz";
    sha256 = "0vlz4x6cgz7h54qq4528q526qlhnsjzbsvgc4iizn76cb0bfanx7";
  };

  patches = [
    # This patch enables building glibc-2.16.0 using TCC and GNU Make 4.x and Mes C Library.
    # * Makefile: Do not link with (non-existent) libgc_eh.
    # * Makefile: Add SHELL variable, ready for substitution, export it.
    # * Makefile: Do not build or assume librpc_compat_pic.
    # * Makefile: Do not build libmesusage.
    # * gen-as-const: Always add preamble.
    # * [BOOTSTRAP_GLIBC]: Really disable rpc.
    (fetchurl {
      url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/glibc-boot-${version}.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
      sha256 = "120fmh4bwpaklrkkspg6p4jqwprh6xysbc4gxhilg4pmzwjivrix";
    })
    # We want to allow builds in chroots that lack /bin/sh.  Thus, system(3)
    # and popen(3) need to be tweaked to use the right shell.  For the bootstrap
    # glibc, we just use whatever `sh' can be found in $PATH.  The final glibc
    # instead uses the hard-coded absolute file name of `bash'.
    (fetchurl {
      url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/glibc-bootstrap-system-${version}.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
      sha256 = "1zshpfbg16b5dca3v5p02sp990lzcm90r2ww71i7jjcxkckg2706";
    })
  ];

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--build=${buildPlatform.config}"
    "--host=${hostPlatform.config}"
    "--with-headers=${linux-headers}/include"
    "--enable-static"
    "--disable-shared"
    "--disable-obsolete-rpc"
    "--enable-static-nss"
    "--with-pthread"
    "--without-cvs"
    "--without-gd"
    "--enable-add-ons=nptl"
    # avoid: configure: error: confusing output from nm -u
    "libc_cv_predef_stack_protector=no"
  ];
in
bash.runCommand "${pname}-${version}" {
  inherit pname version meta;

  nativeBuildInputs = [
    gcc
    gnumake
    gnupatch
    gnused
    gnugrep
    gnutar
    gzip
    gawk
    binutils
    findutils
  ];
} ''
  # Unpack
  tar xzf ${src}
  cd glibc-${version}

  # Patch
  ${lib.concatMapStringsSep "\n" (f: "patch -Np1 --posix --force -i ${f}") patches}
  sed -i \
    -e 's|/bin/pwd|pwd|g' \
    -e 's/3.79*/4.*/g'\
    configure
  # nscd needs libgcc, and we don't want it dynamically linked
  # because we don't want it to depend on bootstrap-tools libs.
  echo "LDFLAGS-nscd += -static-libgcc" >> nscd/Makefile

  # Configure
  export CC="gcc -D BOOTSTRAP_GLIBC=1 -I $(pwd)/nptl/sysdeps/pthread/bits -L ${glibc22}/lib -L $(pwd)"
  export CPP="gcc -E -D BOOTSTRAP_GLIBC=1 -I $(pwd)/nptl/sysdeps/pthread/bits"
  export LD="gcc"
  export libc_cv_friendly_stddef=yes
  # avoid -fstack-protector
  export libc_cv_ssp=false
  mkdir build
  cd build
  bash ../configure ${lib.concatStringsSep " " configureFlags}

  make "$(pwd)/sysd-sorted"
  sed -i \
    -e 's/ sunrpc/ /g' \
    -e 's/ nis/ /g' \
    sysd-sorted

  # Install
  mkdir $out
  cp -r ${linux-headers}/include $out
  chmod -R +w $out/include
  make install-bootstrap-headers=yes install-headers
''
