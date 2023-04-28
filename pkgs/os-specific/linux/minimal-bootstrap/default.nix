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

  nyacc = callPackage ./mes/nyacc.nix { };
  mes = callPackage ./mes { };

  tinycc-with-mes-libc = callPackage ./tinycc/default.nix { };

  gnupatch = callPackage ./gnupatch { tinycc = tinycc-with-mes-libc; };

  gnumake = callPackage ./gnumake { tinycc = tinycc-with-mes-libc; };

  gnused = callPackage ./gnused { tinycc = tinycc-with-mes-libc; };

  gzip = callPackage ./gzip { tinycc = tinycc-with-mes-libc; };

  coreutils = callPackage ./coreutils { tinycc = tinycc-with-mes-libc; };

  heirloom-devtools = callPackage ./heirloom-devtools { tinycc = tinycc-with-mes-libc; };

  bash_2 = callPackage ./bash/2.nix { tinycc = tinycc-with-mes-libc; };

  gnutar = callPackage ./gnutar { tinycc = tinycc-with-mes-libc; };

  gnugrep = callPackage ./gnugrep { tinycc = tinycc-with-mes-libc; };

  flex = callPackage ./flex {
    bash = bash_2;
    tinycc = tinycc-with-mes-libc;
  };
})
