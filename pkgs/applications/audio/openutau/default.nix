{ lib
, fetchFromGitHub
, buildDotnetModule
, portaudio
, libICE
, libSM
, libX11
, libXi
, libXcursor
, libXext
, libXrandr
, fontconfig
, glew
}:
buildDotnetModule rec {
  pname = "openutau";
  version = "0.1.158";

  src = fetchFromGitHub {
    owner = "stakira";
    repo = pname;
    rev = "build/${version}";
    sha256 = "/+hlL2sj/juzWrDcb5dELp8Zdg688XK8OnjKz20rx/M=";
  };

  # Remove vendored libportaudio
  postPatch = ''
    rm runtimes/*/native/*portaudio*
  '';

  projectFile = "OpenUtau/OpenUtau.csproj";
  # selfContainedBuild = true;
  nugetDeps = ./deps.nix;
  runtimeDeps = [
    portaudio

    # Avalonia UI
    libICE
    libSM
    libX11
    libXi
    libXcursor
    libXext
    libXrandr
    fontconfig
    glew
  ];

  # dotnetInstallFlags = [
  #   # "-p:PublishSingleFile=false"
  #   # "-p:PublishTrimmed=false"
  #   "-p:PublishReadyToRun=false"
  # ];
  # enableParallelBuilding = false;

  executables = [ "OpenUtau" ];

  # postFixup = ''
  #   ln -s libSkiaSharp.so $out/lib/openutau/liblibSkiaSharp.so
  # '';

  meta = with lib; {
    description = "Open singing synthesis platform ";
    homepage = "https://www.openutau.com";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
    # runtimes/<platform>/native/libworldline.so is precompiled and appears to be closed-source
    sourceProvenance = with sourceTypes; [ fromSource binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" ] ++ platforms.darwin;
    mainProgram = "OpenUtau";
  };
}
