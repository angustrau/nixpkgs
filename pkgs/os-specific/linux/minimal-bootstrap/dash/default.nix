{ lib
, runCommand
, fetchurl
, tinycc
}:
let
  pname = "dash";
  version = "0.5.12";
  src = fetchurl {
    url = "http://gondor.apana.org.au/~herbert/dash/files/dash-${version}.tar.gz";
    sha256 = "12pjm2j0q0q88nvqbcyqjwr8s1c29ilxyq2cdj8k42wbdv24liva";
  };

  CFLAGS = [
    "-BSD=1"
    "-DSHELL"
    "-DJOBS=0"
    "-DHAVE_CONFIG_H"
    "-I."
    "-I.."
    "-I./bltin"
    "-include${./config.h}"
    "-include${./declarations.h}"
    # These source files require a shell to generate, therefore they must be
    # generated beforehand with `./configure && make`
    "-I${./gen}"
  ];

  # Maintenance note: List of sources
  dash_CFILES = lib.splitString " " (
    "alias.c arith_yacc.c arith_yylex.c cd.c error.c eval.c exec.c expand.c "
    + "histedit.c input.c jobs.c mail.c main.c memalloc.c miscbltin.c "
    + "mystring.c options.c parser.c redir.c show.c trap.c output.c "
    + "bltin/printf.c system.c bltin/test.c bltin/times.c var.c");
  gen_CFILES = [ ./gen/builtins.c "init.c" "nodes.c" "signames.c" "syntax.c" ];
  sources = dash_CFILES ++ gen_CFILES ++ [
    ./stubs.c
    ./musl-extra.c
  ];

  objects = map (x: lib.replaceStrings [".c"] [".o"] (builtins.baseNameOf "${x}")) sources;
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ tinycc ];

  meta = with lib; {
    description = "A POSIX-compliant implementation of /bin/sh that aims to be as small as possible";
    homepage = "http://gondor.apana.org.au/~herbert/dash/";
    license = with licenses; [ bsd3 gpl2Plus ];
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.linux;
  };
} ''
  # Unpack source
  ungz --file ${src} --output dash.tar
  untar --file dash.tar
  rm dash.tar
  build=''${NIX_BUILD_TOP}/dash-${version}
  cd ''${build}/src

  alias CC="tcc ${lib.concatStringsSep " " CFLAGS}"

  # Generate builtins.def
  CC -E -x c -o builtins.def builtins.def.in

  # Generate init.c
  CC -static -o mkinit mkinit.c
  ./mkinit ${lib.concatStringsSep " " dash_CFILES}

  # Generate nodes.{c,h}
  CC -static -o mknodes mknodes.c
  ./mknodes nodetypes nodes.c.pat

  # Generate syntax.{c,h}
  # mes-libc's printf doesn't support "%#" syntax
  replace --file mksyntax.c --output mksyntax.c --match-on "%#o" --replace-with "0%o"
  CC -static -o mksyntax mksyntax.c
  ./mksyntax

  # Generate signames.c
  CC -static -o mksignames mksignames.c
  ./mksignames

  # Compile
  ${lib.concatLines (map (f: "CC -c ${f}") sources)}

  # Link
  CC -static -o dash ${lib.concatStringsSep " " objects}

  # Install
  mkdir -p ''${out}/bin
  cp ./dash ''${out}/bin
  chmod 555 ''${out}/bin/dash
''
