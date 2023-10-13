{ hostPlatform }:
{
  mesArch = {
    "i686-linux"    = "x86";
    "x86_64-linux"  = "x86_64";
  }.${hostPlatform.system} or (throw "Unsupported system: ${hostPlatform.system}");
}
