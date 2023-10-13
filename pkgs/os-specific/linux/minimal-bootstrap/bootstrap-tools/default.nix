{ lib
, runCommand
, libc
, bash
, binutils
, bzip2
, coreutils
, diffutils
, findutils
, gawk
, gcc
, gnugrep
, gnumake
, gnused
, gnutar
, gzip
, patch
, patchelf
}:

runCommand "minimal-bootstrap-tools" {
  nativeBuildInputs = [
    coreutils
    findutils
  ];
} ''
  mkdir -p $out/bin $out/lib $out/libexec

  cp ${libc}/lib/* $out/lib
  cp -r ${libc}/include $out
  chmod -R u+w "$out"

  cp -r ${gcc}/bin/* $out/bin
  cp -r ${gcc}/include/* $out/include
  cp -r ${gcc}/lib/* $out/lib
  cp -r ${gcc}/libexec/* $out/libexec
  chmod -R u+w $out
  rm $out/bin/i686-unknown-linux-gnu-*
''
