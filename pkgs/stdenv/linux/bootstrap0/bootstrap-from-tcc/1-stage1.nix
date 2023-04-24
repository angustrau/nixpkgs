{ system, tcc-seed, musl-seed, protosrc, recipesStage1ExtrasPath, stage1cPath }:

derivation {
  name = "bootstrap-1-stage1";
  builder = "${tcc-seed}/bin/tcc";
  args = [
      "-nostdinc" "-Werror"
      "-I${musl-seed}/include"
      "-static"
      "-I${recipesStage1ExtrasPath}"
      "-DINSIDE_NIX"
      "-DPROTOSRC=\"${protosrc}\""
      "-DTCC_SEED=\"${tcc-seed}/bin/tcc\""
      "-DRECIPES_STAGE1=\"${recipesStage1ExtrasPath}\""
      "-DTMP_STAGE1=\"/build\""
      "-DSTORE_PROTOBUSYBOX=\"${placeholder "protobusybox"}\""
      "-DSTORE_PROTOMUSL=\"${placeholder "protomusl"}\""
      "-DSTORE_TINYCC=\"${placeholder "tinycc"}\""
      "-run"
      ./1-stage1.c
  ];
  outputs = [ "protobusybox" "protomusl" "tinycc" ];
  outputHashAlgo = "sha256"; outputHashMode = "recursive";
  inherit system;
}
