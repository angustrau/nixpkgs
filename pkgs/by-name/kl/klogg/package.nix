{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, boost
, ragel
, simdutf
, croaring
, hyperscan
, namedtype
, libuchardet
, robin-hood-hashing
, backward-cpp
, catch2
, xxHash
, whereami
, efsw
, tbb_2021_8
, git
, cacert
, python3

}:

let

  version = "22.06.0.1289";

  src = fetchFromGitHub {
    owner = "variar";
    repo = "klogg";
    rev = "v${version}";
    hash = "sha256-zqZY2PESd9xHGV28JHyhkwNpGjTovPlJB+x5K8far0Y=";
  };

  klogg-deps = mkDerivation rec {
    pname = "klogg-deps";
    inherit version src;

    nativeBuildInputs = [ cmake pkg-config git cacert python3 ];
    buildInputs = [
      boost
      ragel
      croaring
    ];

    preConfigure = ''
      mkdir -p ${placeholder "out"}/share
    '';
    cmakeFlags = [
      "-DCPM_SOURCE_CACHE=${placeholder "out"}/share"
    ];

    dontBuild = true;

    outputHash =
      if stdenv.hostPlatform.isDarwin then
        ""
      else
        "";
    outputHashAlgo = "sha256";
  };

  macdeployqtfix = fetchFromGitHub {
    owner = "arl";
    repo = "macdeployqtfix";
    rev = "ffe980011dd7a08ac2bc79dbd5ac86a62b1c1f05";
    hash = "sha256-E/RCCGH0ZcbZC1eyE+cryluiFOEgmcf4qQ3iOHMSejQ=";
  };

  klogg-croaring = fetchFromGitHub {
    owner = "variar";
    repo = "CRoaring";
    rev = "d582cd224ebc2f5a1585035a8f5ce306052e8ad1";
    hash = "sha256-GWMUR3oCP2Qo7DTp6TZ5gozr0f+MupMfOjE/ovW2hq8=";
  };

  klogg-maddy = fetchFromGitHub {
    owner = "variar";
    repo = "maddy";
    rev = "67d331c59d3abc4e92eecc5874836a600dbfaf58";
    hash = "sha256-Afbr7ybiGDl796eJ7+Y10AiJJ0zEqTeV6v6phZMpkNI=";
  };

  klogg-karchive = fetchFromGitHub {
    owner = "variar";
    repo = "klogg_karchive";
    rev = "f546bf6ae66a8d34b43da5a41afcfbf4e1a47906";
    hash = "sha256-tI4vErSz8lSw5HRn8cP7xNdnilhvfCe9yIBHY1ucxw4=";
  };

  klogg-singleapplication = fetchFromGitHub {
    owner = "itay-grudev";
    repo = "SingleApplication";
    rev = "v3.3.4";
    hash = "sha256-h2H0evXIajCiMmxrM1a7PVNSRLLyZ6FimAEHIhfTquM=";
  };

  klogg-exprtk = fetchFromGitHub {
    owner = "variar";
    repo = "klogg_exprtk";
    rev = "1f9f4cd7d2620b7b24232de9ea22908d63913459";
    hash = "sha256-ueEmQnEYO74eQf4eG9K7pRk0RX2KRHA/kLL0+NNIPJw=";
  };

  kdtoolbox  = fetchFromGitHub {
    owner = "KDAB";
    repo = "KDToolBox";
    rev = "253a6c087c626cd477e15c9dae4b0e3ec27afaee";
    hash = "sha256-63U+NEpXgvY59qvFTLHlhuMTO/hJxqt3q7nnZxg75nc=";
  };
in
mkDerivation rec {
  pname = "klogg";
  inherit version src;

  postPatch = ''
    echo "" > src/utils/src/cpu_info.cpp
  '';

  nativeBuildInputs = [ cmake pkg-config python3 ];
  buildInputs = [
    boost
    ragel
    # simdutf
    # croaring
    # hyperscan
    libuchardet
    robin-hood-hashing
    # backward-cpp
    catch2
    xxHash
    tbb_2021_8
  ];

  preConfigure = ''
    cp -r ${klogg-croaring} 3rdparty/croaring
    chmod -R a+w 3rdparty/croaring
  '';

  cmakeFlags = [
    "-DKLOGG_USE_HYPERSCAN=OFF"
    "-DKLOGG_USE_LTO=OFF"
    "-DKLOGG_USE_MIMALLOC=OFF"

    "-DCPM_USE_LOCAL_PACKAGES=1"
    # "-DCPM_LOCAL_PACKAGES_ONLY=1"
    "-DCPM_simdutf_SOURCE=${simdutf.src}"
    "-DCPM_macdeployqtfix_SOURCE=${macdeployqtfix}"
    "-Dmacdeployqtfix_SOURCE_DIR=${macdeployqtfix}"
    "-DCPM_CRoaring_SOURCE=../../3rdparty/croaring"
    # "-DCRoaring_SOURCE_DIR=${klogg-croaring}"
    "-DCPM_maddy_SOURCE=${klogg-maddy}"
    "-DCPM_NamedType_SOURCE=${namedtype}/include/NamedType"
    "-DCPM_KF5Archive_SOURCE=${klogg-karchive}"
    "-DCPM_backward-cpp_SOURCE=${backward-cpp.src}"
    "-DCPM_SingleApplication_SOURCE=${klogg-singleapplication}"
    "-DCPM_whereami_SOURCE=${whereami.src}"
    "-DCPM_exprtk_SOURCE=${klogg-exprtk}"
    "-DCPM_KDToolBox_SOURCE=${kdtoolbox}"
    "-DCPM_efsw_SOURCE=${efsw.src}"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-unused-command-line-argument -Wno-deprecated-non-prototype -Wno-unused-but-set-variable";

  # qmakeFlags = [ "VERSION=${version}" ];

  # postInstall = lib.optionalString stdenv.isDarwin ''
  #   mkdir -p $out/Applications
  #   mv $out/bin/glogg.app $out/Applications/glogg.app
  #   rm -fr $out/{bin,share}
  # '';

  passthru.deps = klogg-deps;

  meta = with lib; {
    description = "The fast, smart log explorer";
    longDescription = ''
      A multi-platform GUI application to browse and search through long or complex log files. It is designed with programmers and system administrators in mind. glogg can be seen as a graphical, interactive combination of grep and less.
    '';
    homepage = "https://glogg.bonnefon.org/";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ c0bw3b ];
    mainProgram = "klogg";
  };
}
