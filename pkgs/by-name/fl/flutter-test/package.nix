{ lib
, stdenv
, flutter
, cocoapods
, git
, xcbuild
, rsync
, swift
, swiftPackages
, xib2nib
}:

flutter.buildFlutterApplication {
  pname = "flutter-test";
  version = "0-unstable-2024-04-25";

  src = /Users/emilytrau/Downloads/flutter-test/test_project;

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  nativeBuildInputs = [
    cocoapods
    git
    xcbuild
    rsync
    swift
    xib2nib
  ];

  preConfigure = ''
    export HOME=$(mktemp -d)
    git config --global --add safe.directory '*'
    export ARCHS=arm64
    export SWIFT_LIBRARY_PATH="${swift.swift.lib}/${swift.swiftModuleSubdir}"
  '';

  buildInputs = [
    swiftPackages.apple_sdk.frameworks.Cocoa
    swiftPackages.apple_sdk.frameworks.CoreMedia
  ];

  # flutterBuildFlags = [
  #   "--dart-define"
  #   "DarwinArchs=arm64"
  # ];

  meta = {
    description = "GUI for the Chameleon Ultra";
    homepage = "https://github.com/GameTec-live/ChameleonUltraGUI";
    license = lib.licenses.gpl3Only;
    mainProgram = "chameleonultragui";
    maintainers = with lib.maintainers; [ emilytrau ];
  };
}
