{
  i686-linux = import <nix/fetchurl.nix> {
    url = "https://github.com/oriansj/bootstrap-seeds/raw/590202cfaec43826a29ef3f158d2735c4c574b16/POSIX/x86/hex0-seed";
    sha256 = "sha256-QU3RPGy51W7M2xnfFY1IqruKzusrSLU+L190ztN6JW8=";
    executable = true;
  };
}
