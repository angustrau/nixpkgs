# Common configuration for Apple Silicon hardware (Asahi Linux Project)

{ config, lib, pkgs, ... }:

let
  boot = pkgs.ubootAsahiAppleM1;

  bootFiles = {
    "m1n1/boot.bin" = if config.boot.m1n1ExtraOptions == "" then
      "${boot}/m1n1-u-boot.bin"
    else pkgs.runCommand "boot.bin" {} ''
      cat ${boot}/m1n1-u-boot.bin > $out
      echo '${config.boot.m1n1ExtraOptions}' >> $out
    '';
  };
in
{
  options.boot.m1n1ExtraOptions = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      Append extra options to the m1n1 boot binary. Might be useful for fixing
      display problems on Mac minis.
      https://github.com/AsahiLinux/m1n1/issues/159
    '';
  };

  options.boot.is16K = lib.mkOption {
    type = lib.types.path;
    description = ''
      TODO
    '';
  };

  options.boot.firwareLocation = lib.mkOption {
    type = lib.types.path;
    description = ''
      TODO
    '';
  };

  options.boot.proprietaryFirmware = lib.mkOption {
    type = lib.types.path;
    description = ''
      TODO
    '';
  };

  config = {
    # Adds terminus_font for people with HiDPI displays
    console.packages = [ pkgs.terminus_font ];

    # install m1n1 with the boot loader
    boot.loader.systemd-boot.extraFiles = bootFiles;

    # ensure the installer has m1n1 in the image
    system.extraDependencies = [ boot ];

    # U-Boot does not support EFI variables
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    # GRUB has to be installed as removable if the user chooses to use it
    boot.loader.grub = lib.mkDefault {
      version = 2;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";

      # install m1n1 with the boot loader
      extraFiles = bootFiles;
    };

    # Kernel
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_asahi_16k;

    # kernel parameters that are useful for debugging
    boot.consoleLogLevel = 7;
    boot.kernelParams = [
      "earlycon"
      "console=ttySAC0,1500000"
      "console=tty0"
      "debug"
      "boot.shell_on_fail"
      # Apple's SSDs are slow (~dozens of ms) at processing flush requests which
      # slows down programs that make a lot of fsync calls. This parameter sets
      # a delay in ms before actually flushing so that such requests can be
      # coalesced. Be warned that increasing this parameter above zero (default
      # is 1000) has the potential, though admittedly unlikely, risk of
      # UNBOUNDED data corruption in case of power loss!!!! Don't even think
      # about it on desktops!!
      "nvme_apple.flush_interval=0"
    ];

    # Kernel modules as supported by the Asahi Linux project
    # cat /proc/modules | awk '{ FS = " "; ORS=" "; print "\"" $1 "\"" }'
    boot.initrd.availableKernelModules = lib.mkForce [ "joydev" "usbhid" "des_generic" "libdes" "md4" "snd_soc_apple_silicon" "snd_soc_simple_card_utils" "macsmc_reboot" "macsmc_power" "macsmc_hid" "snd_soc_apple_mca" "snd_soc_tas2770" "snd_soc_cs42l42" "apple_soc_cpufreq" "apple_admac" "clk_apple_nco" "xhci_plat_hcd" "nls_iso8859_1" "brcmfmac" "brcmutil" "cfg80211" "tg3" "xhci_pci" "xhci_hcd" "rfkill" "ptp" "crypto_user" "fuse" "nvmem_spmi_mfd" "tps6598x" "typec" "rtc_macsmc" "simple_mfd_spmi" "regmap_spmi" "pcie_apple" "pci_host_common" "dwc3" "udc_core" "nvme_apple" "apple_sart" "apple_mailbox" "pinctrl_apple_gpio" "spmi_apple_controller" "i2c_apple" "apple_dart" ];

    # Firmware
    systemd.services.asahi-proprietary-firmware = {
      description = "Load Apple proprietary firmware blobs";
      before = [ "systemd-modules-load.service" ];
      wantedBy = [ "systemd-modules-load.service" ];
      conflicts = [ "shutdown.target" ];

      path = with pkgs; [
        gnutar
        kmod
      ];

      serviceConfig = {
        Type = "oneshot";
      };

      unitConfig = {
        DefaultDependencies = false;
        RequiresMountsFor = "/boot";
        PrivateTmp = true;
      };

      script = ''
        if [[ ! -f /boot/vendorfw/firmware.tar ]]; then
          echo "Couldn't locate vendor firmware blob" >&2
          exit 1
        fi
        mkdir -p /lib/firmware
        tar xf /boot/vendorfw/firmware.tar -C /lib/firmware
        rmmod brcmfmac || true
        modprobe brcmfmac
        echo "Loaded firmware successfully"
      '';
    };
  };
}
