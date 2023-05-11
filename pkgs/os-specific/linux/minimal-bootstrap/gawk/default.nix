{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, tinycc
, gnumake
, gnused
, gnugrep
, coreutils
}:
let
  pname = "gawk";
  # >=3.1.x introduces gettext
  version = "3.0.6";

  src = fetchurl {
    url = "mirror://gnu/gawk/gawk-${version}.tar.gz";
    sha256 = "1z4bibjm7ldvjwq3hmyifyb429rs2d9bdwkvs0r171vv1khpdwmb";
  };
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
    gnused
    gnugrep
    coreutils
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
  cd gawk-${version}

  # Patch
  # for reproducibility don't generate datestamp
  sed -i -e "s|date > stamp-h||g" configure
  # mes-libc doesn't require linking with -lm
  sed -i -e "s|-lm||g" Makefile.in

  # Configure
  export CONFIG_SHELL=bash
  export SHELL=bash
  export CC="tcc -static"
  export LD="tcc"
  export ac_cv_func_getpgrp_void=yes
  export ac_cv_func_tzset=yes
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
