{ lib
, python2Packages
, fetchFromGitHub }:

python2Packages.buildPythonApplication rec {
  pname = "deblaze";
  version = "0.2";
  format = "other";

  src = fetchFromGitHub {
    owner = "spiderlabs";
    repo = pname;
    rev = "0608dc36513cb473d71545b5dea765d4333e063e";
    sha256 = "ZloKetRstMVvio9JzJYNLAcj3zZsyE5Kjf8VSYjvWD4=";
  };

  postPatch = ''
    # De-vendor pyamf dependency
    rm -rf pyamf
    substituteInPlace deblaze.py \
      --replace 'sys.path.append("pyamf/")' ""
  '';

  propagatedBuildInputs = with python2Packages; [
    pillow
    pyamf
  ];

  installPhase = ''
    runHook preInstall

    install -D deblaze.py $out/bin/deblaze

    runHook postInstall
  '';

  meta = with lib; {
    description = "A remote enumeration tool for Flex Servers";
    homepage = "https://github.com/SpiderLabs/deblaze";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
  };
}
