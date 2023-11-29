{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, libiconv
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simdutf";
  version = "4.0.5";

  src = fetchFromGitHub {
    owner = "simdutf";
    repo = "simdutf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HNTVo/uB7UTCy5VVdmf6vka9T+htra7Vk7NF4hByGP4=";
  };

  postPatch = ''
    substituteInPlace tools/CMakeLists.txt --replace "-Wl,--gc-sections" ""
  '';

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    libiconv
  ];

  meta = with lib; {
    description = "Unicode validation and transcoding at billions of characters per second";
    homepage = "https://simdutf.github.io/simdutf/";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.all;
    mainProgram = "sutf";
  };
})
