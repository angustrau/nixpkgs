{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "robin-hood-hashing";
  version = "3.11.5";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "robin-hood-hashing";
    rev = finalAttrs.version;
    hash = "sha256-J4u9Q6cXF0SLHbomP42AAn5LSKBYeVgTooOhqxOIpuM=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DRH_STANDALONE_PROJECT=OFF" ];

  meta = with lib; {
    description = "robin_hood unordered map & set";
    homepage = "https://github.com/martinus/robin-hood-hashing";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.all;
  };
})
