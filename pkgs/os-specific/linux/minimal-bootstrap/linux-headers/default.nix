{ lib
, fetchurl
, bash
, gnumake
, gnutar
, xz
}:
let
  # WARNING: You probably don't want to use this package outside minimal-bootstrap
  #
  # We need some set of Linux kernel headers to build our bootstrap packages
  # (gcc/binutils/glibc etc.) against. As long as it compiles it is "good enough".
  # Therefore the requirement for correctness, completeness, platform-specific
  # features, and being up-to-date, are very loose.
  #
  # Rebuilding the Linux headers from source correctly is something we can defer
  # till we have access to gcc/binutils/perl. For now we can use an assembled
  # kernel header distribution and assume it's good enough.
  #
  # Sabotage Linux's kernel headers have been modified to be musl compatible
  pname = "linux-headers";
  version = "4.19.88-2";

  src = fetchurl {
    url = "https://github.com/sabotage-linux/kernel-headers/releases/download/v${version}/linux-headers-${version}.tar.xz";
    hash = "sha256-3Hq/c0SHVTZEJYo4Is/UKddGVnSeMJ8rJfCfQoLgVYg=";
  };
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    gnumake
    gnutar
    xz
  ];

  meta = with lib; {
    description = "Header files and scripts for Linux kernel";
    license = licenses.gpl2;
    maintainers = teams.minimal-bootstrap.members;
    platforms = [ "i686-linux" ];
  };
} ''
  # Unpack
  tar xf ${src}
  cd linux-headers-${version}

  # Install
  make ARCH=x86 prefix=$out install
''
