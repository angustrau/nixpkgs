{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qtbase
, qtsvg
, qtwayland
, gnuradioMinimal
, thrift
, mpir
, fftwFloat
, alsa-lib
, libjack2
, wrapGAppsHook
, wrapQtAppsHook
, sigtool
, cctools
# drivers (optional):
, rtl-sdr
, hackrf
, pulseaudioSupport ? !stdenv.isDarwin, libpulseaudio
, portaudioSupport ? false, portaudio
}:

assert pulseaudioSupport -> libpulseaudio != null;
assert portaudioSupport -> portaudio != null;
# audio backends are mutually exclusive
assert !(pulseaudioSupport && portaudioSupport);

let
  entitlements = builtins.toFile "Entitlements.plist" (lib.generators.toPlist {} {
    "com.apple.security.cs.allow-unsigned-executable-memory" = true;
  });
in
gnuradioMinimal.pkgs.mkDerivation rec {
  pname = "gqrx";
  version = "2.16";

  src = fetchFromGitHub {
    owner = "gqrx-sdr";
    repo = "gqrx";
    rev = "v${version}";
    hash = "sha256-14MVimOxM7upq6vpEhvVRnrverBuFToE2ktNhG59LKE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
    wrapGAppsHook
  ] ++ lib.optional stdenv.isDarwin sigtool;
  buildInputs = [
    gnuradioMinimal.unwrapped.logLib
    mpir
    fftwFloat
    libjack2
    gnuradioMinimal.unwrapped.boost
    qtbase
    qtsvg
    gnuradioMinimal.pkgs.osmosdr
    rtl-sdr
    hackrf
  ] ++ lib.optionals stdenv.isLinux [
    alsa-lib
    qtwayland
  ] ++ lib.optionals (gnuradioMinimal.hasFeature "gr-ctrlport") [
    thrift
    gnuradioMinimal.unwrapped.python.pkgs.thrift
  ] ++ lib.optionals pulseaudioSupport [ libpulseaudio ]
    ++ lib.optionals portaudioSupport [ portaudio ];

  cmakeFlags =
    let
      platform = if stdenv.isDarwin then "OSX" else "LINUX";
      audioBackend =
        if pulseaudioSupport
        then "Pulseaudio"
        else if portaudioSupport
        then "Portaudio"
        else "Gr-audio";
    in [
      "-D${platform}_AUDIO_BACKEND=${audioBackend}"
    ];

   # Prevent double-wrapping, inject wrapper args manually instead.
  dontWrapGApps = true;
  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '' + lib.optionalString stdenv.isDarwin ''
    CODESIGN_ALLOCATE="${cctools}/bin/${cctools.targetPrefix}codesign_allocate" \
      codesign --force --entitlements ${entitlements} --sign - $out/bin/gqrx
  '';

  meta = with lib; {
    description = "Software defined radio (SDR) receiver";
    longDescription = ''
      Gqrx is a software defined radio receiver powered by GNU Radio and the Qt
      GUI toolkit. It can process I/Q data from many types of input devices,
      including Funcube Dongle Pro/Pro+, rtl-sdr, HackRF, and Universal
      Software Radio Peripheral (USRP) devices.
    '';
    homepage = "https://gqrx.dk/";
    # Some of the code comes from the Cutesdr project, with a BSD license, but
    # it's currently unknown which version of the BSD license that is.
    license = licenses.gpl3Plus;
    platforms = platforms.unix;  # should work on Darwin / macOS too
    maintainers = with maintainers; [ bjornfor fpletz ];
  };
}
