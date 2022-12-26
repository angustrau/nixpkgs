{ lib
, fetchFromGitHub
, buildGhidraExtension
}:

buildGhidraExtension rec {
  pname = "ghostrings";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "nccgroup";
    repo = pname;
    rev = "v${version}"; 
    sha256 = "gfYLQkBbEvhjEaXYZFhlB7ieaFEOBtYOsxpL3PL36Fk=";
  };

  meta = with lib; {
    description = "Ghidra scripts for recovering string definitions in Go binaries";
    homepage = "https://github.com/nccgroup/ghostrings";
    license = licenses.gpl3Plus;
  };
}
