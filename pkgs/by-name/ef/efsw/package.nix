{ lib
, stdenv
, fetchFromGitHub
, cmake
, CoreServices
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "efsw";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "SpartanJ";
    repo = "efsw";
    rev = finalAttrs.version;
    hash = "sha256-/qoXviuWwavWvCf6yvJw0nBf7ScnGm1+u59rQ9bkBOw=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    CoreServices
  ];

  meta = with lib; {
    description = "C++ cross-platform file system watcher and notifier";
    homepage = "https://github.com/SpartanJ/efsw";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.all;
  };
})
