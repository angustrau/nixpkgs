{ lib
, stdenv
, fetchFromGitHub
, cmake
, gtest
# , bpftools
, zlib
, protobuf
, elfutils
, jsoncpp
, tbb
, libb64
, jq
, openssl
, curl
, valijson
, re2
, c-ares
, grpc
# , libbpf
, withChisel ? true, luajit
}:

stdenv.mkDerivation rec {
  pname = "falco-libs";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "falcosecurity";
    repo = "libs";
    rev = version;
    sha256 = "N59gNm2xXSvSpil6/zg41HdHLIJdamBsULaFORCAk1E=";
  };

  # Test fails in build sandbox
  patches = [ ./disable-test.patch ];

  nativeBuildInputs = [
    cmake
    gtest
    # bpftools
  ];

  buildInputs = [
    zlib
    protobuf
    elfutils
    jsoncpp
    tbb
    libb64
    jq
    openssl
    curl
    valijson
    re2
    c-ares
    grpc
    # libbpf
  ] ++ lib.optionals withChisel [
    luajit
  ];

  cmakeFlags = [
    "-DFALCOSECURITY_LIBS_VERSION=${version}"
    "-DUSE_BUNDLED_DEPS=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    # "-DBUILD_BPF=ON"
    # "-DBUILD_LIBSCAP_MODERN_BPF=ON"
    "-DBUILD_BPF=OFF"
    "-DBUILD_LIBSCAP_MODERN_BPF=OFF"
    "-DBUILD_DRIVER=OFF"
    "-DENABLE_DKMS=OFF"
    "-DCREATE_TEST_TARGETS=OFF"
  ] ++ lib.optional withChisel "-DWITH_CHISEL=ON";

  makeFlags = [
    "scap"
    "sinsp"
  ];

  # hardeningDisable = [ "stackprotector" ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    # make run-unit-tests

    runHook postCheck
  '';

  postInstall = ''
    rm -rf $out/src
  '';

  meta = with lib; {
    description = "libsinsp and libscap, plus chisels related code and common utilities";
    homepage = "https://github.com/falcosecurity/libs";
    license = licenses.asl20;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
}
