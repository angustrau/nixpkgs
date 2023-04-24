{ lib, config, stdenv, pkgs }:
let
  # localSystem = { system = "i686-linux"; };
  localSystem = stdenv.hostPlatform;
  system = localSystem.system;
  seeds = import ./seeds.nix;
  fetchurl = import ../../../build-support/fetchurl/boot.nix { inherit system; };
in
rec {
  mescc-tools = import ./stage0-posix {
    inherit lib seeds;
    inherit (localSystem) system;
  };

  runKaemScript = {
    name,
    script,
    buildInputs ? [],
    ...
  }@extraArgs: derivation (extraArgs // {
    inherit name system script;
    builder = "${mescc-tools}/bin/kaem";
    args = [
      "--verbose"
      "--strict"
      "--file"
      (builtins.toFile "run-kaem-script.kaem" ''
        set -ex
        PATH=''${BUILD_INPUTS_PATH}:
        LIBRARY_PATH=''${BUILD_INPUTS_LIB}:
        unset BUILD_INPUTS_PATH
        unset BUILD_INPUTS_LIB
        exec kaem --verbose --strict --file ''${script}
      '')
      "--"
    ];
    BUILD_INPUTS_PATH = lib.makeBinPath (buildInputs ++ [ mescc-tools ]);
    BUILD_INPUTS_LIB = lib.makeLibraryPath buildInputs;
  });

  writeTextFile = {
    name,
    text,
    executable ? false,
    prefix ? ""
  }: runKaemScript {
    inherit name text executable prefix;
    passAsFile = [ "text" ];
    preferLocalBuild = true;
    allowSubstitutes = false;
    script = builtins.toFile "writeTextFileLoader" ''
      if match x''${prefix} x; then
        dest=''${out}
      else
        mkdir -p ''${out}/''${prefix}
        dest=''${out}/''${prefix}''${name}
      fi
      cp ''${textPath} ''${dest}
      if match x''${executable} x1; then
        chmod 555 ''${dest}
      fi
    '';
  };

  writeText = name: text: writeTextFile { inherit name text; };

  runKaem = {
    name,
    scriptText,
    buildInputs ? [],
    ...
  }@extraArgs: runKaemScript (extraArgs // {
    inherit name buildInputs;
    script = writeText "${name}.kaem" (''
      set -ex
    '' + scriptText);
  });

  kaemWrapper = runKaem {
    name = "kaem-wrapper";
    scriptText = ''
      M2LIBC_PATH=${mescc-tools.M2libc}
      replace --file ${./kaem-wrapper.c} --output kaem-wrapper.c --match-on @kaem@ --replace-with "${mescc-tools}/bin/kaem"
      M2-Mesoplanet -f kaem-wrapper.c -o ''${out}
    '';
  };

  writeScriptBin = name: text: writeTextFile {
    inherit name;
    text = ''
      #!${kaemWrapper}
      PATH=${mescc-tools}/bin:''${PATH}
    '' + text;
    executable = true;
    prefix = "bin/";
  };

  mescc = import ./mescc { inherit system fetchurl runKaem runKaemScript; };

  tcc = import ./tcc { inherit lib system runKaem mescc; };

  gnumake = import ./gnumake { inherit fetchurl runKaem tcc; };

  sed = import ./sed { inherit fetchurl runKaem tcc gnumake; };

  patch = import ./patch { inherit fetchurl runKaem tcc gnumake sed; };

  coreutils = import ./coreutils { inherit fetchurl runKaem tcc gnumake sed patch; };

  # binutils = import ./binutils { inherit fetchurl stdenvNoCC tcc; };

  musl0 = import ./musl { inherit fetchurl runKaem tcc gnumake sed coreutils; };

  musl-tcc0 = import ./tcc/musl.nix { inherit runKaem tcc; musl = musl0; };

  musl = import ./musl { inherit fetchurl runKaem gnumake sed coreutils; tcc = musl-tcc0; };

  musl-tcc = import ./tcc/musl.nix { inherit runKaem musl; tcc = musl-tcc0; };

  bootstrap-from-tcc = import ./bootstrap-from-tcc { inherit system fetchurl runKaem coreutils sed; tcc-seed = musl-tcc; musl-seed = musl; };
  inherit (bootstrap-from-tcc.stage1) protomusl protobusybox;

  runAsh = {
    name,
    scriptText,
    buildInputs ? [],
    ...
  }@extraArgs: derivation (extraArgs // {
    inherit name system;
    builder = "${protobusybox}/bin/ash";
    args = [
      "-uexc"
      (''
        set -ex
        PATH=''${BUILD_INPUTS_PATH}:
        LIBRARY_PATH=''${BUILD_INPUTS_LIB}:
        unset BUILD_INPUTS_PATH
        unset BUILD_INPUTS_LIB

        ${scriptText}
      '')
    ];
    BUILD_INPUTS_PATH = lib.makeBinPath (buildInputs ++ [ protobusybox ]);
    BUILD_INPUTS_LIB = lib.makeLibraryPath buildInputs;
  });

  bash = import ./bash { inherit fetchurl runAsh musl-tcc gnumake patch; };

  stdenv0NoCC = import ../../generic {
    name = "bootstrap0-stdenv0NoCC";
    initialPath = [ bash protobusybox ];
    cc = null;
    shell = "${bash}/bin/bash";
    # setupScript = builtins.toFile "test" "";
    fetchurlBoot = fetchurl;
    buildPlatform = localSystem;
    hostPlatform = localSystem;
    targetPlatform = localSystem;
    inherit config;
  };

  test = stdenv0NoCC.mkDerivation rec {
    name = "test";
  };
  # test = derivation {
  #   inherit system;
  #   name = "test";
  #   builder = "${bash}/bin/bash";
  #   # builder = "/bin/sh";
  #   # builder = "${/nix/store/pililvnv2kvpmksa49r4qa8as56dryg6-bash-5.1-p16}/bin/bash";
  #   initialPath = [ bash protobusybox ];
  #   # args = ["-e" /home/emilytrau/code/nixpkgs-bootstrap0/pkgs/stdenv/generic/builder.sh ];
  #   args = ["-e" (builtins.toFile "test" ''
  #     echo ''${PATH}
  #   '')];
  # };

  stdenv0 = stdenv0NoCC.override {
    name = "bootstrap0-stdenv0";
    cc = lib.makeOverridable (import ../../../build-support/cc-wrapper) {
      name = "bootstrap0-gcc-wrapper";
      nativeTools = false;
      nativeLibc = false;
      cc = bootstrap-from-tcc.static-gnugcc4-c;
      bintools = (import ../../../build-support/bintools-wrapper) {
        name = "bootstrap0-bintools-wrapper";
        inherit lib;
        stdenvNoCC = stdenv0NoCC;
        nativeTools = false;
        nativeLibc = false;
        libc = protomusl;
        bintools = bootstrap-from-tcc.static-binutils;
        coreutils = protobusybox;
        gnugrep = protobusybox;
      };
      isGNU = true;
      libc = protomusl;
      inherit lib;
      coreutils = protobusybox;
      gnugrep = protobusybox;
      stdenvNoCC = stdenv0NoCC;
    };
  };
}
