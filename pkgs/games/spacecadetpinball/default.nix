{ stdenv, fetchurl, fetchFromGitHub, unzip, cmake, SDL2, SDL2_mixer }:
let
  # Get assets from https://archive.org/details/3d-pinball-space-cadet_202103
  resources = fetchurl {
    name = "3DPinballSpaceCadet.zip";
    url = "https://archive.org/download/3d-pinball-space-cadet_202103/3D%20Pinball%20Space%20Cadet.zip";
    sha256 = "0vn0a63pfffkfpd0mxl4r31r01g1rkil7rqh2c1ic42hir9j23sc";
  };
in
stdenv.mkDerivation rec {
  pname = "SpaceCadetPinball";
  version = "unstable-2021-10-14";

  src = fetchFromGitHub {
    owner = "k4zmu2a";
    repo = pname;
    rev = "5947727f8031db306126c49b9e4b6043da13ea22";
    sha256 = "kNNEu4XiOYRGSvucOeZSGe03O2w24rrs0Lrf5irTmyQ=";
  };

  nativeBuildInputs = [ unzip cmake SDL2 SDL2_mixer ];

  installPhase = ''
    runHook preInstall
    install -D ../bin/SpaceCadetPinball $out/bin/SpaceCadetPinball
    unzip -j ${resources} -d $out/bin
    runHook postInstall
  '';
}
