{ lib
, fetchFromGitHub
, buildGhidraExtension
}:

buildGhidraExtension rec {
  pname = "gotools";
  version = "unstable-2021-04-12";

  src = fetchFromGitHub {
    owner = "felberj";
    repo = pname;
    rev = "c13ad798aa274242c9dd045a2de685595bee54b9"; 
    sha256 = "hHn9N0SHRfJTrnJedlFOZ9ZdhVm+XChUXlDSP1wFckg=";
  };

  meta = with lib; {
    description = "Plugin for Ghidra to assist reversing Golang binaries";
    homepage = "https://github.com/felberj/gotools";
    license = licenses.mit;
  };
}
