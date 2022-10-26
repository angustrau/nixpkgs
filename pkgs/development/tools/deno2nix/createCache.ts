// Populate Deno cache from nix store

import { createCache } from "https://deno.land/x/deno_cache@0.4.1/mod.ts";

if (import.meta.main) {
  const cachePath = Deno.args[0];
  const data = JSON.parse(await Deno.readTextFile(Deno.args[1]));
  const depsMap: Record<string, string | undefined> = data.lock;
  const redirects: Record<string, string | undefined> = data?.lockNix?.redirects ?? {};

  // Silence noisy output from deno_cache library
  console.log = () => {};

  globalThis.fetch = async (input) => {
    let url;
    if (input instanceof URL) {
      url = input.href;
    } else if (input instanceof Request) {
      url = input.url;
    } else {
      url = input;
    }
    const redirect = redirects[url];
    const storePath = depsMap[url] || (redirect ? depsMap[redirect] : undefined);
    if (!storePath) {
      throw new Error(`${url} not in nix store`);
    }

    const file = await Deno.open(storePath, { read: true });
    const response = new Response(file.readable, {
      status: 200,
      statusText: `Found ${input}`,
      headers: {},
    });
    Object.defineProperty(response, "url", { value: redirect || input.toString() });
    return response;
  };

  const { cacheInfo, load } = createCache({
    allowRemote: true,
    cacheSetting: "reloadAll",
    root: cachePath,
  });

  for (const [path, store] of Object.entries(depsMap)) {
    const resp = await load(path);
    const info = cacheInfo(path);
    if (!resp || !(info?.local)) {
      console.error(`Failed to load ${path} (${store}) into the cache`);
      Deno.exit(1);
    }
    console.error(`Inserted ${store} into cache at ${info.local}`);
  }

  for (const [initial, concrete] of Object.entries(redirects)) {
    const resp = await load(initial);
    const info = cacheInfo(initial);
    if (!resp || !(info?.local)) {
      console.error(`Failed to load ${initial} (redirect to ${concrete}) into the cache`);
      Deno.exit(1);
    }
    console.error(`Inserted redirect ${initial} => ${concrete} into cache at ${info.local}`);
  }
}
