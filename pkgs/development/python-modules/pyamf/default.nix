{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy3k
, pytestCheckHook
, cython
, defusedxml }:

buildPythonPackage rec {
  pname = "pyamf";
  version = "0.8.0";
  disabled = isPy3k;

  src = fetchFromGitHub {
    owner = "hydralabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "NBY6JjnxZisipCgEYWXiTTkVKaRvW2DuygfX34jm+XI=";
  };

  buildInputs = [
    cython
  ];

  propagatedBuildInputs = [
    defusedxml
  ];

  checkInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "pyamf" ];

  meta = with lib; {
    description = "Action Message Format (AMF) support that is compatible with the Adobe Flash Player";
    homepage = "https://github.com/hydralabs/pyamf";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
  };
}
