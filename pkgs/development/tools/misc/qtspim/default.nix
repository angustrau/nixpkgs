{ lib
, stdenv
, fetchsvn
, makeBinaryWrapper
, qt5
, qt6
, bison
, flex
, coreutils
}:

stdenv.mkDerivation rec {
  pname = "qtspim";
  version = "9.1.24";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/spimsimulator/code/";
    rev = "764";
    hash = "sha256-7fZGjT72wsZHsyslEDQzRrh0fETZF2UXNzbVKle0kck=";
  };

  postPatch = ''
    cd QtSpim

    substituteInPlace QtSpim.pro --replace-fail /usr/lib/qtspim/lib $out/lib
    substituteInPlace menu.cpp \
      --replace-fail /usr/lib/qtspim/bin/assistant ${qt5.qttools.dev}/bin/assistant \
      --replace-fail /Applications/QtSpim.app/Contents/MacOS/Assistant ${qt5.qttools.dev}/bin/Assistant.app/Contents/MacOS/Assistant \
      --replace-fail /usr/lib/qtspim/help/qtspim.qhc $out/share/help/qtspim.qhc \
      --replace-fail /Applications/QtSpim.app/Contents/Resources/doc/qtspim.qhc $out/Applications/QtSpim.app/Contents/Resources/doc/qtspim.qhc
    substituteInPlace ../Setup/qtspim_debian_deployment/qtspim.desktop \
      --replace-fail /usr/bin/qtspim qtspim \
      --replace-fail /usr/lib/qtspim/qtspim.png qtspim

    # Qt5's qhelpgenerator segfaults on darwin?
    ${qt6.qttools}/libexec/qhelpgenerator help/qtspim.qhp -o help/qtspim.qch
  '';

  nativeBuildInputs = [
    makeBinaryWrapper
    qt5.wrapQtAppsHook
    qt5.qmake
    bison
    flex
    coreutils
  ];
  buildInputs = [ qt5.qtbase ];
  env.QT_PLUGIN_PATH = "${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}";

  qmakeFlags = [
    # This seems really stupid, but the only place that MOVE is invoked is to move parser_yacc.h on
    # to itself, which fails with gnuutils, since they raises an error if you try to mv (or cp) a
    # file onto itself. Pretty pointless, and no way to turn it off...
    "QMAKE_MOVE=touch"
  ];

  installPhase = if stdenv.isDarwin then ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp NewIcon.icns QtSpim.app/Contents/Resources/NewIcon.icns
    cp -r help QtSpim.app/Contents/Resources/doc
    cp -r QtSpim.app $out/Applications/QtSpim.app
    makeWrapper $out/Applications/QtSpim.app/Contents/MacOS/QtSpim $out/bin/qtspim

    runHook postInstall
  '' else ''
    runHook preInstall

    install -D QtSpim $out/bin/qtspim
    install -D ../Setup/qtspim_debian_deployment/copyright $out/share/licenses/qtspim/copyright
    install -D ../Setup/qtspim_debian_deployment/qtspim.desktop $out/share/applications/qtspim.desktop
    install -D ../Setup/NewIcon48x48.png $out/share/icons/hicolor/48x48/apps/qtspim.png
    install -D ../Setup/NewIcon256x256.png $out/share/icons/hicolor/256x256/apps/qtspim.png
    cp -r help $out/share/help

    runHook postInstall
  '';

  meta = with lib; {
    description = "New user interface for spim, a MIPS simulator";
    mainProgram = "qtspim";
    homepage = "https://spimsimulator.sourceforge.net/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
}
