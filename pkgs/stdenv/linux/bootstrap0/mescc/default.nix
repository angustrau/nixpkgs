{ fetchtarball, mescc-tools }:
let
  version = "0.24";
  src = fetchtarball {
    name = "mescc-source-${version}";
    url = "mirror://gnu/mes/mes-${version}.tar.gz";
    sha256 = "00lrpm4x5qg0l840zhbf9mr67mqhp8gljcl24j5dy0y109gf32w2";
  };
in
src
