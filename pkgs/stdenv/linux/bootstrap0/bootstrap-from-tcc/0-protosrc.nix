{ fetchurl, runKaem, coreutils, sed, musl-seed }:
let
  muslSrc = builtins.fetchTarball {
    url = "http://musl.libc.org/releases/musl-1.2.2.tar.gz";
    sha256 = "0c1mbadligmi02r180l0qx4ixwrf372zl5mivb1axmjgpd612ylp";
  };

  tinyccSrc = builtins.fetchTarball {
    url = "https://github.com/TinyCC/tinycc/archive/da11cf651576f94486dbd043dbfcde469e497574.tar.gz";
    sha256 = "1h51lz6wg3wq5la7x5d32idc8cpp1n3cz09z18gcziz3azzlqrrd";
  };

  busyboxSrc = builtins.fetchTarball {
    url = "https://busybox.net/downloads/busybox-1.34.1.tar.bz2";
    sha256 = "12ygw5p77h63z68kmss07r28y2gbc7p6jzg5adi906lv1dk0jang";
  };
in
runKaem {
  name = "protosrc";
  buildInputs = [ coreutils sed ];
  scriptText = ''
    mkdir ''${out}

    echo "###  unpacking protomusl sources..."
    cp -r --preserve=mode ${muslSrc} ''${out}/protomusl
    chmod -R a+w ''${out}/protomusl

    echo "###  unpacking tinycc sources..."
    cp -r --preserve=mode ${tinyccSrc} ''${out}/tinycc
    chmod -R a+w ''${out}/tinycc

    echo "###  unpacking protobusybox sources..."
    cp -r --preserve=mode ${busyboxSrc} ''${out}/protobusybox
    chmod -R a+w ''${out}/protobusybox

    echo "###  patching up protomusl stage 1 sources..."
    cd ''${out}/protomusl/
    # eliminiate a source path reference
    sed -i "s/__FILE__/\"__FILE__\"/" include/assert.h
    # two files have to be generated with host sed
    mkdir -p host-generated/sed1/bits host-generated/sed2/bits
    cp ${musl-seed.alltypes_h} host-generated/sed1/bits/alltypes.h
    cp ${musl-seed.syscall_h} host-generated/sed2/bits/syscall.h
    # more frivolous patching
    cp ${builtins.toFile "version" "#define VERSION \"1.2.2\"\n"} src/internal/version.h
    replace --file src/signal/i386/sigsetjmp.s --output src/signal/i386/sigsetjmp.s --match-on "jecxz 1f" --replace-with "cmp %ecx,0\nje 1f"
    # *BIG URGH*
    rm -f src/signal/restore.c
    # *BIG URGH #2*
    rm -f src/thread/clone.c
    # possible double-define
    rm -f src/thread/__set_thread_area.c
    # double-define
    rm -f src/thread/__unmapself.c
    # tcc-incompatible
    rm -f src/math/sqrtl.c
    # sqrtl dep
    rm -f src/math/acoshl.c src/math/acosl.c src/math/asinhl.c src/math/asinl.c src/math/hypotl.c
    sed -i "s|posix_spawn(&pid, \"/bin/sh\",|posix_spawnp(\\&pid, \"sh\",|" \
      src/stdio/popen.c src/process/system.c
    sed -i "s|execl(\"/bin/sh\", \"sh\", \"-c\",|execlp(\"sh\", \"-c\",|"\
      src/misc/wordexp.c

    echo "###  patching up tinycc stage 1 sources..."
    cd ''${out}/tinycc/
    touch config.h
    # eliminiate a source path reference
    sed -i "s/__FILE__/\"__FILE__\"/" tcc.h
    # don't hardcode paths when compiling asm files
    sed -i "s/SHN_ABS, file->filename);/SHN_ABS, \"FILE stub\");/" tccgen.c
    # break a circular dependency
    sed -i "s/abort();//" lib/va_list.c

    echo "###  patching up protobusybox stage 1 sources..."
    cd ''${out}/protobusybox/
    touch include/NUM_APPLETS.h
    touch include/common_bufsiz.h
    # eliminiate a source path reference
    sed -i "s/__FILE__/\"__FILE__\"/" miscutils/fbsplash.c include/libbb.h
    # already fixed in an unreleased version
    sed -i "s/extern struct test_statics \*const test_ptr_to_statics/extern struct test_statics *BB_GLOBAL_CONST test_ptr_to_statics/" coreutils/test.c

    echo "###  done"
  '';
}
