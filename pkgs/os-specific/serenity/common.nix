{ lib
, stdenvNoCC
, buildPackages
}:

rec {
  rev = "3fa9c9bda48d86ae5fa3759aa91a2e0b6ba47d22";

  version = "unstable-2023-04-03";

  # Fetch Serenity source and patch shebangs
  src = buildPackages.stdenvNoCC.mkDerivation {
    pname = "serenity-src";
    inherit version;

    src = buildPackages.fetchFromGitHub {
      owner = "SerenityOS";
      repo = "serenity";
      sha256 = "M99WKPzX1IsGTqIBPljLYRtrXskDLxldCV+xIVGmwHc=";
      inherit rev;
    };

    installPhase = ''
      cp -r . $out
    '';

    dontPatchELF = true;
  };
}
