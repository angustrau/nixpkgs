{ lib, buildPythonPackage, fetchPypi
, protobuf
, pyobjc
, websockets
}:

buildPythonPackage rec {
  pname = "iterm2";
  version = "1.29";

  src = fetchPypi {
    inherit pname version;
    sha256 = "8245562ed713fd473520f81361cdc1b15835920e1ceb7d588678cd153e77c2b6";
  };

  propagatedBuildInputs = [ protobuf pyobjc websockets ];

  # No tests are available
  doCheck = false;

  pythonImportsCheck = [ "iterm2" ];

  meta = with lib; {
    description = "Python interface to iTerm2's scripting API";
    homepage = "https://github.com/gnachman/iTerm2";
    license = licenses.gpl2;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ jeremyschlatter ];
  };
}
