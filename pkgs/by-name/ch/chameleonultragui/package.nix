{ lib
, flutter
, fetchFromGitHub
}:

flutter.buildFlutterApplication rec {
  pname = "chameleonultragui";
  version = "0-unstable-2024-04-25";

  src = fetchFromGitHub {
    owner = "GameTec-live";
    repo = "ChameleonUltraGUI";
    rev = "bc6e42d34a8f76448d61f67f4c27927b0ca39e56";
    hash = "sha256-EVHHgyh/HiWH4rb55m8xhVUYFUWT71hJei5iMfnYjPg=";
  };

  sourceRoot = "${src.name}/chameleonultragui";

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = {
    usb_serial = "sha256-cW5pAS8rVJYPtsGobYEV/ywvjU7D/FjZM0uM8VH7Cug=";
  };

  meta = {
    description = "GUI for the Chameleon Ultra";
    homepage = "https://github.com/GameTec-live/ChameleonUltraGUI";
    license = lib.licenses.gpl3Only;
    mainProgram = "chameleonultragui";
    maintainers = with lib.maintainers; [ emilytrau ];
  };
}
