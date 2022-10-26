import { parse, bold, red, assert } from "./deps.ts";

const USAGE = `
deno2nix
Convert a Deno lock file (lock.json) to nix. The output is written to standard output.

  deno2nix --lock ./lock.json

USAGE:
    deno2nix [OPTIONS]

OPTIONS:
    -h, --help
            Print help information

        --no-nix
            Hide the nix output

        --lock <FILE>
            Convert the specified lock file

            [default: ./lock.json]
`.trim();

const HEADER = `
{ fetchurl }:
{
`.trim();

const generatePackage = (file: string, sha256: string) => `
  "${file}" = fetchurl {
    name   = "${encodeURIComponent(file)}";
    url    = "${file}";
    sha256 = "${sha256}";
  };`;

const error = (message: string) => console.error(`${red(bold("error"))}: ${message}`);

if (import.meta.main) {
  const args = parse(Deno.args, {
    boolean: ["help", "no-nix"],
    string: ["lock"],
    alias: {
      "help": "h"
    },
    default: {
      "lock": "./lock.json",
    },
    unknown: (arg) => {
      error(`Found argument '${arg}' which wasn't expected, or isn't valid in this context\n`);
      console.log(USAGE);
      Deno.exit(1);
    }
  });

  if (args.help) {
    console.log(USAGE);
    Deno.exit(0);
  }

  const lockfile = Deno.readTextFileSync(args.lock);
  const json = JSON.parse(lockfile);

  // json example

  // {
  //   "https://deno.land/std@0.154.0/textproto/mod.ts": "3118d7a42c03c242c5a49c2ad91c8396110e14acca1324e7aaefd31a999b71a4",
  //   "https://deno.land/std@0.154.0/io/util.ts": "ae133d310a0fdcf298cea7bc09a599c49acb616d34e148e263bcb02976f80dee",
  //   "https://deno.land/std@0.154.0/async/delay.ts": "35957d585a6e3dd87706858fb1d6b551cb278271b03f52c5a2cb70e65e00c26a",
  //    ...
  // }

  // Checksums are computed via SHA256 https://github.com/denoland/deno/blob/1848f43aa1a2de0fabcde7970327baf37c177003/cli/checksum.rs

  let nix = HEADER;
  for (const [file, sha256] of Object.entries(json)) {
    assert(typeof sha256 === "string");
    nix += generatePackage(file, sha256);
  }
  nix += "\n}";

  const buffer = new TextEncoder().encode(nix);
  Deno.stdout.writeSync(buffer);
}
