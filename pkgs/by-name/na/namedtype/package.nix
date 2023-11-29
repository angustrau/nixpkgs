{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "namedtype";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "joboccara";
    repo = "NamedType";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ImEOj8nuAUeNjVgLjohSDPA8n7nN6YEa6o6oRbHwqRY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r include $out/include

    runHook postInstall
  '';

  meta = with lib; {
    description = "Implementation of strong types in C++";
    homepage = "https://github.com/joboccara/NamedType";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.all;
  };
})
