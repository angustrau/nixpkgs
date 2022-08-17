{ lib, system, seeds }:

let
  src = builtins.fetchGit {
    name = "stage0-posix-source";
    url = "https://github.com/oriansj/stage0-posix.git";
    rev = "c6f86a3e924b2ce2061ee677b9b91c18c2d1a769";
    submodules = true;
  };

  inherit ({
    i686-linux = {
      ARCH = "x86";
      BLOOD_FLAG = " ";
      BASE_ADDRESS = "0x8048000";
      ENDIAN_FLAG = "--little-endian";
      mescc-tools-mini-kaem = import ./x86/mescc-tools-mini-kaem.nix;
    };
  }.${system}) ARCH BLOOD_FLAG BASE_ADDRESS ENDIAN_FLAG mescc-tools-mini-kaem;

  run = name: builder: args: derivation {
    inherit system name builder args;
  };
  out = placeholder "out";

  hex0-seed = seeds.${system};
  hex0 = run "hex0" hex0-seed ["${src}/${ARCH}/hex0_${ARCH}.hex0" out];

  mini-kaem = mescc-tools-mini-kaem { inherit src run out hex0; };

  run-kaem = {
    name,
    script,
    buildInputs ? [],
    extraEnv ? {}
  }: derivation (rec {
    inherit system name src ARCH BLOOD_FLAG BASE_ADDRESS ENDIAN_FLAG;
    builder = mini-kaem.kaem;
    args = [
      "--verbose"
      "--strict"
      "--file"
      script
    ];
    BUILD_INPUTS_PATH = lib.makeBinPath buildInputs;
  } // extraEnv);

  # Detour outside the specified pipeline to build mkdir and cp
  # This is useful for creating multiple-output derivations
  mkdir0 = run-kaem {
    name = "mkdir0";
    script = ./mkdir0.kaem;
    extraEnv = mini-kaem;
  };
  ln0 = run-kaem {
    name = "ln0";
    script = ./ln0/ln0.kaem;
    extraEnv = mini-kaem // {
      ln0_DIR = ./ln0;
    };
  };

  mescc-tools-mini = run-kaem {
    name = "mescc-tools-mini";
    script = ./bundle-mescc-tools-mini.kaem;
    extraEnv = mini-kaem // { inherit mkdir0 ln0; };
  };

  mescc-tools-full = run-kaem {
    name = "mescc-tools-full";
    script = ./mescc-tools-full-kaem.kaem;
    buildInputs = [ mescc-tools-mini ];
  };

  mescc-tools-extra = run-kaem {
    name = "mescc-tools-extra";
    script = ./mescc-tools-extra.kaem;
    buildInputs = [ mescc-tools-mini mescc-tools-full ];
  };
in
{
  inherit mescc-tools-mini mescc-tools-full mescc-tools-extra;
}
