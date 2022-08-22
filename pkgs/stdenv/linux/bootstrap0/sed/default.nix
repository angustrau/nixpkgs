{ fetchurl, runKaem, tcc, gnumake }:
let
  version = "4.0.9";
  src = fetchurl {
    url = "mirror://gnu/sed/sed-${version}.tar.gz";
    sha256 = "0006gk1dw2582xsvgx6y6rzs9zw8b36rhafjwm288zqqji3qfrf3";
  };
in
runKaem {
  name = "sed-${version}";
  buildInputs = [ tcc gnumake ];
  scriptText = ''
    ungz --file ${src} --output sed.tar
    untar --file sed.tar
    cd sed-${version}

    catm config.h
    make -f ${./Makefile} LIBC=mes
    make -f ${./Makefile} PREFIX=''${out} install
  '';
}
