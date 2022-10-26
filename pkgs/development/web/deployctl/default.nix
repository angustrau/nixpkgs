{ lib, stdenv, fetchurl, deno2nix }:

deno2nix.mkDenoScript rec {
  pname = "deployctl";
  version = "1.3.0";

  entrypoint = "https://deno.land/x/deploy@${version}/deployctl.ts";
  sha256 = "1n6fvnfq98nipwq6z4q2c2q1ry5wawhz1k9hxhfmxl7xjhysrqv0";
  lock = ./lock.json;

  permissions = [
    "--allow-read"
    "--allow-write"
    "--allow-env"
    "--allow-net"
    "--allow-run"
  ];

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
}
