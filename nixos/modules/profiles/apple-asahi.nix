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
    # https://github.com/AsahiLinux/asahi-scripts/blob/6f675aed77a9c7417ece2ae8ed554268608125a7/initcpio/install/asahi
    boot.initrd.availableKernelModules = lib.mkForce [ "apple-mailbox" "nvme_apple" "pinctrl-apple-gpio" "macsmc" "macsmc-rtkit" "i2c-apple" "tps6598x" "apple-dart" "dwc3" "dwc3-of-simple" "xhci-pci" "pcie-apple" "gpio_macsmc" "spi-apple" "spi-hid-apple" "spi-hid-apple-of" "rtc-macsmc" "simple-mfd-spmi" "spmi-apple-controller" "nvmem_spmi_mfd" ];

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
