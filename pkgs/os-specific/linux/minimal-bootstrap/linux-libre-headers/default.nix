{ lib
, hostPlatform
, fetchurl
, bash
, gnutar
, xz
}:
let
  pname = "linux-libre-headers";
  version = "4.14.67";

  src = fetchurl {
    url = "mirror://gnu/gnu/guix/bootstrap/i686-linux/20190815/linux-libre-headers-stripped-4.14.67-i686-linux.tar.xz";
    sha256 = "0sm2z9x4wk45bh6qfs94p0w1d6hsy6dqx9sw38qsqbvxwa1qzk8s";
  };
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    gnutar
    xz
  ];

  meta = with lib; {
    description = "Header files and scripts for Linux kernel";
    license = licenses.gpl2;
    maintainers = teams.minimal-bootstrap.members;
    platforms = platforms.linux;
  };
} ''
  # Unpack
  cp ${src} linux-headers.tar.xz
  # suppress warning. "Cannot set the file group: sterror: unknown error"
  unxz linux-headers.tar.xz || true
  tar xf linux-headers.tar

  # Install
  mkdir $out
  mv include $out
''
