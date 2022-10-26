{ stdenv, lib, deno }:
let
  mkDenoScript = {
    entrypoint,
    entrypointHash ? null,
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
in
{
  inherit mkDenoScript;
}
