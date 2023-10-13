{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, gcc
, musl
, binutils
, gnumake
, gnused
, gnugrep
, gawk
, diffutils
, findutils
, gnutar
, xz
}:
let
  pname = "lndir";
  version = "1.0.4";

  src = fetchurl {
    url = "mirror://xorg/individual/util/lndir-${version}.tar.xz";
    hash = "sha256-PjQ3qdO7N3dV3QSiyQ1MAU2f6QmH/3NFC/W40WF5Xoc=";
  };
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    gcc
    musl
    binutils
    gnumake
    gnused
    gnugrep
    gawk
    diffutils
    findutils
    gnutar
    xz
  ];

  passthru.tests.get-version = result:
    bash.runCommand "${pname}-get-version-${version}" {} ''
      ${result}/bin/lndir --version
      mkdir $out
    '';

  meta = with lib; {
    description = "Utility to create a shadow directory of symbolic links to another directory tree";
    homepage = "https://gitlab.freedesktop.org/xorg/util/lndir";
    license = licenses.mitOpenGroup;
    maintainers = teams.minimal-bootstrap.members;
    platforms = platforms.unix;
  };
} ''
  # Unpack
  tar xf ${src}
  cd lndir-${version}

  # Configure
  bash ./configure \
    --prefix=$out \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    CC=musl-gcc

  # Build
  make -j $NIX_BUILD_CORES

  # Install
  make -j $NIX_BUILD_CORES install
''
