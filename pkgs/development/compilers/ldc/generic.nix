{ lib, stdenv, fetchurl, fetchpatch, cmake, ninja, llvm, curl, tzdata
, libconfig, lit, gdb, unzip, darwin, bash
, callPackage, makeWrapper, runCommand, targetPackages
, bootstrapping ? false
, ldcBootstrap ? null
, version, sha256
}:

assert !bootstrapping -> ldcBootstrap != null;

let
  pathConfig = runCommand "ldc-lib-paths" {} ''
    mkdir $out
    echo ${tzdata}/share/zoneinfo/ > $out/TZDatabaseDirFile
    echo ${curl.out}/lib/libcurl${stdenv.hostPlatform.extensions.sharedLibrary} > $out/LibcurlPathFile
  '';

in

stdenv.mkDerivation rec {
  pname = "ldc";
  inherit version;

  src = fetchurl {
    url = "https://github.com/ldc-developers/ldc/releases/download/v${version}/ldc-${version}-src.tar.gz";
    inherit sha256;
  };

  patches = lib.optionals bootstrapping [
    # Backported from ltsmaster
    # https://github.com/ldc-developers/ldc/issues/2982
    (fetchpatch {
      url = "https://github.com/ldc-developers/ldc/commit/d442f9f67f49362c1ba28c874d2569cf68236498.patch";
      hash = "sha256-xOOKocf/TeK+EazCC121eZTbmB2K+8C1iRvzKKusmTE=";
    })
  ];

  # https://issues.dlang.org/show_bug.cgi?id=19553
  hardeningDisable = [ "fortify" ];

  postUnpack = ''
    patchShebangs .
  ''
  + lib.optionalString (!bootstrapping && false) ''
      rm ldc-${version}-src/tests/dmd/fail_compilation/mixin_gc.d
      rm ldc-${version}-src/tests/dmd/runnable/xtest46_gc.d
      rm ldc-${version}-src/tests/dmd/runnable/testptrref_gc.d

      # test depends on current year
      rm ldc-${version}-src/tests/dmd/compilable/ddocYear.d
  ''
  + lib.optionalString (stdenv.hostPlatform.isDarwin && !bootstrapping) ''
      # https://github.com/NixOS/nixpkgs/issues/34817
      rm -r ldc-${version}-src/tests/plugins/addFuncEntryCall
  '';

  postPatch = lib.optionalString (!bootstrapping && false) ''
    # Setting SHELL=$SHELL when dmd testsuite is run doesn't work on Linux somehow
    substituteInPlace tests/dmd/Makefile --replace "SHELL=/bin/bash" "SHELL=${bash}/bin/bash"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace runtime/phobos/std/socket.d --replace "assert(ih.addrList[0] == 0x7F_00_00_01);" ""
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace runtime/phobos/std/socket.d --replace "foreach (name; names)" "names = []; foreach (name; names)"
  '';

  nativeBuildInputs = [
    cmake lit lit.python llvm.dev makeWrapper ninja unzip
  ]
  ++ lib.optionals (!bootstrapping) [ ldcBootstrap ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Foundation
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    # https://github.com/NixOS/nixpkgs/pull/36378#issuecomment-385034818
    gdb
  ];

  buildInputs = [ curl tzdata ] ++ lib.optionals bootstrapping [ libconfig ];

  cmakeFlags = [
    "-DD_FLAGS=-d-version=TZDatabaseDir;-d-version=LibcurlPath;-J${pathConfig}"
  ] ++ lib.optionals (!bootstrapping) [
    "-DLDC_ENABLE_PLUGINS=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  postConfigure = ''
    export DMD=$PWD/bin/ldmd2
  '';

  makeFlags = [ "DMD=$DMD" ];

  fixNames = lib.optionalString stdenv.hostPlatform.isDarwin  ''
    fixDarwinDylibNames() {
      local flags=()

      for fn in "$@"; do
        flags+=(-change "$(basename "$fn")" "$fn")
      done

      for fn in "$@"; do
        if [ -L "$fn" ]; then continue; fi
        echo "$fn: fixing dylib"
        install_name_tool -id "$fn" "''${flags[@]}" "$fn"
      done
    }

    fixDarwinDylibNames $(find "$(pwd)/lib" -name "*.dylib")
    export DYLD_LIBRARY_PATH=$(pwd)/lib
  '';

  # https://github.com/ldc-developers/ldc/issues/2497#issuecomment-459633746
  additionalExceptions = lib.optionalString stdenv.hostPlatform.isDarwin
    "|druntime-test-shared";

  checkPhase = ''
    # Build default lib test runners
    ninja -j$NIX_BUILD_CORES all-test-runners

    ${fixNames}

    # Run dmd testsuite
    export DMD_TESTSUITE_MAKE_ARGS="-j$NIX_BUILD_CORES DMD=$DMD"
    ctest -V -R "dmd-testsuite"

    # Build and run LDC D unittests.
    ctest --output-on-failure -R "ldc2-unittest"

    # Run LIT testsuite.
    ctest -V -R "lit-tests"

    # Run default lib unittests
    ctest -j$NIX_BUILD_CORES --output-on-failure -E "ldc2-unittest|lit-tests|dmd-testsuite${additionalExceptions}"
  '';

  postInstall = ''
    wrapProgram $out/bin/ldc2 \
        --prefix PATH ":" "${targetPackages.stdenv.cc}/bin" \
        --set-default CC "${targetPackages.stdenv.cc}/bin/cc"
   '';

  passthru.__bootstrap = ldcBootstrap;

  meta = with lib; {
    description = "The LLVM-based D compiler";
    homepage = "https://github.com/ldc-developers/ldc";
    # from https://github.com/ldc-developers/ldc/blob/master/LICENSE
    license = with licenses; [ bsd3 boost mit ncsa gpl2Plus ];
    maintainers = with maintainers; [ ThomasMader lionello jtbx ];
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin" ]
      # bootstrap compiler doesn't support aarch64-darwin
      ++ lib.optionals (!bootstrapping) [ "aarch64-darwin" ];
  };
}
