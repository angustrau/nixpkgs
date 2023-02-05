{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "valijson";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "tristanpenman";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "VwgAJ2mMbERokRufGKfcqtM6X6M2B+EBiVlNLjq6qWs=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "Header-only C++ library for JSON Schema validation";
    homepage = "https://github.com/tristanpenman/valijson";
    license = licenses.bsd2;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.all;
  };
}
