{ lib
, fetchFromGitHub
, buildLinux
# Enable 16K page size. Provides up to a 20% performance increase.
, is16K ? true
, ...
} @ args:

buildLinux (args // rec {
  # Tracking branch: https://github.com/AsahiLinux/linux/tree/asahi
  version = "5.17.0-rc7-asahi-next-20220310";
  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "linux";
    rev = "00e23945f258f06ed0cb0dd9ea44272cbdfc7346";
    sha256 = "oHEy0QS7RkhR9Av68rqAAmR8kXi0ZR4yot0uGWfJOzw=";
  };

  extraConfig = lib.optionalString is16K ''
    CONFIG_ARM64_4K_PAGES n
    CONFIG_ARM64_16K_PAGES y
    CONFIG_ARM64_64K_PAGES n
  '';

  modDirVersion = version;
  extraMeta.branch = lib.versions.majorMinor version;
} // (args.argsOverride or { }))
