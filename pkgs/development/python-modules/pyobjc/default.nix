{ lib, fetchFromGitHub, buildPythonPackage, python, frameworks }:

buildPythonPackage rec {
  pname = "pyobjc";
  version = "7.3";

  src = fetchFromGitHub {
    owner = "ronaldoussoren";
    repo = pname;
    rev = "v${version}";
    sha256 = "Y8Su1qNpc9aOnlrklc379JGHsozf3+nJlcwM4s5ZV28=";
  };

  patches = [
    # Replace setuptools install with pip
    # setuptools fails trying to access pypi
    ./install-with-pip.diff
  ];

  postPatch = ''
    # Remove requirements on broken submodules
    substituteInPlace pyobjc/setup.py --replace "install_requires=BASE_REQUIRES + framework_requires()" "install_requires=BASE_REQUIRES"
    rm -rf pyobjc-framework-{AdServices,CoreServices,DictionaryServices,FileProvider,FileProviderUI,FSEvents,GameCenter,InterfaceBuilderKit,LaunchServices,libdispatch,PubSub,SearchKit,ServerNotification,WebKit}
  '';

  hardeningDisable = [
    "strictoverflow"
  ];

  buildInputs = with frameworks; [
    ffi # This is Apple's native libffi
    Foundation
    GLKit

    # pyobjc binding submodules
    # Commented out are frameworks either broken or unsupported by nix
    # Please create an issue and @maintainer if a module is missing
    Accessibility
    Accounts
    AddressBook
    # AdServices
    AdSupport
    AppleScriptKit
    AppleScriptObjC
    ApplicationServices
    AppTrackingTransparency
    AuthenticationServices
    AutomaticAssessmentConfiguration
    Automator
    AVFoundation
    AVKit
    BusinessChat
    CalendarStore
    CallKit
    CFNetwork
    ClassKit
    CloudKit
    Cocoa
    Collaboration
    ColorSync
    Contacts
    ContactsUI
    CoreAudio
    CoreAudioKit
    CoreBluetooth
    CoreData
    CoreHaptics
    CoreLocation
    CoreMedia
    CoreMediaIO
    CoreMIDI
    CoreML
    CoreMotion
    # CoreServices
    CoreSpotlight
    CoreText
    CoreWLAN
    CryptoTokenKit
    DeviceCheck
    # DictionaryServices
    DiscRecording
    DiscRecordingUI
    DiskArbitration
    DVDPlayback
    EventKit
    ExceptionHandling
    ExecutionPolicy
    ExternalAccessory
    # FileProvider
    # FileProviderUI
    FinderSync
    # FSEvents
    # GameCenter
    GameController
    GameKit
    GameplayKit
    ImageCaptureCore
    IMServicePlugIn
    InputMethodKit
    InstallerPlugins
    InstantMessage
    Intents
    # InterfaceBuilderKit
    IOSurface
    iTunesLibrary
    KernelManagement
    LatentSemanticMapping
    # LaunchServices
    # libdispatch
    LinkPresentation
    LocalAuthentication
    MapKit
    MediaAccessibility
    MediaLibrary
    MediaPlayer
    MediaToolbox
    Message
    Metal
    MetalKit
    MetalPerformanceShaders
    MetalPerformanceShadersGraph
    MLCompute
    ModelIO
    MultipeerConnectivity
    NaturalLanguage
    NetFS
    Network
    NetworkExtension
    NotificationCenter
    OpenDirectory
    OSAKit
    OSLog
    PassKit
    PencilKit
    Photos
    PhotosUI
    PreferencePanes
    # PubSub
    PushKit
    Quartz
    QuickLookThumbnailing
    ReplayKit
    SafariServices
    SceneKit
    ScreenSaver
    ScreenTime
    ScriptingBridge
    # SearchKit
    Security
    SecurityFoundation
    SecurityInterface
    # ServerNotification
    ServiceManagement
    Social
    SoundAnalysis
    Speech
    SpriteKit
    StoreKit
    SyncServices
    SystemConfiguration
    SystemExtensions
    UniformTypeIdentifiers
    UserNotifications
    UserNotificationsUI
    VideoSubscriberAccount
    VideoToolbox
    Virtualization
    Vision
    # WebKit
  ];

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir $out
    PYTHONPATH=$out/${python.sitePackages}:$PYTHONPATH
    ${python.interpreter} install.py --prefix $out
    ${python.interpreter} -m pip install ./pyobjc --no-index --prefix $out
    runHook postInstall
  '';

  # Test runner fails without reporting error locations
  doCheck = false;
  pythonImportsCheck = [ "objc" ];

  meta = with lib; {
    description = "A bridge between the Python and Objective-C programming languages";
    homepage = "https://pyobjc.readthedocs.io/";
    license = licenses.mit;
    maintainers = with maintainers; [ angustrau ];
    platforms = platforms.darwin;
  };
}
