{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, cmake
, pkg-config
, libelf
, libb64
, c-ares
, curl
# , civetweb
, grpc
, jq
, libyaml
# , lpeg
# , luajit
# , lyaml
# , njson
, openssl
, protobuf
# , tbb
, libyamlcpp
, zlib
, jsoncpp
, re2
}:
let
  falcosecurity-libs = fetchFromGitHub {
    owner = "falcosecurity";
    repo = "libs";
    rev = "0.10.3";
    sha256 = "N59gNm2xXSvSpil6/zg41HdHLIJdamBsULaFORCAk1E=";
  };

  driver = fetchFromGitHub {
    owner = "falcosecurity";
    repo = "libs";
    rev = "4.0.0+driver";
    sha256 = "QRFOec1EZW1RsS/rHqQaPesnsV1xWhDj2S3LZiy2ZiE=";
  };
in
stdenv.mkDerivation rec {
  pname = "falco";
  version = "0.33.1";

  src = fetchFromGitHub {
    owner = "falcosecurity";
    repo = pname;
    rev = version;
    sha256 = "cPPJQmwZ+/VKFMbMAxqqUDEFw4ycLxvd/oZD1U7ZN78=";
  };

  patches = [
    # Unnecessary dependency, removed in next release
    (fetchurl {
      url = "https://github.com/falcosecurity/falco/pull/2307.patch";
      sha256 = "1pi6dawsb4862jbiqpyrcqqxaz5ppqwnbysawi118mfxpqh4fyac";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libelf
    zlib
    jq
    libyamlcpp
    openssl
    curl
    c-ares
    protobuf
    grpc
    libyaml
    jsoncpp
    libb64
    re2
  ];

  cmakeFlags = [
    "-DUSE_BUNDLED_DEPS=OFF"
    "-DFALCOSECURITY_LIBS_SOURCE_DIR=${falcosecurity-libs}"
    "-DDRIVER_SOURCE_DIR=${driver}"
  ];

  meta = with lib; {
    description = "Cloud Native Runtime Security";
    homepage = "https://falco.org";
    license = licenses.asl20;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.linux;
  };
}
