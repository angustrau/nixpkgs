{ lib
, runCommand
, fetchurl
, tinycc
, gnupatch
}:
let
  pname = "gnumake";
  version = "4.4.1";

  src = fetchurl {
    url = "mirror://gnu/make/make-${version}.tar.gz";
    sha256 = "sha256-3Rb7HWe/q3mnL16DkHNcSePo5wtJRaFasfgd23hlj7M=";
  };

  CFLAGS = [
    "-I./src"
    "-I./lib"
    "-DHAVE_CONFIG_H"
    "-DMAKE_MAINTAINER_MODE"
    "-DLIBDIR=\\\"${placeholder "out"}/lib\\\""
    "-DLOCALEDIR=\\\"/fake-locale\\\""
    "-DPOSIX=1"
    # mes-libc doesn't implement osync_* methods
    "-DNO_OUTPUT_SYNC=1"
  ];

  # Maintenance note: list of source files derived from Basic.mk
  make_SOURCES = lib.splitString " " "src/ar.c src/arscan.c src/commands.c src/default.c src/dir.c src/expand.c src/file.c src/function.c src/getopt.c src/getopt1.c src/guile.c src/hash.c src/implicit.c src/job.c src/load.c src/loadapi.c src/main.c src/misc.c src/output.c src/read.c src/remake.c src/rule.c src/shuffle.c src/signame.c src/strcache.c src/variable.c src/version.c src/vpath.c";
  glob_SOURCES = [ "lib/fnmatch.c" "lib/glob.c" ];
  remote_SOURCES = [ "src/remote-stub.c" ];
  sources = make_SOURCES ++ glob_SOURCES ++ remote_SOURCES ++ [
    "src/posixos.c"
  ];

  objects = map (x: lib.replaceStrings [".c"] [".o"] (builtins.baseNameOf x)) sources;
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc gnupatch ];

  meta = with lib; {
    description = "A tool to control the generation of non-source files from sources";
    homepage = "https://www.gnu.org/software/make";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    mainProgram = "make";
    platforms = [ "i686-linux" ];
  };
} ''
  # Unpack source
  ungz --file ${src} --output make.tar
  untar --file make.tar
  rm make.tar
  build=''${NIX_BUILD_TOP}/make-${version}
  cd ''${build}

  cp ${./config.h} src/config.h
  cp lib/glob.in.h lib/glob.h
  cp lib/fnmatch.in.h lib/fnmatch.h

  # Replaces /bin/sh with sh, see patch file for reasoning
  patch -p1 -i ${./0001-No-impure-bin-sh.patch}

  # Purity: don't look for library dependencies (of the form `-lfoo') in /lib
  # and /usr/lib. It's a stupid feature anyway. Likewise, when searching for
  # included Makefiles, don't look in /usr/include and friends.
  patch -p1 -i ${./0002-remove-impure-dirs.patch}

  # Fixes for tinycc. See patch file for reasoning
  patch -p1 -i ${./0003-tinycc-support.patch}

  # Compile
  alias CC="tcc ${lib.concatStringsSep " " CFLAGS}"
  ${lib.concatLines (map (f: "CC -c ${f}") sources)}

  # Link
  CC -static -o make ${lib.concatStringsSep " " objects}

  # Check
  ./make --version

  # Install
  mkdir -p ''${out}/bin
  cp ./make ''${out}/bin
  chmod 555 ''${out}/bin/make
''
