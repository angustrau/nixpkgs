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
, gzip
}:
let
  pname = "gnused";
  # >=3.1.x introduces gettext
  version = "4.2";

  src = fetchurl {
    url = "mirror://gnu/sed/sed-${version}.tar.gz";
    sha256 = "10yrcxr970n7wpjhcri38lknb6k8wzy5spfn6w2na3h1zmiwsifv";
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
    gzip
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
  cp ${src} sed.tar.gz
  gunzip sed.tar.gz
  untar --file sed.tar
  rm sed.tar
  cd sed-${version}

  # Configure
  export CC="tcc -static -DHAVE_FCNTL_H"
  export LD="tcc"
  export gl_cv_socklen_t_equiv=int
  bash ./configure \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --disable-nls \
    --disable-dependency-tracking \
    --prefix=''${out}

  # Build
  make AR="tcc -ar"

  # Check
  ./sed/sed --version

  # Install
  make install
''
