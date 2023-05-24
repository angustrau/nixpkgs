{ lib
, config
, buildPlatform
, hostPlatform
, cheatingPkgs
}:

lib.makeScope
  # Prevent using top-level attrs to protect against introducing dependency on
  # non-bootstrap packages by mistake. Any top-level inputs must be explicitly
  # declared here.
  (extra: lib.callPackageWith ({ inherit lib config buildPlatform hostPlatform cheatingPkgs; } // extra))
  (self: with self; {
    inherit (callPackage ./utils.nix { }) fetchurl derivationWithMeta writeTextFile writeText runCommand;

    inherit (callPackage ./stage0-posix { }) kaem m2libc mescc-tools mescc-tools-extra;

    mes = callPackage ./mes { };
    mes-libc = callPackage ./mes/libc.nix { };

    ln-boot = callPackage ./ln-boot { };

    tinycc-bootstrappable = callPackage ./tinycc/bootstrappable.nix { };
    tinycc-mes = callPackage ./tinycc/mes.nix { };

    gnupatch = callPackage ./gnupatch { tinycc = tinycc-mes; };

    gnumake = callPackage ./gnumake { tinycc = tinycc-mes; };

    coreutils = callPackage ./coreutils { tinycc = tinycc-mes; };

    bash_2_05 = callPackage ./bash/2.nix { tinycc = tinycc-mes; };

    gnused-boot = callPackage ./gnused { tinycc = tinycc-mes; bash = bash_2_05; bootstrap = true; };
    gnused = callPackage ./gnused { tinycc = tinycc-mes; bash = bash_2_05; gnused = gnused-boot; gnugrep = gnugrep-boot; };

    gnugrep-boot = callPackage ./gnugrep { tinycc = tinycc-mes; bash = bash_2_05; bootstrap = true; };
    gnugrep = callPackage ./gnugrep { tinycc = tinycc-mes; bash = bash_2_05; gnugrep = gnugrep-boot; };

    gawk = callPackage ./gawk { tinycc = tinycc-mes; bash = bash_2_05; };

    tinycc = callPackage ./tinycc { bash = bash_2_05; };

    gawk_3_1 = callPackage ./gawk/3.1.nix { tinycc = tinycc-mes; bash = bash_2_05; };

    gawk_3_1_8 = callPackage ./gawk/3.1.8.nix { tinycc = tinycc-mes; bash = bash_2_05; gawk = gawk_3_1; gnused = gnused_4_2; };

    gnused_4_2 = callPackage ./gnused/4.2.nix { tinycc = tinycc-mes; bash = bash_2_05; };

    gnused_4 = cheatingPkgs.callPackage ./gnused/cheating-4-2.nix { };

    binutils_2_14 = callPackage ./binutils/2.14.nix { tinycc = tinycc-mes; bash = bash_2_05; };

    binutils_2_20 = callPackage ./binutils/2.20.nix { tinycc = tinycc-mes; bash = bash_2_05; };

    gzip = callPackage ./gzip { tinycc = tinycc-mes; };

    heirloom-devtools = callPackage ./heirloom-devtools { tinycc = tinycc-mes; };

    gnutar = callPackage ./gnutar { tinycc = tinycc-mes; };

    flex-boot = callPackage ./flex {
      bash = bash_2_05;
      tinycc = tinycc-mes;
      bootstrap = true;
    };

    flex = callPackage ./flex {
      bash = bash_2_05;
      tinycc = tinycc-mes;
      bootstrap = false;
      flex = flex-boot;
    };

    musl = callPackage ./musl {
      bash = bash_2_05;
      tinycc = tinycc-mes;
    };

    gnum4 = callPackage ./gnum4 { tinycc = tinycc-mes; };

    bash = callPackage ./bash { tinycc = tinycc-mes; };

    inherit (callPackage ./stdenv {
      fetchurlBoot = fetchurl;
      localSystem = stdenv.buildPlatform;
    }) stdenvStage1;

    hello = stdenvStage1.mkDerivation {
      name = "hello";

      src = fetchurl {
        url = "mirror://gnu/hello/hello-2.12.1.tar.gz";
        sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
      };
    };
  })
