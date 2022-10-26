import { parse } from "https://deno.land/std@0.154.0/flags/mod.ts";
import { error } from "https://deno.land/std@0.154.0/log/mod.ts";
import { type ModuleGraphJson, Module } from "https://deno.land/x/deno_graph@0.33.0/mod.ts";

const USAGE = `
deno2nix
Convert a Deno lock file (lock.json) to nix. The output is written to standard output.

  deno2nix --lock ./lock.json

USAGE:
  deno2nix [OPTIONS] --lock <FILE> <entrypoint>

ARGS:
  <entrypoint>

OPTIONS:
    -h, --help
            Print help information

    -c, --config <FILE>
            Use import map from configuration file ("deno.json", "deno.jsonc" or similar)

        --import-map <FILE>
            Use import map for module resolution

        --lock <FILE>
            Use the specified lock file

            [Required]
`.trim();

if (import.meta.main) {
  const args = parse(Deno.args, {
    boolean: ["help"],
    string: ["config", "import-map", "lock"],
    alias: {
      "help": "h",
      "config": "c"
    },
    unknown: (arg, key) => {
      if (key) {
        error(`Found argument '${arg}' which wasn't expected, or isn't valid in this context\n`);
        console.error(USAGE);
        Deno.exit(1);
      }
    }
  });

  if (args.help) {
    console.log(USAGE);
    Deno.exit(0);
  }

  if (!args._[0] || args._.length > 1) {
    error(`Exactly one entrypoint file must be specified`);
    Deno.exit(1);
  }
  const file = args._[0].toString();

  // Deno's lock file provides integrity checking. The format currently doesn't accomodate
  // reproducable module resolutions: the fully-resolved URL is saved, but not
  // the original import specifier. These mismatch when dependencies are under-specified
  // and, the registry redirects to a better resolution.
  //
  //    Eg.
  //        `https://deno.land/x/deno_cache/mod.ts`
  //    is resolved to
  //        `https://deno.land/x/deno_cache@0.4.1/mod.ts`
  //
  // We need to know these redirections to prevent Deno from reaching out to the
  // network during the build process.
  const subprocess = Deno.run({
    cmd:[
      "deno", "info", "--json",
      ...(args.config ? [ "--config", args.config ] : []),
      ...(args["no-config"] ? [ "--no-config" ] : []),
      ...(args["import-map"] ? [ "--import", args["import-map"] ] : []),
      file,
    ],
    stderr: "inherit",
    stdin: "null",
    stdout: "piped",
  });
  const output = await subprocess.output();
  const reader = new TextDecoder().decode(output);
  const moduleGraph = JSON.parse(reader) as ModuleGraphJson;
  const redirects = moduleGraph?.redirects ?? [];
  const nixRedirects = Object.entries(redirects).map(([initial, concrete]) => `"${initial}" = "${concrete}";`);

  // Reallyyyyy hacky way to try and find wasm dependencies that aren't in the module graph
  const nixWasmModules = [];
  for (const module of moduleGraph.modules) {
    if (module.specifier.endsWith(".generated.js")) {
      try {
        const wasmSpecifier = module.specifier.replace(".generated.js", "_bg.wasm");
        const response = await fetch(new URL(wasmSpecifier));
        if (response.ok) {
          console.error(`Found a WASM module: ${wasmSpecifier}`);
          const data = await response.arrayBuffer();
          const hashBuffer = await crypto.subtle.digest("SHA-256", data);
          const hashArray = Array.from(new Uint8Array(hashBuffer));
          const hashHex = hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');
          nixWasmModules.push(`"${wasmSpecifier}" = "${hashHex}";`);
          continue;
        }
      } catch {}
    }
  }

  // Define deps argument in case we need to pass in values in the future
  const nix = `
deps:
{
  redirects = {
    ${nixRedirects.join("\n    ")}
  };
  wasmModules = {
    ${nixWasmModules.join("\n    ")}
  };
}`.trim();



  console.log(nix);
}
