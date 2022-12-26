{ lib, pkgs }:

lib.makeScope pkgs.newScope (self: with self; { } // {
  inherit (callPackage ./build-extension.nix { }) buildGhidraExtension buildGhidraScripts;
})
