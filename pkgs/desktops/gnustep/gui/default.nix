{ lib
, stdenv
, make
, wrapGNUstepAppsHook
, fetchzip
, base
, darwin
}:

stdenv.mkDerivation (finalAttrs: {
  version = "0.30.0";
  pname = "gnustep-gui";

  src = fetchzip {
    url = "ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-gui-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-24hL4TeIY6izlhQUcxKI0nXITysAPfRrncRqsDm2zNk=";
  };

  nativeBuildInputs = [ make wrapGNUstepAppsHook ];
  buildInputs = [
    base
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.CoreGraphics
  ];

  patches = [
    ./fixup-all.patch
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang (toString [
    "-Wno-error=implicit-function-declaration"
    "-Wno-error=int-conversion"
    "-Wno-error=implicit-int"
  ]);

  meta = {
    changelog = "https://github.com/gnustep/libs-gui/releases/tag/gui-${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    description = "A GUI class library of GNUstep";
    homepage = "https://gnustep.github.io/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ ashalkhakov matthewbauer dblsaiko ];
    platforms = lib.platforms.unix;
  };
})
