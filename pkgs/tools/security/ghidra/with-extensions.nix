{ lib
, symlinkJoin
, makeWrapper
, ghidra
, ghidra-extensions
}:

let
  allExtensions = lib.filterAttrs (n: pkg: lib.isDerivation pkg) ghidra-extensions;

  /* Make Ghidra with additional extensions
     Example:
       pkgs.ghidra.withExtensions (p: with p; [
         ghostrings
       ]);
       => /nix/store/3yn0rbnz5mbrxf0x70jbjq73wgkszr5c-ghidra-with-extensions-10.2.2
  */
  withExtensions = f: (symlinkJoin {
    name = "ghidra-with-extensions-${lib.getVersion ghidra}";
    paths = [ ghidra ] ++ (f allExtensions);
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/ghidra" \
        --set NIX_GHIDRAHOME "$out/lib/ghidra/Ghidra"
    '';
    inherit (ghidra) meta;
  });
in
  withExtensions
