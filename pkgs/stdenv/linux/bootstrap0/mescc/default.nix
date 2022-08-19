{ system, fetchurl, runKaemScript }:
let
  mesVersion = "0.24";
  mesSrc = fetchurl {
    url = "mirror://gnu/mes/mes-${mesVersion}.tar.gz";
    sha256 = "00lrpm4x5qg0l840zhbf9mr67mqhp8gljcl24j5dy0y109gf32w2";
  };
  mesPrefix = builtins.fetchTarball {
    url = "https://ftp.gnu.org/gnu/mes/mes-${mesVersion}.tar.gz";
    sha256 = "11gkf9j31z59wswp9lbgvncs6b4ky1wv4c21n2sl70pjiisk19xr";
  };

  nyaccVersion = "1.00.2";
  nyaccPrefix = builtins.fetchTarball {
    url = "http://download.savannah.nongnu.org/releases/nyacc/nyacc-${nyaccVersion}.tar.gz";
    sha256 = "06rg6pn4k8smyydwls1abc9h702cri3z65ac9gvc4rxxklpynslk";
  };

  env = ({
    i686-linux = {
      mes_cpu = "x86";
      stage0_cpu = "x86";
    };
  }).${system};

  mescc-unwrapped = runKaemScript {
    name = "mescc-${mesVersion}";
    script = ./kaem.run;

    inherit (env) mes_cpu stage0_cpu;
    MES_VERSION = mesVersion;
    MES_PKG = mesSrc;
    NYACC_PREFIX = nyaccPrefix;

    config_h = ./config.h;
  };

  mesccScript = ''
    MES_ARENA=20000000
    MES_MAX_ARENA=20000000
    MES_STACK=6000000
    MES_PREFIX=${mesPrefix}
    GUILE_LOAD_PATH=''${MES_PREFIX}/mes/module:''${MES_PREFIX}/module:${nyaccPrefix}/module

    alias mescc="${mescc-unwrapped}/bin/mes -e main ${mescc-unwrapped}/bin/mescc.scm -L ${mescc-unwrapped}/lib -I ${mescc-unwrapped}/include"
  '';
in
{
  inherit mescc-unwrapped mesccScript;
}
