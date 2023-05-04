{ lib
, buildPlatform
, hostPlatform
, runCommand
, fetchurl
, tinycc
, gnumake
, gnused
, gnugrep
, coreutils
, bash
}:
let
  pname = "gawk";
  version = "3.0.0";

  src = fetchurl {
    url = "mirror://gnu/gawk/gawk-${version}.tar.gz";
    sha256 = "087s7vpc8zawn3l7bwv9f44bf59rc398hvaiid63klw6fkbvabr3";
  };
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
    gnused
    gnugrep
    coreutils
    bash
  ];

  meta = with lib; {
    description = "GNU implementation of the Awk programming language";
    homepage = "https://www.gnu.org/software/gawk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output gawk.tar
  untar --file gawk.tar
  rm gawk.tar
  build=''${NIX_BUILD_TOP}/gawk-${version}
  cd ''${build}

  # Patch
  sed -i -e "s|date > stamp-h||g" configure
  sed -i -e "s|-lm||g" Makefile.in

  # Configure
  CONFIG_SHELL=bash
  SHELL=bash
  CC="tcc -static"
  LD="tcc"
  ac_cv_func_getpgrp_void=yes
  ac_cv_func_tzset=yes
  bash ./configure \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --disable-nls \
    --prefix=''${out}

  # Build
  make gawk

  # Check
  ./gawk --version

  # Install
  install -D gawk ''${out}/bin/gawk
  ln -s gawk ''${out}/bin/awk
''
