{ lib, system, runKaem, mescc }:
let
  bootstrapVersion = "0.9.26";
  bootstrapSrc = builtins.fetchTarball {
    url = "https://lilypond.org/janneke/tcc/tcc-0.9.26-1136-g5bba73cc.tar.gz";
    sha256 = "19q1bv48saiiwyc6na2sxw9h0vfs4kl6x7iyr8nb3r254vinx47i";
  };

  mainlineVersion = "unstable-2022-08-18";
  mainlineSrc = builtins.fetchTarball {
    url = "https://github.com/TinyCC/tinycc/archive/20a1ebf8544c9be86e0f22a760b7bbb907f923e1.tar.gz";
    sha256 = "0z8z0l172jx1fnrdpgndb1k837r266mgj960bswhaiiln5gwlx05";
  };

  targetFlag = {
    i686-linux = "TCC_TARGET_I386";
  }.${system};

  # Split into new derivation since the size of this line appeared to be causing
  # kaem to have parsing issues parsing the script?
  unified-libc = runKaem {
    name = "unified-libc-${bootstrapVersion}.c";
    scriptText = ''
      cd ${mescc.mesPrefix}/lib
      catm ''${out} ctype/isalnum.c ctype/isalpha.c ctype/isascii.c ctype/iscntrl.c ctype/isdigit.c ctype/isgraph.c ctype/islower.c ctype/isnumber.c ctype/isprint.c ctype/ispunct.c ctype/isspace.c ctype/isupper.c ctype/isxdigit.c ctype/tolower.c ctype/toupper.c dirent/closedir.c dirent/__getdirentries.c dirent/opendir.c dirent/readdir.c linux/access.c linux/brk.c linux/chdir.c linux/chmod.c linux/clock_gettime.c linux/close.c linux/dup2.c linux/dup.c linux/execve.c linux/fcntl.c linux/fork.c linux/fsync.c linux/fstat.c linux/_getcwd.c linux/getdents.c linux/getegid.c linux/geteuid.c linux/getgid.c linux/getpid.c linux/getppid.c linux/getrusage.c linux/gettimeofday.c linux/getuid.c linux/ioctl.c linux/ioctl3.c linux/kill.c linux/link.c linux/lseek.c linux/lstat.c linux/malloc.c linux/mkdir.c linux/mknod.c linux/nanosleep.c linux/_open3.c linux/pipe.c linux/_read.c linux/readlink.c linux/rename.c linux/rmdir.c linux/setgid.c linux/settimer.c linux/setuid.c linux/signal.c linux/sigprogmask.c linux/symlink.c linux/stat.c linux/time.c linux/unlink.c linux/waitpid.c linux/x86-mes-gcc/_exit.c linux/x86-mes-gcc/syscall.c linux/x86-mes-gcc/_write.c math/ceil.c math/fabs.c math/floor.c mes/abtod.c mes/abtol.c mes/__assert_fail.c mes/assert_msg.c mes/__buffered_read.c mes/cast.c mes/dtoab.c mes/eputc.c mes/eputs.c mes/fdgetc.c mes/fdgets.c mes/fdputc.c mes/fdputs.c mes/fdungetc.c mes/globals.c mes/itoa.c mes/ltoab.c mes/ltoa.c mes/__mes_debug.c mes/mes_open.c mes/ntoab.c mes/oputc.c mes/oputs.c mes/search-path.c mes/ultoa.c mes/utoa.c posix/alarm.c posix/buffered-read.c posix/execl.c posix/execlp.c posix/execv.c posix/execvp.c posix/getcwd.c posix/getenv.c posix/isatty.c posix/mktemp.c posix/open.c posix/raise.c posix/sbrk.c posix/setenv.c posix/sleep.c posix/unsetenv.c posix/wait.c posix/write.c stdio/clearerr.c stdio/fclose.c stdio/fdopen.c stdio/feof.c stdio/ferror.c stdio/fflush.c stdio/fgetc.c stdio/fgets.c stdio/fileno.c stdio/fopen.c stdio/fprintf.c stdio/fputc.c stdio/fputs.c stdio/fread.c stdio/freopen.c stdio/fscanf.c stdio/fseek.c stdio/ftell.c stdio/fwrite.c stdio/getc.c stdio/getchar.c stdio/perror.c stdio/printf.c stdio/putc.c stdio/putchar.c stdio/remove.c stdio/snprintf.c stdio/sprintf.c stdio/sscanf.c stdio/ungetc.c stdio/vfprintf.c stdio/vfscanf.c stdio/vprintf.c stdio/vsnprintf.c stdio/vsprintf.c stdio/vsscanf.c stdlib/abort.c stdlib/abs.c stdlib/alloca.c stdlib/atexit.c stdlib/atof.c stdlib/atoi.c stdlib/atol.c stdlib/calloc.c stdlib/__exit.c stdlib/exit.c stdlib/free.c stdlib/mbstowcs.c stdlib/puts.c stdlib/qsort.c stdlib/realloc.c stdlib/strtod.c stdlib/strtof.c stdlib/strtol.c stdlib/strtold.c stdlib/strtoll.c stdlib/strtoul.c stdlib/strtoull.c string/bcmp.c string/bcopy.c string/bzero.c string/index.c string/memchr.c string/memcmp.c string/memcpy.c string/memmem.c string/memmove.c string/memset.c string/rindex.c string/strcat.c string/strchr.c string/strcmp.c string/strcpy.c string/strcspn.c string/strdup.c string/strerror.c string/strlen.c string/strlwr.c string/strncat.c string/strncmp.c string/strncpy.c string/strpbrk.c string/strrchr.c string/strspn.c string/strstr.c string/strupr.c stub/atan2.c stub/bsearch.c stub/chown.c stub/__cleanup.c stub/cos.c stub/ctime.c stub/exp.c stub/fpurge.c stub/freadahead.c stub/frexp.c stub/getgrgid.c stub/getgrnam.c stub/getlogin.c stub/getpgid.c stub/getpgrp.c stub/getpwnam.c stub/getpwuid.c stub/gmtime.c stub/ldexp.c stub/localtime.c stub/log.c stub/mktime.c stub/modf.c stub/mprotect.c stub/pclose.c stub/popen.c stub/pow.c stub/rand.c stub/rewind.c stub/setbuf.c stub/setgrent.c stub/setlocale.c stub/setvbuf.c stub/sigaction.c stub/sigaddset.c stub/sigblock.c stub/sigdelset.c stub/sigemptyset.c stub/sigsetmask.c stub/sin.c stub/sys_siglist.c stub/system.c stub/sqrt.c stub/strftime.c stub/times.c stub/ttyname.c stub/umask.c stub/utime.c x86-mes-gcc/setjmp.c
    '';
  };

  mes-tcc = runKaem {
    name = "mes-tcc-${bootstrapVersion}";
    scriptText = ''
      ${mescc.mesccScript}

      catm config.h

      mescc \
        -S \
        -o tcc.s \
        -D BOOTSTRAP=1 \
        -I ${bootstrapSrc} \
        -D ${targetFlag}=1 \
        -D inline= \
        -D CONFIG_TCCDIR=\"''${out}/lib\" \
        -D CONFIG_SYSROOT=\"\" \
        -D CONFIG_TCC_CRTPREFIX=\"''${out}/lib\" \
        -D CONFIG_TCC_ELFINTERP=\"/mes/loader\" \
        -D CONFIG_TCC_SYSINCLUDEPATHS=\"${mescc.mescc-unwrapped}/include:${mescc.mesccConfigH}\" \
        -D TCC_LIBGCC=\"${mescc.mescc-unwrapped}/lib/libc.a\" \
        -D CONFIG_TCC_LIBTCC1_MES=0 \
        -D CONFIG_TCCBOOT=1 \
        -D CONFIG_TCC_STATIC=1 \
        -D CONFIG_USE_LIBGCC=1 \
        -D TCC_MES_LIBC=1 \
        -D TCC_VERSION=\"${bootstrapVersion}\" \
        -D ONE_SOURCE=1 \
        ${bootstrapSrc}/tcc.c

      mkdir -p ''${out}/bin ''${out}/lib
      mescc \
        -o ''${out}/bin/tcc \
        -L ${mescc.mescc-unwrapped} \
        tcc.s \
        -l c+tcc

      # Quick test
      ''${out}/bin/tcc -version

      # Recompile the mes C library
      cd ${mescc.mesPrefix}

      # crt1.o
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${out}/lib/crt1.o lib/linux/x86-mes-gcc/crt1.c

      # crtn.o
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${out}/lib/crtn.o lib/linux/x86-mes-gcc/crtn.c

      # crti.o
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${out}/lib/crti.o lib/linux/x86-mes-gcc/crti.c

      # libc+gcc.a
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${TMPDIR}/unified-libc.o ${unified-libc}
      ''${out}/bin/tcc -ar cr ''${out}/lib/libc.a ''${TMPDIR}/unified-libc.o

      # libtcc1.a
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${TMPDIR}/libtcc1.o lib/libtcc1.c
      ''${out}/bin/tcc -ar cr ''${out}/lib/libtcc1.a ''${TMPDIR}/libtcc1.o

      # libgetopt.a
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${TMPDIR}/getopt.o lib/posix/getopt.c
      ''${out}/bin/tcc -ar cr ''${out}/lib/libgetopt.a ''${TMPDIR}/getopt.o
    '';
  };

  buildBootN = {
    pname,
    version,
    src,
    prev,
    buildOptions,
    libtccBuildOptions,
  }: let
    options = lib.strings.concatStringsSep " " buildOptions;
    libtccOptions = lib.strings.concatStringsSep " " libtccBuildOptions;
  in
  runKaem {
    name = "${pname}-${version}";
    scriptText = ''
      catm config.h
      mkdir -p ''${out}/bin ''${out}/lib
      ${prev}/bin/tcc \
        -g \
        -v \
        -static \
        -o ''${out}/bin/tcc \
        -D BOOTSTRAP=1 \
        ${options} \
        -I . \
        -I ${src} \
        -D ${targetFlag}=1 \
        -D CONFIG_TCCDIR=\"''${out}/lib\" \
        -D CONFIG_TCC_CRTPREFIX=\"''${out}/lib\" \
        -D CONFIG_TCC_ELFINTERP=\"\" \
        -D CONFIG_TCC_LIBPATHS=\"''${out}/lib\" \
        -D CONFIG_TCC_SYSINCLUDEPATHS=\"${mescc.mesPrefix}/include:${mescc.mesccConfigH}:${src}/include\" \
        -D TCC_LIBGCC=\"libc.a\" \
        -D TCC_LIBTCC1=\"libtcc1.a\" \
        -D CONFIG_TCCBOOT=1 \
        -D CONFIG_TCC_STATIC=1 \
        -D CONFIG_USE_LIBGCC=1 \
        -D TCC_MES_LIBC=1 \
        -D TCC_VERSION=\"${version}\" \
        -D ONE_SOURCE=1 \
        -L ${prev}/lib \
        ${src}/tcc.c

      ''${out}/bin/tcc -v

      cd ${mescc.mesPrefix}
      # Recompile libc: crt{1,n,i}, libtcc.a, libc.a, libgetopt.a
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${out}/lib/crt1.o lib/linux/x86-mes-gcc/crt1.c
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${out}/lib/crtn.o lib/linux/x86-mes-gcc/crtn.c
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${out}/lib/crti.o lib/linux/x86-mes-gcc/crti.c
      ''${out}/bin/tcc -c -D TCC_TARGET_I386=1 ${libtccOptions} -o ''${TMPDIR}/libtcc1.o ${src}/lib/libtcc1.c
      ''${out}/bin/tcc -ar cr ''${out}/lib/libtcc1.a ''${TMPDIR}/libtcc1.o
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${TMPDIR}/unified-libc.o ${unified-libc}
      ''${out}/bin/tcc -ar cr ''${out}/lib/libc.a ''${TMPDIR}/unified-libc.o
      ''${out}/bin/tcc -c -D HAVE_CONFIG_H=1 -I include -I include/linux/x86 -o ''${TMPDIR}/getopt.o lib/posix/getopt.c
      ''${out}/bin/tcc -ar cr ''${out}/lib/libgetopt.a ''${TMPDIR}/getopt.o
    '';
  };

  boot0-tcc = buildBootN {
    pname = "boot0-tcc";
    version = bootstrapVersion;
    src = bootstrapSrc;
    prev = mes-tcc;
    buildOptions = [
      "-D HAVE_LONG_LONG_STUB=1"
      "-D HAVE_SETJMP=1"
    ];
    libtccBuildOptions = [
      "-D HAVE_LONG_LONG_STUB=1"
    ];
  };

  boot1-tcc = buildBootN {
    pname = "boot1-tcc";
    version = bootstrapVersion;
    src = bootstrapSrc;
    prev = boot0-tcc;
    buildOptions = [
      "-D HAVE_BITFIELD=1"
      "-D HAVE_LONG_LONG=1"
      "-D HAVE_SETJMP=1"
    ];
    libtccBuildOptions = [
      "-D HAVE_LONG_LONG=1"
    ];
  };

  boot2-tcc = buildBootN {
    pname = "boot2-tcc";
    version = bootstrapVersion;
    src = bootstrapSrc;
    prev = boot1-tcc;
    buildOptions = [
      "-D HAVE_BITFIELD=1"
      "-D HAVE_FLOAT_STUB=1"
      "-D HAVE_LONG_LONG=1"
      "-D HAVE_SETJMP=1"
    ];
    libtccBuildOptions = [
      "-D HAVE_FLOAT_STUB=1"
      "-D HAVE_LONG_LONG=1"
    ];
  };

  boot3-tcc = buildBootN {
    pname = "boot3-tcc";
    version = bootstrapVersion;
    src = bootstrapSrc;
    prev = boot2-tcc;
    buildOptions = [
      "-D HAVE_BITFIELD=1"
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
      "-D HAVE_SETJMP=1"
    ];
    libtccBuildOptions = [
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
    ];
  };

  # Rebuild final bootstrappable version
  boot4-tcc = buildBootN {
    pname = "boot4-tcc";
    version = bootstrapVersion;
    src = bootstrapSrc;
    prev = boot3-tcc;
    buildOptions = [
      "-D HAVE_BITFIELD=1"
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
      "-D HAVE_SETJMP=1"
    ];
    libtccBuildOptions = [
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
    ];
  };

  tccdefs = runKaem {
    name = "tccdefs-${mainlineVersion}";
    scriptText = ''
      mkdir ''${out}
      ${boot4-tcc}/bin/tcc -static -DC2STR -o c2str ${mainlineSrc}/conftest.c
      ./c2str ${mainlineSrc}/include/tccdefs.h ''${out}/tccdefs_.h
    '';
  };

  # Use bootstrappable TCC to build latest mainline
  boot5-tcc = buildBootN {
    pname = "boot5-tcc";
    version = mainlineVersion;
    src = mainlineSrc;
    prev = boot4-tcc;
    buildOptions = [
      "-D HAVE_BITFIELD=1"
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
      "-D HAVE_SETJMP=1"
      "-D CONFIG_TCC_PREDEFS=1"
      "-I ${tccdefs}"
      "-D CONFIG_TCC_SEMLOCK=0"
    ];
    libtccBuildOptions = [
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
      "-D CONFIG_TCC_PREDEFS=1"
      "-I ${tccdefs}"
      "-D CONFIG_TCC_SEMLOCK=0"
    ];
  };

  tcc = buildBootN {
    pname = "tcc";
    version = mainlineVersion;
    src = mainlineSrc;
    prev = boot5-tcc;
    buildOptions = [
      "-std=c99"
      "-D HAVE_BITFIELD=1"
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
      "-D HAVE_SETJMP=1"
      "-D CONFIG_TCC_PREDEFS=1"
      "-I ${tccdefs}"
      "-D CONFIG_TCC_SEMLOCK=0"
    ];
    libtccBuildOptions = [
      "-D HAVE_FLOAT=1"
      "-D HAVE_LONG_LONG=1"
      "-D CONFIG_TCC_PREDEFS=1"
      "-I ${tccdefs}"
      "-D CONFIG_TCC_SEMLOCK=0"
    ];
  };
in
tcc // {
  src = mainlineSrc;
  version = mainlineVersion;
  boot4-tcc = boot4-tcc;
  inherit bootstrapSrc bootstrapVersion;
}
