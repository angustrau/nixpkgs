{ fetchurl, runKaem, tcc }:
let
  version = "3.80";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/make/make-${version}.tar.gz";
    sha256 = "1pb7fb7fqf9wz9najm85qdma1xhxzf1rhj5gwrlzdsz2zm0hpcv4";
  };
in
runKaem {
  name = "gnumake-${version}";
  buildInputs = [ tcc ];
  scriptText = ''
    # SPDX-FileCopyrightText: 2021-22 fosslinux <fosslinux@aussies.space>
    #
    # SPDX-License-Identifier: GPL-3.0-or-later
    mkdir -p ''${out}/bin

    # Extract
    ungz --file ${src} --output make.tar
    untar --file make.tar

    cd make-${version}

    # Create .h files
    catm config.h

    # Compile
    tcc -c getopt.c
    tcc -c getopt1.c
    tcc -c -I. -Iglob -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DHAVE_STDINT_H ar.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DHAVE_FCNTL_H arscan.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DFILE_TIMESTAMP_HI_RES=0 commands.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DSCCS_GET=\"/nullop\" default.c
    tcc -c -I. -Iglob -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DHAVE_DIRENT_H dir.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART expand.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DFILE_TIMESTAMP_HI_RES=0 file.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -Dvfork=fork function.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART implicit.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DHAVE_DUP2 -DHAVE_STRCHR -Dvfork=fork job.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DLOCALEDIR=\"/fake-locale\" -DPACKAGE=\"fake-make\" -DHAVE_MKTEMP -DHAVE_GETCWD main.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DHAVE_STRERROR -DHAVE_VPRINTF misc.c
    tcc -c -I. -Iglob -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DINCLUDEDIR=\"\" read.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART -DFILE_TIMESTAMP_HI_RES=0 -DHAVE_FCNTL_H -DLIBDIR=\"\" remake.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART rule.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART signame.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART variable.c
    tcc -c -I. -DVERSION=\"${version}\" version.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART vpath.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART hash.c
    tcc -c -I. -DHAVE_INTTYPES_H -DHAVE_SA_RESTART remote-stub.c
    tcc -c -DHAVE_FCNTL_H getloadavg.c
    tcc -c -Iglob -DSTDC_HEADERS glob/fnmatch.c
    tcc -c -Iglob -DHAVE_STRDUP -DHAVE_DIRENT_H glob/glob.c

    # Link
    tcc -o ''${out}/bin/make getopt.o getopt1.o ar.o arscan.o commands.o default.o dir.o expand.o file.o function.o implicit.o job.o main.o misc.o read.o remake.o rule.o signame.o variable.o version.o vpath.o hash.o remote-stub.o getloadavg.o fnmatch.o glob.o

    # Test
    ''${out}/bin/make --version
  '';
}
