{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, cython
, setuptools-scm
, astunparse
, cloudpickle
, crdp
, hypothesis
, ipython
, jinja2
, numpy
, pynvml
, rich
, pytestCheckHook
}:

let
  # No version is specified. Scalene tries to use the latest commit
  heap-layers = fetchFromGitHub {
    owner = "emeryberger";
    repo = "Heap-Layers";
    rev = "afa5232481a53ea743de9c72f5764bf869e961e1";
    hash = "sha256-gTPchDROZ26MC+xcVFS+ZosipME08tjIROjirodf+pk=";
  };
  printf = fetchFromGitHub {
    owner = "mpaland";
    repo = "printf";
    rev = "d3b984684bb8a8bdc48cc7a1abecb93ce59bbe3e";
    hash = "sha256-uLN9MtmL/6aE+TRRM0OFcL1xi4gGQNFvooEJkiVIabU=";
  };

in
buildPythonPackage rec {
  pname = "scalene";
  version = "1.5.36";
  # format = "setuptools";

  src = fetchFromGitHub {
    owner = "plasma-umass";
    repo = "scalene";
    rev = "v${version}";
    hash = "sha256-gxq2Cps3K0RYbUBQGMncIQJtDYnipop1FhXDClN2nfE=";
  };

  patches = [
    # ./darwin.patch
  ];

  postPatch = ''
    cp -r ${heap-layers} vendor/Heap-Layers
    cp -r ${printf} vendor/printf
    cp -r ${crdp.src} vendor/crdp
    chmod -R +w vendor/Heap-Layers vendor/printf vendor/crdp
    cp vendor/printf/printf.c vendor/printf/printf.cpp
    sed -i -e 's/^#define printf printf_/\/\/&/' vendor/printf/printf.h
    sed -i -e 's/^#define vsnprintf vsnprintf_/\/\/&/' vendor/printf/printf.h
  '';

  build-system = [
    setuptools
    wheel
  ];

  nativeBuildInputs = [
    cython
    setuptools-scm
  ];

  propagatedBuildInputs = [
    # astunparse
    cloudpickle
    # crdp
    # ipython

    jinja2
    rich
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    pynvml
  ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    numpy
  ];
  pythonImportsCheck = [ "scalene" "scalene.crdp" ];
  doCheck = false;

  meta = {
    description = "Python CPU+GPU+memory profiler with AI-powered optimization proposals";
    homepage = "https://github.com/plasma-umass/scalene";
    license = lib.licenses.asl20;
    mainProgram = "scalene";
    maintainers = with lib.maintainers; [ emilytrau ];
  };
}
