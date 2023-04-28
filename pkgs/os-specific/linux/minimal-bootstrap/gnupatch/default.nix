{ lib
, runCommand
, fetchurl
, tinycc
}:
let
  pname = "gnupatch";
  # >2.5.9 uses features not implemented in mes-libc (eg. quotearg.h)
  version = "2.5.9";

  src = fetchurl {
    url = "mirror://gnu/patch/patch-${version}.tar.gz";
    sha256 = "12nv7jx3gxfp50y11nxzlnmqqrpicjggw6pcsq0wyavkkm3cddgc";
  };

  CFLAGS = [
    "-I."
    "-DHAVE_CONFIG_H"
    "-Ded_PROGRAM=\\\"ed\\\""
  ];

  # Maintenance note: List of sources from Makefile.in
  SRCS = lib.splitString " " (
    "addext.c argmatch.c backupfile.c "
    + "basename.c dirname.c "
    + "getopt.c getopt1.c inp.c "
    + "maketime.c partime.c "
    + "patch.c pch.c "
    + "quote.c quotearg.c quotesys.c "
    + "util.c version.c xmalloc.c");
  sources = SRCS ++ [
    # mes-libc doesn't implement `error`
    "error.c"
  ];

  objects = map (x: lib.replaceStrings [".c"] [".o"] (builtins.baseNameOf x)) sources;
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc ];

  meta = with lib; {
    description = "A program to apply differences to files";
    homepage = "https://www.gnu.org/software/patch";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    mainProgram = "patch";
    platforms = [ "i686-linux" ];
  };
} ''
  # Unpack source
  ungz --file ${src} --output patch.tar
  untar --file patch.tar
  rm patch.tar
  build=''${NIX_BUILD_TOP}/patch-${version}
  cd ''${build}

  cp ${./config.h} config.h

  # Compile
  alias CC="tcc ${lib.concatStringsSep " " CFLAGS}"
  ${lib.concatLines (map (f: "CC -c ${f}") sources)}

  # Link
  CC -static -o patch ${lib.concatStringsSep " " objects}

  # Check
  ./patch --version

  # Install
  mkdir -p ''${out}/bin
  cp ./patch ''${out}/bin
  chmod 555 ''${out}/bin/patch
''
