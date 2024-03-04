{ lib
, stdenv
, fetchFromGitHub
, fetchgit
, substituteAll
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "svim";
  version = "1.0.11";

  # src = fetchFromGitHub {
  #   owner = "FelixKratz";
  #   repo = "SketchyVim";
  #   rev = "v${finalAttrs.version}";
  #
  #   fetchSubmodules = true;
  # };
  src = fetchgit {
    url = "ssh://git@github.com:FelixKratz/SketchyVim.git";
    rev = "v${finalAttrs.version}";
    # hash = "sha256-+0HSHmyE9FV8xk7pjY39RBXTEv/56nqRxnaoPURr4Gw=";
    fetchSubmodules = true;
  };

  patches = [
    # Add fallback path to blacklist file if not found in $HOME
    (substituteAll {
      src = ./default-blacklist.patch;
      PREFIX = placeholder "out";
    })
  ];

  # installPhase = ''
  #   runHook preInstall

  #   install -D bundle/svim $out/bin/svim
  #   install -D bundle/svim.sh $out/share/svim/svim.sh
  #   cp bundle/svimrc $out/share/svim/svimrc
  #   cp bundle/blacklist $out/share/svim/blacklist

  #   runHook postInstall
  # '';

  meta = with lib; {
    description = "Adds all vim moves and modes to macOS text fields";
    homepage = "https://github.com/FelixKratz/SketchyVim";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.darwin;
    mainProgram = "svim";
  };
})
