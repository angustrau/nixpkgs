{ lib
, newScope
, stdenv
}:

lib.makeScope newScope (self: with self; {
  callPackage = self.callPackage;

  fetchurl = import ../../../build-support/fetchurl/boot.nix {
    inherit (stdenv.buildPlatform) system;
  };

  inherit (callPackage ./stage0-posix { }) kaem m2libc mescc-tools mescc-tools-extra writeTextFile writeText runCommand;

  mes = callPackage ./mes { };
  inherit (mes) mes-libc;

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
})
