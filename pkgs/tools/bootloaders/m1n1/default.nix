{ stdenv
, lib
, fetchFromGitHub
, dtc
, imagemagick
}:

stdenv.mkDerivation rec {
  pname = "m1n1";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = pname;
    rev = "v${version}";
    sha256 = "fW1r0/k31wO89ob4Be27CrATkf4JnWkJGN8sgH3Ulj4=";
    fetchSubmodules = true;
  };

  makeFlags = [
    "ARCH="
    "RELEASE=1"
  ];

  nativeBuildInputs = [
    dtc
    imagemagick
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp build/m1n1.bin $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Asahi Linux bootloader";
    homepage = "https://github.com/AsahiLinux/m1n1";
    maintainers = with maintainers; [ emilytrau arianvp ];
    # Building under aarch64-darwin is unmaintained but likely possible
    platforms = [ "aarch64-linux" ];
    license = licenses.mit;
  };
}
