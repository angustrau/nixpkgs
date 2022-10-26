import { parse } from "https://deno.land/std@0.154.0/flags/mod.ts";
import { error, warning } from "https://deno.land/std@0.154.0/log/mod.ts";
import { toFileUrl, resolve } from "https://deno.land/std@0.154.0/path/mod.ts";
import { createCache } from "https://deno.land/x/deno_cache@0.4.1/mod.ts";
import { createGraph, parseModule, load as originalLoad, type LoadResponse } from "https://deno.land/x/deno_graph@0.34.0/mod.ts";
import { resolveImportMap, resolveModuleSpecifier } from "https://deno.land/x/importmap@0.2.1/mod.ts";
import { isSpecifierMap } from "https://deno.land/x/importmap@0.2.1/_util.ts";
import { parse as parseJSONC, ParseError } from "https://deno.land/x/jsonc@1/main.ts";

const USAGE = `
deno2nix
Augment a Deno lock file (lock.json) for . The output is written to standard output.

  deno2nix --lock lock.json https://deno.land/std@0.154.0/examples/welcome.ts

USAGE:
  deno2nix [OPTIONS] --lock=<FILE> <entrypoint>

ARGS:
  <entrypoint>

OPTIONS:
    -h, --help
            Print help information

        --import-map <FILE>
            Use an import map for module resolution

            See https://deno.land/manual@v1.25.1/linking_to_external_code/import_maps

        --lock <FILE>
            An existing lock file

            [Required]
`.trim();

function pathToURL(path: string) {
  try {
    return new URL(path);
  } catch {
    return toFileUrl(resolve(path));
  }
}

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
    error("Exactly one entrypoint file must be specified");
    Deno.exit(1);
  }
  const entrypoint = args._[0].toString();

  if (!args.lock) {
    error(`Please explicitly specify a lock file (lock.json or similar) to augment.
      If the upstream project doesn't have a lock file, you can create one with
      this command

          deno cache --lock=lock.json --lock-write${args.config ? ` --config=${args.config}` : ""}${args["import-map"] ? ` --import-map=${args["import-map"]}` : ""} "${entrypoint}"
    `);
    Deno.exit(1);
  }

  const rootSpecifier = pathToURL(entrypoint);
  const lockFile = await fetch(pathToURL(args.lock));
  const lock = await lockFile.json();

  const config = await (async () => {
    try {
      if (!args.config) return undefined;
      const file = await fetch(pathToURL(args.config));
      const text = await file.text();
      const errors: ParseError[] = [];
      const result = parseJSONC(text, errors);
      if (errors.length === 0) return result;
    } catch {
      return undefined;
    }
  })();

  const importMap = await (async() => {
    try {
      const path = args["import-map"] || config?.importMap;
      if (!path) return {};
      const url = pathToURL(path);
      const file = await fetch(url);
      const importMap= await file.json();
      const resolvedImportMap = resolveImportMap(importMap, url);
      return resolvedImportMap;
    } catch {
      return {};
    }
  })();

  const { cacheInfo, load } = createCache({
    allowRemote: true,
    cacheSetting: "reloadAll",
    // root: await Deno.makeTempDir(),
  });

  const resolver = (specifier: string, referrer: string) => {
    const resolved = resolveModuleSpecifier(
      specifier,
      importMap,
      new URL(referrer),
    );
    if (!resolved) {
      warning("no resolution");
    }
    return resolved;
  };

  const redirections: Record<string, string> = {};

  // We're going to try and match Deno CLI's behaviour here
  // Unfortunately only parts of it are exposed in libraries so we'll try
  // our best to match the code.
  const graph = await createGraph(rootSpecifier.href, {
    // kind: "codeOnly",
    resolve: resolver,
    load: async (specifier, isDynamic) => {
      if (isDynamic) {
        warning(`Dynamic import - ${specifier}`);
      }

      const result: LoadResponse | undefined = await originalLoad(specifier);
      // if (!result) return;
      if (!result) {
        warning(`magic ${specifier}`);
        return;
        // return {
        //   kind: "builtIn",
        //   specifier: "magicplace",

        // };
      };
      if (result.specifier !== specifier) {
        warning(`Got redirected - ${specifier} => ${result.specifier}`);
        redirections[specifier] = result.specifier;
      }
      return result;
    },
  });

  // log out the console a similar output to `deno info` on the command line.
  // console.log(graph.toString());

  for (const module of graph.modules) {
    console.log(module.specifier);
    // if (module.source.includes("WebAssembly.instantiate")) {
    //   warning(`Web assembly ${module.specifier}`);
    // }
    // const dep = parseModule(module.specifier, module.source, {
    //   resolve: (spec, ref) => {
    //     const b = resolver(spec, ref);
    //     error(b);
    //     return b;
    //   }
    // });
    if (module.dependencies) {
      for (const [specifier, dependency] of Object.entries(module.dependencies)) {
        // console.log(dependency)
        if (!dependency.code) warning(`yay no code ${specifier}`);
        if (dependency.isDynamic) warning(`yay dynamic ${specifier}`);
      }
    }
  }


  // It's important that we use Deno's user agent. Some CDNs such as Skypack
  // may serve different results

  // Test case for dynamic imports
  // deno cache --lock fresh-lock.json --lock-write --import-map https://github.com/lucacasonato/fresh-with-signals/raw/main/import_map.json https://github.com/lucacasonato/fresh-with-signals/raw/main/dev.ts

  // Lock github commit
  // https://docs.github.com/en/rest/commits/commits#get-a-commit

  // Deno's lock file provides integrity checking. The format currently doesn't accomodate
  // reproducable module resolutions: the fully-resolved URL is saved, but not
  // the original import specifier. These mismatch when dependencies are under-specified
  // and the registry redirects to a better resolution.
  //
  //    Eg.
  //        `https://deno.land/x/deno_cache/mod.ts`
  //    is resolved to
  //        `https://deno.land/x/deno_cache@0.4.1/mod.ts`
  //
  // We need to know these redirections to prevent Deno from reaching out to the
  // network during the build process.

}
