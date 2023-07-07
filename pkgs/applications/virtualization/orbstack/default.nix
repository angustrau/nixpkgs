{ lib
, stdenvNoCC
, fetchurl
, _7zz
}:
let
  arch =
    if stdenvNoCC.hostPlatform.isAarch64 then "arm64"
    else if stdenvNoCC.hostPlatform.isx86_64 then "amd64"
    else throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "orbstack";
  version = "0.13.0_1910";

  src = fetchurl {
    url = "https://cdn-updates.orbstack.dev/${arch}/OrbStack_v${finalAttrs.version}_${arch}.dmg";
    sha256 = {
      aarch64-darwin = "0dspmbgxcxy4lzn221mg7d9mdmh06f43rxgbw2fbbjav258k7zvv";
      x86_64-darwin  = "04fbhyak9bj0syqngzqkns97by44ljql0303irmy8q2503skksxz";
    }.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
  };

  # APFS format is unsupported by undmg
  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    7zz x -snld $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications
    ln -s Applications/OrbStack.app/Contents/MacOS/bin $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Run Docker containers and Linux machines on macOS";
    homepage = "https://orbstack.dev";
    license = licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ emilytrau Enzime ];
    platforms = platforms.darwin;
  };
})
