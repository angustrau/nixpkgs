{ stdenv, lib, callPackage, fetchurl, deno, writeText, runCommand, writeTextDir, makeWrapper }:
let
  lockToNix = lock:
    builtins.mapAttrs (url: sha256: fetchurl {
      name = lib.strings.sanitizeDerivationName url;
      inherit url sha256;
    }) lock;

  # deno2nix = { lock, outputHash ? "" }:
  #   let
  #     cache = createCache {  };
  #   in
  #     writeTextDir "lock.nix" ''
  #       { fetchurl }:
  #       {
  #         cacheOutputSHA256 = "",
  #         modules = {
  #           ${builtins.concatStringsSep "  " (builtins.attrValues packages)}
  #         };

  #       }
  #     '';

  deno2nix_ = lock:
    let
      lockJSON = lib.importJSON lock;
      packages = builtins.mapAttrs (url: sha256:
        ''
          "${url}" = fetchurl {
              name = "${lib.strings.sanitizeDerivationName url}";
              url = "${url}";
              sha256 = "${sha256}";
            };
        '') lockJSON;
    in
    ''
      { fetchurl }:
      {
        ${builtins.concatStringsSep "  " (builtins.attrValues packages)}
      }
    '';

  # 1ir89vdxzc9scn8g721xacf3wdr4dlv3pqffl1fz1910vv4j5z9m
  # metaLock = writeTextDir "lock-nix.json" (builtins.toJSON (lockToNix ./lock.json));

  createCache =
    let
      cacheHashLock = "1ir89vdxzc9scn8g721xacf3wdr4dlv3pqffl1fz1910vv4j5z9m";
      bootstrapCache =
        runCommand "deno-bootstrap-cache" {
          nativeBuildInputs = [ deno ];
          outputHashMode = "recursive";
          outputHashAlgo = "sha256";
          outputHash = cacheHashLock;
        } ''
          deno run --allow-net --allow-read --allow-write --allow-env --no-check --lock ${./lock.json} ${./createCache.ts} $out ${writeText "lock-nix.json" (builtins.toJSON (lockToNix (lib.importJSON ./lock.json)))}
          mkdir $out/gen
        '';
    in
      runCommand "createCache.js" {
        nativeBuildInputs = [ deno ];
        DENO_DIR = bootstrapCache;
      } ''
        deno bundle --no-check --lock ${./lock.json} ${./createCache.ts} $out
      '';

  mkDenoCache = 1; # TODO

  readOnlyCache = runCommand "deno-read-only-cache" {} ''
    mkdir -p $out/gen
  '';

  mkDenoModule = lib.makeOverridable ({
    name ? "${pname}-${version}",
    pname,
    version,
    entrypoint,
    lock,
    lockNix ? null,
    config ? null,
    importMap ? null,
    permissions,
    installName ? pname,
    moduleResolutions ? {},
    denoFlags ? [],
    denoInstallFlags ? [],
    denoTestFlags ? [],
    ...
  }@attrs:
  let
    configFile = if builtins.isAttrs config then builtins.toFile "config.json" (builtins.toJSON config) else config;
    importMapFile = if builtins.isAttrs importMap then builtins.toFile "import_map.json" (builtins.toJSON importMap) else importMap;
    flags = builtins.concatStringsSep " " (
      [
        "--lock=${lock}"
      ] ++ denoFlags);
    buildFlags = builtins.concatStringsSep " " (
      [
        "--lock=${lock}"
      ] ++ lib.optional (config != null) "--config=${configFile}"
        ++ lib.optional (importMap != null) "--import-map=${importMapFile}"
        # denoBuildFlags
      );
    installFlags = builtins.concatStringsSep " " (
      [
        "--root=${placeholder "out"}"
        "--name=${installName}"
        "--no-check"
        "--cached-only"
        "--no-remote"
      ] ++ permissions ++ denoInstallFlags
      );
    testFlags = builtins.concatStringsSep " " (permissions ++ denoTestFlags);

    _lockNix = if lockNix == null then {} else import lockNix {};
    cachePaths = writeText "cache.json" (builtins.toJSON ({
      lock = lockToNix ((lib.importJSON lock) // (_lockNix.wasmModules or {}));
      redirects = _lockNix.redirects or {};
    }));
  in
    stdenv.mkDerivation (builtins.removeAttrs attrs ["entrypoint" "lock" "config" "importMap" "permissions" "installName" "moduleResolutions" "denoFlags" "denoInstallFlags" "denoTestFlags"] // {

      nativeBuildInputs = [
        deno
        makeWrapper
      ] ++ (attrs.nativeBuildInputs or []);

      # preUnpack = ''
      #   # Deno's cache lookup relies on the file path so we must do everything from the $out directory
      #   mkdir -p $out/lib/deno/cache/gen
      #   export DENO_DIR=$out/lib/deno/cache
      #   cd $out/lib/deno

      #   ${attrs.preUnpack or ""}
      # '';

      configurePhase = attrs.configurePhase or ''
        runHook preConfigure

        # Populate offline cache with remote modules
        deno run --allow-net --allow-read --allow-write --allow-env ${createCache} $PWD/cache ${cachePaths}
        export DENO_DIR=$PWD/cache

        runHook postConfigure
      '';

      # doCheck = attrs.doCheck or true;
      # checkPhase = attrs.checkPhase or ''
      #   runHook preCheck

      #   deno test ${flags} ${testFlags}

      #   runHook postCheck
      # '';

      installPhase = attrs.installPhase or ''
        runHook preInstall

        mkdir -p $out/lib/deno

        # Populate cache with remote modules from nix store
        TMP_CACHE=$(mktemp -d)
        deno run --allow-net --allow-read --allow-write --allow-env ${createCache} $TMP_CACHE ${cachePaths}
        DENO_DIR=$TMP_CACHE deno vendor --output $out/lib/deno/vendor ${buildFlags} ${entrypoint}

        deno install --import-map $out/lib/deno/vendor/import_map.json ${installFlags} ${entrypoint}
        wrapProgram "$out/bin/${installName}" \
          --prefix PATH ":" "${deno}"

        runHook postInstall
      '';



      # TODO
      # DENO_JOBS
      # fetch from denolandx
      # check output for webassembly and local storage apis
      # make a deno2nix shell script escape hatch
      # does bundling break wasm and asset files?

      # docs notes
      # use dontInstall = true if not a binary
      # how to specify auth token
      # change output name with mainProgram
      # we must bundle. compatability issues with cache, especially when it's readonly
      # also avoids shipping things not in module graph.
      # dynamic imports probably dont work in build context


      meta = (if attrs ? "installPhase" then {} else {
        mainProgram = installName;
      }) // (attrs.meta or {});
    }));

    mkDenoScript = {
      entrypoint,
      sha256 ? null,
      ...
    }@attrs:
      assert !(lib.isDerivation entrypoint || builtins.isPath entrypoint) -> sha256 != null;
      mkDenoModule ({
        dontUnpack = true;
        dontBuild = true;
        doCheck = false;
        # denoInstallFlags = [
        #   "--location=${entrypoint}"
        # ] ++ (attrs.denoInstallFlags or []);
      } // (builtins.removeAttrs attrs [ "denoInstallFlags" ]));

  # lockJSON = ./lock.json;
  # lockNix = import ./lock.nix { inherit fetchurl; };
  # importMap = writeText "import_map.json" (builtins.toJSON {
  #   imports = lockNix // {
  #     "https://deno.land/x/deno_graph@0.33.0/lib/deno_graph_bg.wasm" = "/nix/store/hdl0fibsgb025lc0wbdkxq9y38zyhmy5-deno_graph_bg.wasm";
  #   };
  # });

  deno2nix = mkDenoScript {
    pname = "deno2nix";
    version = "0.1";
    entrypoint = ./deno2nix2.ts;
    lock = ./lock2.json;
    lockNix = ./lock2.nix;
    permissions = [
      "--allow-net"
      "--allow-run"
    ];
  };

  # testPackage = mkDenoModule {
  #   pname = "deno2nix";
  #   version = "0.1";
  #   src = ./.;
  #   entrypoint = "deno2nix.ts";
  #   lock = ./lock2.json;
  #   installBin = true;
  #   permissions = [];
  #   # dontUnpack = true;
  #   # dontInstall = true;
  #   doCheck = false;
  # };

  testPackage2 = mkDenoScript {
    pname = "test2";
    version = "0.1";
    entrypoint = ./t2.ts;
    lock = ./lock3.json;
    lockNix = ./lock3.nix;
    # config = {
    #   importMap = ./import_map.json;
    # };
    # importMap = {
    #   "imports" = {
    #     "https://deno.land/x/deno_cache/mod.ts" = "https://deno.land/x/deno_cache@0.4.1/mod.ts";
    #     "https://deno.land/x/deno_graph/mod.ts" = "https://deno.land/x/deno_graph@0.26.0/mod.ts";
    #   };
    # };
    # permissions = ["--allow-net"];
    permissions = [];
  };
in
{
  inherit createCache testPackage2 mkDenoModule mkDenoScript deno2nix;
}
# runCommand "cache-test" {} ''
#   export DENO_DIR=$out
#   ${deno}/bin/deno cache --reload --import-map ${importMap} --lock ${lockJSON} ${./stupid.ts}
# ''
