{ lib
, runCommand
, fetchurl
, tinycc
, gnumake
, gnupatch
, gnused
}:
let
  pname = "coreutils";
  version = "5.0";

  src = fetchurl {
    url = "mirror://gnu/coreutils/coreutils-${version}.tar.gz";
    sha256 = "10wq6k66i8adr4k08p0xmg87ff4ypiazvwzlmi7myib27xgffz62";
  };

  # Thanks to the live-bootstrap project!
  # See https://github.com/fosslinux/live-bootstrap/blob/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/coreutils-5.0/coreutils-5.0.kaem
  liveBootstrap = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/coreutils-5.0";

  patches = [
    # modechange.h uses functions defined in sys/stat.h, so we need to move it to
    # after sys/stat.h include.
    (fetchurl {
      url = "${liveBootstrap}/patches/modechange.patch";
      sha256 = "04xa4a5w2syjs3xs6qhh8kdzqavxnrxpxwyhc3qqykpk699p3ms5";
    })
    # mbstate_t is a struct that is required. However, it is not defined by mes libc.
    (fetchurl {
      url = "${liveBootstrap}/patches/mbstate.patch";
      sha256 = "0rz3c0sflgxjv445xs87b83i7gmjpl2l78jzp6nm3khdbpcc53vy";
    })
    # strcoll() does not exist in mes libc, change it to strcmp.
    (fetchurl {
      url = "${liveBootstrap}/patches/ls-strcmp.patch";
      sha256 = "0lx8rz4sxq3bvncbbr6jf0kyn5bqwlfv9gxyafp0541dld6l55p6";
    })
    # getdate.c is pre-compiled from getdate.y
    # At this point we don't have bison yet and in any case getdate.y does not
    # compile when generated with modern bison.
    (fetchurl {
      url = "${liveBootstrap}/patches/touch-getdate.patch";
      sha256 = "1xd3z57lvkj7r8vs5n0hb9cxzlyp58pji7d335snajbxzwy144ma";
    })
    # touch: add -h to change symlink timestamps, where supported
    (fetchurl {
      url = "${liveBootstrap}/patches/touch-dereference.patch";
      sha256 = "0wky5r3k028xwyf6g6ycwqxzc7cscgmbymncjg948vv4qxsxlfda";
    })
    # strcoll() does not exist in mes libc, change it to strcmp.
    ./expr-strcmp.patch
    # mes libc does not support locale
    ./sort-locale.patch
  ];
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
    gnupatch
    gnused
  ];

  meta = with lib; {
    description = "The GNU Core Utilities";
    homepage = "https://www.gnu.org/software/coreutils";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output coreutils.tar
  untar --file coreutils.tar
  rm coreutils.tar
  build=''${NIX_BUILD_TOP}/coreutils-${version}
  cd ''${build}

  # Patch
  ${lib.concatLines (map (f: "patch -Np0 -i ${f}") patches)}

  # Configure
  catm config.h
  cp lib/fnmatch_.h lib/fnmatch.h
  cp lib/ftw_.h lib/ftw.h
  cp lib/search_.h lib/search.h
  rm src/false.c
  rm src/dircolors.h

  # Build
  make -f ${./Makefile} PREFIX=''${out}

  # Check
  ./src/echo "Hello coreutils!"

  # Install
  ./src/mkdir -p ''${out}/bin
  make -f ${./Makefile} install PREFIX=''${out}
''
