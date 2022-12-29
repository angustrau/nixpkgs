{ lib
, fetchFromGitHub
, buildGhidraScripts
, curl
}:

buildGhidraScripts rec {
  pname = "g3po";
  version = "unstable-2022-12-22";

  src = fetchFromGitHub {
    owner = "tenable";
    repo = "ghidra_tools";
    sparseCheckout = [ "g3po" ];
    rev = "f1bc558987a86292f097dba05e82c83b76286b24"; 
    sha256 = "sha256-/tuBk3PXMsL1Gj+KGLdDJZNwp9N8faocoy6UPjpCQyU=";
  };

  postPatch = ''
    # Replace subprocesses with store versions
    cd g3po
    substituteInPlace g3po.py --replace '"curl"' '"${curl}/bin/curl"'
  '';

  meta = with lib; {
    description = "Query an OpenAI large language model for explanatory comments on decompiled functions";
    homepage = "https://github.com/tenable/ghidra_tools";
    license = licenses.mit;
    maintainers = with maintainers; [ josephsurin ];
  };
}
