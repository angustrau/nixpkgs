{ stdenv
, lib
, fetchurl
, fetchFromGitHub
, linux
, linuxKernel
, ...
}:

linuxKernel.manualConfig rec {
  inherit stdenv lib;

  # Tracking branch: https://github.com/AsahiLinux/linux/tree/asahi
  version = "5.17.0-rc7-asahi-next-20220310-ARCH";
  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "linux";
    rev = "00e23945f258f06ed0cb0dd9ea44272cbdfc7346";
    sha256 = "oHEy0QS7RkhR9Av68rqAAmR8kXi0ZR4yot0uGWfJOzw=";
  };

  # Use kernel config from the Asahi Linux distro
  # This config enables 16K page sizes
  configfile = fetchurl {
    # Tracking https://github.com/AsahiLinux/PKGBUILDs/blob/main/linux-asahi/config
    url = "https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/5dd2336e765ba3dd34b5658e553af423aef87d97/linux-asahi/config";
    sha256 = "0x19mwnsz0xca9xlxvh9nrk09sgnvq68n9lm6v3g244nhwha8pmh";
  };
  allowImportFromDerivation = true;
}
