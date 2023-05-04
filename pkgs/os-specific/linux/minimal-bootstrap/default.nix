{ lib
, config
, buildPlatform
, hostPlatform
}:

lib.makeScope
  # Prevent using top-level attrs to protect against introducing dependency on
  # non-bootstrap packages by mistake. Any top-level inputs must be explicitly
  # declared here.
  (extra: lib.callPackageWith ({ inherit lib config buildPlatform hostPlatform; } // extra))
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

    gnused = callPackage ./gnused { tinycc = tinycc-mes; };

    gzip = callPackage ./gzip { tinycc = tinycc-mes; };

    coreutils = callPackage ./coreutils { tinycc = tinycc-mes; };

    heirloom-devtools = callPackage ./heirloom-devtools { tinycc = tinycc-mes; };

    bash_2_05 = callPackage ./bash/2.nix { tinycc = tinycc-mes; };

    gnutar = callPackage ./gnutar { tinycc = tinycc-mes; };

    gnugrep = callPackage ./gnugrep { tinycc = tinycc-mes; };

    gawk = callPackage ./gawk { tinycc = tinycc-mes; };

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
  })
