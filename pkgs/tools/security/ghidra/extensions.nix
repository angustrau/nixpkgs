{ lib, pkgs }:

lib.makeScope pkgs.newScope (self: with self; {

  ghostrings = callPackage ./extensions/ghostrings { };

} // {
  inherit (callPackage ./build-extension.nix { }) buildGhidraExtension buildGhidraScripts;
})
