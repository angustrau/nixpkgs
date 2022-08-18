{ lib }:
let
  localSystem = { system = "i686-linux"; };
  system = localSystem.system;
  seeds = import ./seeds.nix;
  fetchurl = import ../../../build-support/fetchurl/boot.nix { inherit system; };
in
rec {
  mescc-tools = import ./stage0-posix {
    inherit lib seeds;
    inherit (localSystem) system;
  };

  writeTextFileLoader = builtins.toFile "toFileLoader" ''
    ''${cp} ''${contentsPath} ''${out}
  '';
  writeTextFile = name: contents: derivation {
    inherit name system contents;
    passAsFile = [ "contents" ];
    builder = "${mescc-tools}/bin/kaem";
    args = [
      "--verbose"
      "--strict"
      "--file"
      writeTextFileLoader
    ];
    cp = "${mescc-tools}/bin/cp";
  };

  runScript = name: script: derivation {
    inherit name system;
    builder = "${mescc-tools}/bin/kaem";
    args = [
      "--verbose"
      "--strict"
      "--file"
      (writeTextFile "${name}-script" (''
        PATH=${mescc-tools}/bin
      '' + script))
    ];
  };

  ungz = input: runScript "ungz" ''
    ungz --file ${input} --output ''${out}
  '';

  untar = input: runScript "untar" ''
    mkdir ''${out}
    cd ''${out}
    untar --file ${input}
  '';

  fetchtarball = args: untar (ungz (fetchurl args));

  mescc = import ./mescc {
    inherit fetchtarball mescc-tools;
  };
}
