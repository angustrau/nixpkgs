{ lib
, stdenv
, fetchFromGitHub
, gettext
, pkg-config
, ncurses
, darwin
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvim";
  version = "0-unstable-2021-06-24";

  src = fetchFromGitHub {
    owner = "onivim";
    repo = "libvim";
    rev = "9ade7d1e2ac54cb945724762cb8be9c68adef3f0";
    hash = "sha256-jNhvzHB2eJzV1G1DjwwWx+QRF8MJpHd1WlNwRM9muIM=";
  };

  preConfigure = ''
    cd src/
  '';

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=implicit-function-declaration -Wno-error=implicit-int";

  # nativeBuildInputs = [
  #   gettext
  #   pkg-config
  # ];

  buildInputs = [
    ncurses
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.Carbon
  ];

  enableParallelBuilding = true;
  makeFlags = [
    "libvim.a"
    # Disable warnings as errors
    "WARN_FLAGS="
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    make installlibvim DESTDIR=$out

    runHook postInstall
  '';

  meta = with lib; {
    description = "The core Vim editing engine as a minimal C library";
    homepage = "https://github.com/onivim/libvim";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
})
