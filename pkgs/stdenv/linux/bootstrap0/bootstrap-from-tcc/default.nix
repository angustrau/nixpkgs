{ system, fetchurl, runKaem, coreutils, sed, tcc-seed, musl-seed }:

let
  # stage 0
  src = builtins.fetchTarball {
    url = "https://github.com/ZilchOS/bootstrap-from-tcc/archive/76fb04fccc51697371c60d7622b658db18d7449e.tar.gz";
    sha256 = "1m7cligxszr8dpm8hhqf7hxw21gkvqxj6fanj5i0jrkzqdvr71g2";
  };

  # these two use nixpkgs, but are fixed-output derivations with no dependencies
  protosrc = import ./0-protosrc.nix { inherit fetchurl runKaem coreutils sed musl-seed; };
  # in bootstrapping builds,
  # 0.nix is different and they're not coming from nixpkgs,
  # see recipes/4-rebootstrap-..sh

  # stage 1

  stage1 = (import ./1-stage1.nix) {
    inherit tcc-seed musl-seed protosrc system;
    recipesStage1ExtrasPath = "${src}/recipes/1-stage1";
    stage1cPath = "${src}/recipes/1-stage1.c";
  };  # multioutput, offers .protobusybox, .protomusl and .tinycc

  # stage 2

  mkCaDerivation = args: derivation (args // {
    inherit system;
    # __contentAddressed = true;
    outputHashAlgo = "sha256"; outputHashMode = "recursive";
  });

  mkDerivationStage2 =
    {name, script, buildInputPaths, extra ? {}}: mkCaDerivation {
      inherit name;
      builder = "${stage1.protobusybox}/bin/ash";
      args = [ "-uexc" (
        ''
          export PATH=${builtins.concatStringsSep ":" buildInputPaths}

          if [ -e /ccache/setup ]; then
            . /ccache/setup bootstrap-from-tcc/${name}
          fi

          unpack() (tar --strip-components=1 -xf "$@")

          if [ -n "$NIX_BUILD_CORES" ] && [ "$NIX_BUILD_CORES" != 0 ]; then
            NPROC=$NIX_BUILD_CORES
          elif [ "$NIX_BUILD_CORES" == 0 ] && [ -r /proc/cpuinfo ]; then
            NPROC=$(grep -c processor /proc/cpuinfo)
          else
            NPROC=1
          fi
        '' + script
      ) ];
    } // extra;

  static-gnumake = (import ./2a0-static-gnumake.nix) {
    inherit fetchurl mkDerivationStage2 stage1;
  };

  static-binutils = (import ./2a1-static-binutils.nix) {
    inherit fetchurl mkDerivationStage2 stage1 static-gnumake;
  };

  static-gnugcc4-c = (import ./2a2-static-gnugcc4-c.nix) {
    inherit fetchurl mkDerivationStage2 stage1 static-gnumake static-binutils;
  };

  intermediate-musl = (import ./2a3-intermediate-musl.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake static-binutils static-gnugcc4-c;
  };

  gnugcc4-cpp = (import ./2a4-gnugcc4-cpp.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake static-binutils static-gnugcc4-c;
    inherit intermediate-musl;
  };

  gnugcc10 = (import ./2a5-gnugcc10.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake static-binutils gnugcc4-cpp intermediate-musl;
  };

  linux-headers = (import ./2a6-linux-headers.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake static-binutils gnugcc10;
  };

  cmake = (import ./2a7-cmake.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake static-binutils gnugcc10 linux-headers;
  };

  python = (import ./2a8-python.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake static-binutils gnugcc10;
  };

  intermediate-clang = (import ./2a9-intermediate-clang.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake static-binutils intermediate-musl gnugcc10;
    inherit linux-headers cmake python;
  };

  musl = (import ./2b0-musl.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake intermediate-clang;
  };

  clang = (import ./2b1-clang.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake musl intermediate-clang;
    inherit linux-headers cmake python;
  };

  busybox = (import ./2b2-busybox.nix) {
    inherit fetchurl mkDerivationStage2;
    inherit stage1 static-gnumake musl clang linux-headers;
  };

in
{
  # exposed just because; don't rely on these
  inherit protosrc tcc-seed;
  inherit stage1;
  inherit static-gnumake static-binutils static-gnugcc4-c;
  inherit intermediate-musl gnugcc4-cpp gnugcc10;
  inherit linux-headers cmake python intermediate-clang;
  inherit musl clang;

  # public interface:
  libc = musl;        # some libc that TODO: doesn't depend on anything else
  toolchain = clang;  # some modern C/C++ compiler targeting this libc
  busybox = busybox;  # a freebie busybox TODO: depending on just libc
}
