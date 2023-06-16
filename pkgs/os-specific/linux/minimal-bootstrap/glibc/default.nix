{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, gcc2-mes
, gnumake
, gnupatch
, gnused
, gnugrep
, gnutar
, gzip
, gawk
, heirloom
, binutils, binutils-mes
, linuxHeaders
}:
let
  pname = "glibc";

  buildGlibc = { version, src, patches, configureFlags, gcc, binutils, CC, CPP }:
    bash.runCommand "${pname}-${version}" {
      inherit pname version;

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
      ];

      meta = with lib; {
        description = "The GNU C Library";
        homepage = "https://www.gnu.org/software/libc";
        license = licenses.lgpl2Plus;
        maintainers = teams.minimal-bootstrap.members;
        platforms = platforms.linux;
      };
    } ''
      # Unpack
      tar xzf ${src}
      cd glibc-${version}

      # Patch
      ${lib.concatMapStringsSep "\n" (f: "patch -Np1 -i ${f}") patches}

      # Configure
      export CC="${CC}"
      export CPP="${CPP}"
      bash ./configure --prefix=$out ${lib.concatStringsSep " " (
        [
          "--build=${buildPlatform.config}"
          "--host=${hostPlatform.config}"
          "--with-headers=${linuxHeaders}/include"
          "--enable-static"
          "--disable-shared"
        ] ++ configureFlags)}

      # Build
      make

      # Install
      # GNU sed w/ mes-libc crashes on certain stdio actions
      export PATH="${heirloom.sed}/bin:$PATH"
      make install
    '';
in
{
  glibc22 = buildGlibc rec {
    # GNU C Library 2.2.5 is the most recent glibc that we managed to build
    # using gcc-2.95.3.  Newer versions (2.3.x, 2.6, 2.1x) seem to need a newer
    # gcc.
    #   - from guix/gnu/packages/commencement.scm
    version = "2.2.5";
    src = fetchurl {
      url = "mirror://gnu/glibc/glibc-${version}.tar.gz";
      sha256 = "1vl48i16gx6h68whjyhgnn1s57vqq32f9ygfa2fls7pdkbsqvp2q";
    };

    patches = [
      # This patch enables building glibc-2.2.5 using TCC and GNU Make 4.x and Mes C Library.
      #   * Makefile: Do not assemble from stdin, use file indirection.
      #   * Makefile: Add new target: install-lib-all.
      #   * Makefile: Avoid building stub DOC.
      #   * [_LIBC_REENTRANT]: Add missing guarding.
      #   * [MES_BOOTSTRAP]: Disable some GCC extensions.
      #   * [MES_BOOTSTRAP]: Add missing GCC div/mod defines.
      (fetchurl {
        url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/glibc-boot-${version}.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
        sha256 = "1nyz2dr9g7scqwwygd6jvbl7xxpwh11ryvgdz8aikkkna02q1pm8";
      })
      # We want to allow builds in chroots that lack /bin/sh.  Thus, system(3)
      # and popen(3) need to be tweaked to use the right shell.  For the bootstrap
      # glibc, we just use whatever `sh' can be found in $PATH.  The final glibc
      # instead uses the hard-coded absolute file name of `bash'.
      (fetchurl {
        url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/glibc-bootstrap-system-${version}.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
        sha256 = "1l67w9rysrlsg2i0r210qxxn37h2969ba9lx7pp3ywlnikvi98m8";
      })
    ];

    configureFlags = [
      "--disable-sanity-checks"
      "--enable-static-nss"
      "--without-__thread"
      "--without-cvs"
      "--without-gd"
      "--without-tls"
    ];

    gcc = gcc2-mes;
    binutils = binutils-mes;
    CC = "gcc -D MES_BOOTSTRAP=1 -D BOOTSTRAP_GLIBC=1 -L $(pwd)";
    CPP = "gcc -E -D MES_BOOTSTRAP=1 -D BOOTSTRAP_GLIBC=1";
  };

  # FIXME: requires GCC 4
  # glibc216 = buildGlibc rec {
  #   version = "2.16.0";
  #   src = fetchurl {
  #     url = "mirror://gnu/glibc/glibc-${version}.tar.gz";
  #     sha256 = "0vlz4x6cgz7h54qq4528q526qlhnsjzbsvgc4iizn76cb0bfanx7";
  #   };

  #   patches = [
  #     # This patch enables building glibc-2.16.0 using TCC and GNU Make 4.x and Mes C Library.
  #     # * Makefile: Do not link with (non-existent) libgc_eh.
  #     # * Makefile: Add SHELL variable, ready for substitution, export it.
  #     # * Makefile: Do not build or assume librpc_compat_pic.
  #     # * Makefile: Do not build libmesusage.
  #     # * gen-as-const: Always add preamble.
  #     # * [BOOTSTRAP_GLIBC]: Really disable rpc.
  #     (fetchurl {
  #       url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/glibc-boot-${version}.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
  #       sha256 = "120fmh4bwpaklrkkspg6p4jqwprh6xysbc4gxhilg4pmzwjivrix";
  #     })
  #     # We want to allow builds in chroots that lack /bin/sh.  Thus, system(3)
  #     # and popen(3) need to be tweaked to use the right shell.  For the bootstrap
  #     # glibc, we just use whatever `sh' can be found in $PATH.  The final glibc
  #     # instead uses the hard-coded absolute file name of `bash'.
  #     (fetchurl {
  #       url = "https://git.savannah.gnu.org/cgit/guix.git/plain/gnu/packages/patches/glibc-bootstrap-system-${version}.patch?id=50249cab3a98839ade2433456fe618acc6f804a5";
  #       sha256 = "1zshpfbg16b5dca3v5p02sp990lzcm90r2ww71i7jjcxkckg2706";
  #     })
  #   ];

  #   configureFlags = [
  #     "--disable-obsolete-rpc"
  #     "--enable-static-nss"
  #     "--with-pthread"
  #     "--without-cvs"
  #     "--without-gd"
  #     "--enable-add-ons=nptl"
  #   ];

  #   gcc = gcc2;
  #   inherit binutils;
  #   CC = "gcc -D BOOTSTRAP_GLIBC=1 -L $(pwd)";
  #   CPP = "gcc -E -D BOOTSTRAP_GLIBC=1";
  # };
}
