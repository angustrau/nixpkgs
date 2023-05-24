{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, gnutar
, tinycc-mes
}:
let
  pname = "tinycc";
  version = "0.9.27";

  src = fetchurl {
    url = "mirror://savannah/tinycc/tcc-${version}.tar.bz2";
    sha256 = "177bdhwzrnqgyrdv1dwvpd04fcxj68s5pm1dzwny6359ziway8yy";
  };
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc-mes gnutar ];

  meta = with lib; {
    description = "Small, fast, and embeddable C compiler and interpreter";
    homepage = "https://repo.or.cz/w/tinycc.git";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ emilytrau ];
    platforms = [ "i686-linux" ];
  };
} ''
  # Unpack
  unbz2 --file ${src} --output tcc.tar
  tar xf tcc.tar
  rm tcc.tar
  cd tcc-${version}

  # Patch
  sed -i -e 's|targetos=`uname`|targetos=Linux|' \
    -e '0,/cpu=/s//cpu=i386/' \
    -e 's|cc="gcc"|cc="tcc -static"|' \
    -e 's|ar="ar"|ar="tcc -ar"|' \
    -e 's|tcc_crtprefix=""|tcc_crtprefix="${tinycc-mes}/lib"|' \
    -e 's|tcc_sysincludepaths=""|tcc_sysincludepaths="${tinycc-mes}/include"|' \
    -e 's|tcc_libpaths=""|tcc_libpaths="${tinycc-mes}/lib"|' \
    -e 's|^prefix=""|prefix="${placeholder "out"}"|' \
    configure

  # Configure
  bash ./configure

  # Build
  make LIBS= CFLAGS='-DBOOTSTRAP=1 -DTCC_TARGET_I386=1 -DCONFIG_TCCBOOT=1 -DCONFIG_TCC_STATIC=1 -DCONFIG_USE_LIBGCC=1 -DTCC_MES_LIBC=1'

  # Check

  # Install
  make install
''
