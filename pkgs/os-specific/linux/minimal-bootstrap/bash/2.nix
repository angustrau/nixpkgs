{ lib
, runCommand
, fetchurl
, tinycc
, gnumake
, gnupatch
, gzip
, coreutils
, heirloom-devtools
}:
let
  pname = "bash";
  version = "2.05b";

  src = fetchurl {
    url = "mirror://gnu/bash/bash-${version}.tar.gz";
    sha256 = "1r1z2qdw3rz668nxrzwa14vk2zcn00hw7mpjn384picck49d80xs";
  };

  # Thanks to the live-bootstrap project!
  # See https://github.com/fosslinux/live-bootstrap/blob/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/bash-2.05b/bash-2.05b.kaem
  liveBootstrap = "https://github.com/fosslinux/live-bootstrap/raw/1bc4296091c51f53a5598050c8956d16e945b0f5/sysa/bash-2.05b";

  main_mk = fetchurl {
    url = "${liveBootstrap}/mk/main.mk";
    sha256 = "0hj29q3pq3370p18sxkpvv9flb7yvx2fs96xxlxqlwa8lkimd0j4";
  };

  common_mk = fetchurl {
    url = "${liveBootstrap}/mk/common.mk";
    sha256 = "09rigxxf85p2ybnq248sai1gdx95yykc8jmwi4yjx389zh09mcr8";
  };

  builtins_mk = fetchurl {
    url = "${liveBootstrap}/mk/builtins.mk";
    sha256 = "0939dy5by1xhfmsjj6w63nlgk509fjrhpb2crics3dpcv7prl8lj";
  };

  patches = [
    (fetchurl {
      url = "${liveBootstrap}/patches/mes-libc.patch";
      sha256 = "0zksdjf6zbb3p4hqg6plq631y76hhhgab7kdvf7cnpk8bcykn12z";
    })
    (fetchurl {
      url = "${liveBootstrap}/patches/tinycc.patch";
      sha256 = "042d2kr4a8klazk1hlvphxr6frn4mr53k957aq3apf6lbvrjgcj2";
    })
    (fetchurl {
      url = "${liveBootstrap}/patches/missing-defines.patch";
      sha256 = "1q0k1kj5mrvjkqqly7ki5575a5b3hy1ywnmvhrln318yh67qnkj4";
    })
    (fetchurl {
      url = "${liveBootstrap}/patches/locale.patch";
      sha256 = "1p1q1slhafsgj8x4k0dpn9h6ryq5fwfx7dicbbxhldbw7zvnnbx9";
    })
    (fetchurl {
      url = "${liveBootstrap}/patches/dev-tty.patch";
      sha256 = "1315slv5f7ziajqyxg4jlyanf1xwd06xw14y6pq7xpm3jzjk55j9";
    })
  ];
in
runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc
    gnumake
    gnupatch
    gzip
    coreutils
    heirloom-devtools
  ];

  meta = with lib; {
    description = "GNU Bourne-Again Shell, the de facto standard shell on Linux";
    homepage = "https://www.gnu.org/software/bash";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = platforms.unix;
  };
} ''
  # Unpack
  cp ${src} bash.tar.gz
  gunzip bash.tar.gz
  untar --file bash.tar
  rm bash.tar
  build=''${NIX_BUILD_TOP}/bash-${version}
  cd ''${build}

  # Patch
  ${lib.concatLines (map (f: "patch -Np0 -i ${f}") patches)}

  # Configure
  cp ${main_mk} Makefile
  cp ${builtins_mk} builtins/Makefile
  cp ${common_mk} common.mk
  touch config.h
  touch include/version.h
  touch include/pipesize.h
  rm y.tab.c y.tab.h

  # Build
  make mkbuiltins
  cd builtins
  make libbuiltins.a
  cd ..
  make

  # Check
  ./bash --version

  # Install
  install -D bash ''${out}/bin/bash
  ln -s ''${out}/bin/bash ''${out}/bin/sh
''
