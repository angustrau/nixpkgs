# To build, use:
# nix-build nixos -I nixos-config=nixos/modules/installer/cd-dvd/installation-cd-apple-m1.nix -A config.system.build.isoImage
{ pkgs, ... }:

{
  imports = [
    # ./installation-cd-graphical-plasma5.nix
    ./installation-cd-minimal.nix
    ./../../profiles/apple-asahi.nix
  ];
}
