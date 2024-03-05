{ lib
, buildPythonPackage
, fetchFromGitHub
, cython
}:

buildPythonPackage rec {
  pname = "crdp";
  version = "0-unstable-2023-09-23";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "plasma-umass";
    repo = "crdp";
    rev = "1a25a6cd4abfbe5c53eccbd1c2da01d57e988a28";
    hash = "sha256-kC4xpeHo2Qharr9cFTAcmSJa0XYgVU3AHrdVfhjosG0=";
  };

  propagatedBuildInputs = [
    cython
  ];

  # No tests included
  doCheck = false;
  pythonImportsCheck = [ "crdp" ];

  meta = with lib; {
    description = "Fast Ramer-Douglas-Peucker algorithm implementation";
    homepage = "https://github.com/plasma-umass/crdp";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
  };
}
