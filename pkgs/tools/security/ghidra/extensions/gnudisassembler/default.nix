{ lib
, fetchurl
, buildGhidraExtension
, ghidra
, flex
, bison
, texinfo
, perl
, zlib
}:

let
  # Incorporates source from binutils
  # https://github.com/NationalSecurityAgency/ghidra/blob/00533b2869dbe2904474859bcd38c1dfde6f52f8/GPL/GnuDisassembler/build.gradle#L34
  binutils-version = "2.36";
  binutils-src = fetchurl {
    url = "mirror://gnu/binutils/binutils-${binutils-version}.tar.bz2";
    sha256 = "13cfscz165p0spals44nzdhjl8l9c9yyixysjajqrhksvj8gd7i0";
  };
in
buildGhidraExtension rec {
  pname = "gnudisassembler";
  version = lib.getVersion ghidra;

  src = "${ghidra}/lib/ghidra/Extensions/Ghidra/${ghidra.distroPrefix}_GnuDisassembler.zip";

  postPatch = ''
    ln -s ${binutils-src} binutils-${binutils-version}.tar.bz2
  '';

  # Don't modify ELF stub resources
  dontPatchELF = true;
  dontStrip = true;

  nativeBuildInputs = [
    flex
    bison
    texinfo
    perl
  ];

  buildInputs = [
    zlib
  ];

  installPhase = ''
    runHook preInstall

    EXTENSIONS_ROOT=$out/lib/ghidra/Ghidra/Extensions
    mkdir -p $EXTENSIONS_ROOT
    unzip -d $EXTENSIONS_ROOT $src
  
    mkdir -p $EXTENSIONS_ROOT/GnuDisassembler/build
    cp -r build/os $EXTENSIONS_ROOT/GnuDisassembler/build/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Leverage the binutils disassembler capabilities for various processors";
    homepage = "https://ghidra-sre.org/";
    downloadPage = "https://github.com/NationalSecurityAgency/ghidra/tree/master/GPL/GnuDisassembler";
    license = licenses.gpl2Only;
  };
}
