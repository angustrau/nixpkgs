{ lib, pkgs }:

lib.makeScope pkgs.newScope (self: with self; {

  g3po = callPackage ./extensions/g3po{ };

  ghidraninja-ghidra-scripts = callPackage ./extensions/ghidraninja-ghidra-scripts { };

  ghostrings = callPackage ./extensions/ghostrings { };

  gnudisassembler = callPackage ./extensions/gnudisassembler { };

  gotools = callPackage ./extensions/gotools { };

  machinelearning = callPackage ./extensions/machinelearning { };

  sleighdevtools = callPackage ./extensions/sleighdevtools { };

} // {
  inherit (callPackage ./build-extension.nix { }) buildGhidraExtension buildGhidraScripts;
})
