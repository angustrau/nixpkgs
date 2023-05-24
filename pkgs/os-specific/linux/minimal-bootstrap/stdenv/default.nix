{ lib
, config
, localSystem
, fetchurlBoot
, coreutils
, gnumake
, gnupatch
, gnused
, gnutar
, gnugrep
, gzip
, heirloom-devtools
, bash_2
, tinycc-mes
}:
let
  mkStdenv = attrs:
    import ../../../../stdenv/generic ({
      name = "minimal-bootstrap-stdenv-${attrs.name}";
      buildPlatform = localSystem;
      hostPlatform = localSystem;
      targetPlatform = localSystem;
      inherit config fetchurlBoot;
    } // (builtins.removeAttrs attrs [ "name" ]));

  ccWrapper = attrs:
    import ../../../../build-support/cc-wrapper ({
      name = "minimal-bootstrap-cc-wrapper-${attrs.name}";
      inherit lib coreutils gnugrep;
      stdenvNoCC = stdenvStage0;
    } // (builtins.removeAttrs attrs [ "name" ]));

  # Build a dummy stdenv with no compiler or working fetchurl. This is
  # because we need a stdenv to build the compiler wrapper and fetchurl.
  stdenvStage0 = mkStdenv {
    name = "stage0";
    shell = "${bash_2}/bin/bash";
    setupScript = ./minimal-setup.sh;
    initialPath = [ coreutils ];
    cc = null;
  };
in
rec {
  stdenvStage1 = mkStdenv rec {
    name = "stage1";
    shell = "${bash_2}/bin/bash";
    setupScript = ./minimal-setup.sh;
    initialPath = [
      coreutils
      gnumake
      gnupatch
      gnused
      gnugrep
      gnutar
      gzip
      heirloom-devtools
    ];
    cc = ccWrapper rec {
      inherit name;
      cc = tinycc-mes;
      libc = cc;
      bintools = cc // {
        libc_bin = libc;
        libc_dev = libc;
        libc_lib = libc;
        nativeTools = false;
        nativeLibc = false;
        nativePrefix = "";
      };
      nativeTools = false;
      nativeLibc = false;
    };
  };
}
