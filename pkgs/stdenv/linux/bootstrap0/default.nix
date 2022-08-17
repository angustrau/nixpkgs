{ lib }:
let
  localSystem = { system = "i686-linux"; };
  seeds = import ./seeds.nix;
in
{
  stage0-posix = import ./stage0-posix {
    inherit lib seeds;
    inherit (localSystem) system;
  };
}
