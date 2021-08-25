{ stdenv, lib, fetchurl, fetchpatch, file, pciutils, libx86, lzo }:

stdenv.mkDerivation rec {
  pname = "uswsusp";
  version = "1.0";

  src = fetchurl {
    url = "mirror://sourceforge/suspend/suspend-utils-${version}.tar.bz2";
    sha256 = "0206ba6332860b6da57acc79cc0f8604150ef0835ff9633fd42d59d181a6c85d";
  };

  patches = [
    (fetchpatch {
      url = "https://aur.archlinux.org/cgit/aur.git/plain/no-inline.patch?h=uswsusp-git";
      sha256 = "03bnl79drzlyl78i0qrr7x0vfrf6zswvisb7lbw981xfsdw3qc7w";
    })
  ];

  nativeBuildInputs = [ file ];

  buildInputs = [ pciutils libx86 lzo ];

  hardeningDisable = [ "format" ];

  configureFlags = [
    "--enable-compress"
    "--enable-threads"
    "--disable-resume-static"
  ];
}
