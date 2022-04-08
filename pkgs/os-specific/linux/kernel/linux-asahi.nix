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

  extraConfig = ''
    # Taken from the Debian Asahi config
    # https://git.zerfleddert.de/cgi-bin/gitweb.cgi/m1-debian/blob/4f72d3c758d6b53b2bddade260e7e72e7c6197f6:/patch_kernel_config.pl
    CONFIG_APPLE_ADMAC y
    CONFIG_APPLE_AIC y
    CONFIG_APPLE_DART y
    CONFIG_APPLE_MAILBOX y
    CONFIG_APPLE_PLATFORMS y
    CONFIG_APPLE_PMGR_PWRSTATE y
    CONFIG_APPLE_RTKIT y
    CONFIG_APPLE_SART y
    CONFIG_APPLE_SMC y
    CONFIG_APPLE_SMC_RTKIT y
    CONFIG_APPLE_WATCHDOG y
    CONFIG_ARCH_APPLE y
    CONFIG_ARM_APPLE_SOC_CPUFREQ y
    CONFIG_BRCMFMAC m
    CONFIG_BRCMFMAC_PCIE y
    CONFIG_CFG80211_WEXT y
    CONFIG_CHARGER_MACSMC y
    CONFIG_COMMON_CLK_APPLE_NCO y
    CONFIG_DRM y
    CONFIG_DRM_SIMPLEDRM y
    CONFIG_FW_LOADER_USER_HELPER n
    CONFIG_FW_LOADER_USER_HELPER_FALLBACK n
    CONFIG_GPIO_MACSMC y
    CONFIG_HID_APPLE y
    CONFIG_HID_MAGICMOUSE y
    CONFIG_I2C_APPLE y
    CONFIG_MFD_APPLE_SPMI_PMU y
    CONFIG_MMC_SDHCI_PCI y
    CONFIG_NLMON m
    CONFIG_NVMEM_SPMI_MFD y
    CONFIG_NVME_APPLE y
    CONFIG_PCIE_APPLE y
    CONFIG_PINCTRL_APPLE_GPIO y
    CONFIG_POWER_RESET_MACSMC y
    CONFIG_RTC_DRV_MACSMC y
    CONFIG_SND_SIMPLE_CARD y
    CONFIG_SND_SOC_APPLE_MCA y
    CONFIG_SND_SOC_APPLE_SILICON y
    CONFIG_SND_SOC_CS42L42 y
    CONFIG_SND_SOC_TAS2770 m
    CONFIG_SPI_APPLE y
    CONFIG_SPI_HID_APPLE_CORE y
    CONFIG_SPI_HID_APPLE_OF y
    CONFIG_SPMI_APPLE y
    CONFIG_USB_DWC3 y
    CONFIG_USB_DWC3_PCI y
    CONFIG_FB_EFI y
    CONFIG_BACKLIGHT_CLASS_DEVICE y
    CONFIG_BACKLIGHT_GPIO m
    CONFIG_TYPEC_TPS6598X y
  '' + lib.optionalString is16K ''
    CONFIG_ARM64_4K_PAGES n
    CONFIG_ARM64_16K_PAGES y
    CONFIG_ARM64_64K_PAGES n
  '';

  modDirVersion = version;
  extraMeta.branch = lib.versions.majorMinor version;
} // (args.argsOverride or { }))
