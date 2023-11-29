{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "backward";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "bombela";
    repo = "backward-cpp";
    rev = "v${version}";
    sha256 = "sha256-2k5PjwFxgA/2XPqJrPHxgSInM61FBEcieppBx+MAUKw=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Beautiful stack trace pretty printer for C++";
    homepage = "https://github.com/bombela/backward-cpp";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ emilytrau ];
  };
}
