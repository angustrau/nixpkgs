{ lib
, stdenv
, fetchFromGitHub
, substituteAll
, gradle
, perl
, jdk
, makeWrapper
, xorg
, libGL
}:
stdenv.mkDerivation (finalAttrs: let
  # fake build to pre-download deps into fixed-output derivation
  deps = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-deps";
    inherit (finalAttrs) version src patches;
    nativeBuildInputs = [ gradle perl ];
    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon fatJar
    '';
    # perl code mavenizes pathes (com.squareup.okio/okio/1.13.0/a9283170b7305c8d92d25aff02a6ab7e45d06cbe/okio-1.13.0.jar -> com/squareup/okio/okio/1.13.0/okio-1.13.0.jar)
    # reproducible by sorting
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\|module\)' \
        | LC_ALL=C sort \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh

      cp $out/com/squareup/okio/okio-jvm/3.2.0/okio-jvm-3.2.0.jar $out/com/squareup/okio/okio/3.2.0/okio-3.2.0.jar
      cp $out/org/jetbrains/kotlin/kotlin-gradle-plugin/1.9.0-Beta/kotlin-gradle-plugin-1.9.0-Beta{-gradle80,}.jar
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = finalAttrs.depsHash;
  };
in
{
  pname = "minosoft";
  version = "unstable-2023-06-22";
  rev = "60cda1237e3387b7fa51deccc37a02a40172b6a4";

  src = fetchFromGitHub {
    owner = "Bixilon";
    repo = finalAttrs.pname;
    sha256 = "S6CfaKInrJB51XQGfGEvQRxkSsctlrALkZnTqMtikAs=";
    inherit (finalAttrs) rev;
  };

  patches = [
    # there is no .git anyway
    (substituteAll {
      src = ./remove-git-version.patch;
      inherit (finalAttrs) version rev;
      rev_short = lib.substring 0 7 finalAttrs.rev;
    })
  ];

  nativeBuildInputs = [ gradle perl makeWrapper ];

  buildPhase = ''
    runHook preBuild

    export GRADLE_USER_HOME=$(mktemp -d)
    # point to offline repo
    sed -ie 's#mavenCentral()#maven(url = "${deps}")#g' build.gradle.kts
    sed -ie 's#mavenCentral()#maven(url = "${deps}")#g' settings.gradle.kts
    gradle --offline --no-daemon fatJar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 build/libs/minosoft-fat-*.jar $out/share/minosoft/minosoft.jar
    mkdir -p $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/minosoft \
      --add-flags "-jar $out/share/minosoft/minosoft.jar" \
      --prefix LD_LIBRARY_PATH ":" "${lib.makeLibraryPath [ xorg.libX11 xorg.libXxf86vm xorg.libxcb xorg.libXext xorg.libXau xorg.libXdmcp libGL ]}"

    runHook postInstall
  '';

  passthru.deps = deps;
  depsHash = "sha256-rFH9vX1wd0RC7Zta15Kavxi4+o2BdmEhnLKBO18YLI4=";

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
})
