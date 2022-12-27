{ lib, pkgs }:

lib.makeScope pkgs.newScope (self: with self; {

  ghidraninja-ghidra-scripts = callPackage ./extensions/ghidraninja-ghidra-scripts { };

  ghostrings = callPackage ./extensions/ghostrings { };

  gnudisassembler = callPackage ./extensions/gnudisassembler { };

  sleighdevtools = callPackage ./extensions/sleighdevtools { };

} // {
  inherit (callPackage ./build-extension.nix { }) buildGhidraExtension buildGhidraScripts;
})
