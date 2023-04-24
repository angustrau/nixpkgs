{ fetchurl, runAsh, musl-tcc, gnumake, patch }:
let
  version = "5.1.8";
  src = fetchurl {
    url = "mirror://gnu/bash/bash-${version}.tar.gz";
    sha256 = "1gnn2d0j2cnx1xg80nw12c87m68wa4cjs95xjw5817x2n6dmryqc";
  };
in
runAsh {
  name = "bash-${version}";
  buildInputs = [ musl-tcc gnumake patch ];
  scriptText = ''
    tar --strip-components=1 -xf ${src}

    patch -Np0 -i ${./patches/extern.patch}
    patch -Np0 -i ${./patches/dev-tty.patch}

    export CC=tcc
    export LD=tcc
    export AR="tcc -ar"
    export CFLAGS="-g -static -DNON_INTERACTIVE_LOGIN_SHELLS -DSYS_BASHRC='\"/etc/bashrc\"' -DSYS_BASH_LOGOUT='\"/etc/bash_logout\"' -DDEFAULT_PATH_VALUE='\"/no-such-path\"' -DSTANDARD_UTILS_PATH='\"/no-such-path\"'"
    export bash_cv_job_control_missing=nomissing
    export bash_cv_sys_named_pipes=nomissing
    export bash_cv_getcwd_malloc=yes
    export bash_cv_pgrp_pipe=yes
    export bash_cv_dev_stdin=present
    export bash_cv_dev_fd=standard
    export ac_cv_func_alloca_works=yes

    # export ac_cv_func_gettimeofday=yes

    ash ./configure --without-bash-malloc --disable-nls --prefix=''$out --build=i686-unknown-linux-musl
    make
    make install

    rm -rf ''$out/share ''$out/bin/bashbug
    ln -s ''$out/bin/bash ''$out/bin/sh
    cp config.log ''$out/
  '';
}
