import { createCache } from "https://deno.land/x/deno_cache/mod.ts";
import { createGraph } from "https://deno.land/x/deno_graph/mod.ts";

// create a cache where the location will be determined environmentally
const cache = createCache({
  root: await Deno.makeTempDir(),
});
// destructuring the two functions we need to pass to the graph
const { cacheInfo, load } = cache;
// create a graph that will use the cache above to load and cache dependencies
const graph = await createGraph("https://raw.githubusercontent.com/denoland/deno_std/main/version.ts", {
  cacheInfo,
  load,
});

// log out the console a similar output to `deno info` on the command line.
console.log(graph.toString());

console.log(import.meta.url);

if (Deno.args[0]) {
  const a = (() => "https://raw.githubusercontent.com/denoland/deno_std/main/signal/mod.ts")
  await import(a());
}

try {
  // import("blob:https://deno.land/x/deno_graph@0.33.0/lib/deno_graph_bg.wasm");
  // { assert: {
  //   type: ""
  // }}
} catch (error) {

}

// const value = localStorage.getItem("myDemo");
// console.log(`storage is ${value}`);
// localStorage.setItem("myDemo", "newval");
