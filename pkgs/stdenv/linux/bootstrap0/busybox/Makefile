# Usage:
#
#   make [ all | clean ] ...
#   ... CC=gcc       use gcc
#   ... GCC=3        for older mingw-gcc 3.x

CC ?= tcc

S = \
 applets/applets.c                                   \
 archival/ar.c                                       \
 archival/bbunzip.c                                  \
 archival/bzip2.c                                    \
 archival/cpio.c                                     \
 archival/dpkg.c                                     \
 archival/dpkg_deb.c                                 \
 archival/gzip.c                                     \
 archival/lzop.c                                     \
 archival/rpm.c                                      \
 archival/tar.c                                      \
 archival/unzip.c                                    \
 archival/libarchive/common.c                        \
 archival/libarchive/data_align.c                    \
 archival/libarchive/data_extract_all.c              \
 archival/libarchive/data_extract_to_stdout.c        \
 archival/libarchive/data_skip.c                     \
 archival/libarchive/decompress_bunzip2.c            \
 archival/libarchive/decompress_gunzip.c             \
 archival/libarchive/decompress_uncompress.c         \
 archival/libarchive/decompress_unlzma.c             \
 archival/libarchive/decompress_unxz.c               \
 archival/libarchive/filter_accept_all.c             \
 archival/libarchive/filter_accept_list.c            \
 archival/libarchive/filter_accept_list_reassign.c   \
 archival/libarchive/filter_accept_reject_list.c     \
 archival/libarchive/find_list_entry.c               \
 archival/libarchive/get_header_ar.c                 \
 archival/libarchive/get_header_cpio.c               \
 archival/libarchive/get_header_tar.c                \
 archival/libarchive/get_header_tar_bz2.c            \
 archival/libarchive/get_header_tar_gz.c             \
 archival/libarchive/get_header_tar_lzma.c           \
 archival/libarchive/get_header_tar_xz.c             \
 archival/libarchive/header_list.c                   \
 archival/libarchive/header_skip.c                   \
 archival/libarchive/header_verbose_list.c           \
 archival/libarchive/init_handle.c                   \
 archival/libarchive/lzo1x_1.c                       \
 archival/libarchive/lzo1x_1o.c                      \
 archival/libarchive/lzo1x_d.c                       \
 archival/libarchive/open_transformer.c              \
 archival/libarchive/seek_by_jump.c                  \
 archival/libarchive/seek_by_read.c                  \
 archival/libarchive/unpack_ar_archive.c             \
 archival/libarchive/unsafe_prefix.c                 \
 archival/libarchive/unsafe_symlink_target.c         \
 console-tools/clear.c                               \
 console-tools/reset.c                               \
 coreutils/basename.c                                \
 coreutils/cat.c                                     \
 coreutils/chmod.c                                   \
 coreutils/cksum.c                                   \
 coreutils/comm.c                                    \
 coreutils/cp.c                                      \
 coreutils/cut.c                                     \
 coreutils/date.c                                    \
 coreutils/dd.c                                      \
 coreutils/df.c                                      \
 coreutils/dirname.c                                 \
 coreutils/dos2unix.c                                \
 coreutils/du.c                                      \
 coreutils/echo.c                                    \
 coreutils/env.c                                     \
 coreutils/expand.c                                  \
 coreutils/expr.c                                    \
 coreutils/factor.c                                  \
 coreutils/false.c                                   \
 coreutils/fold.c                                    \
 coreutils/head.c                                    \
 coreutils/id.c                                      \
 coreutils/link.c                                    \
 coreutils/ln.c                                      \
 coreutils/logname.c                                 \
 coreutils/ls.c                                      \
 coreutils/md5_sha1_sum.c                            \
 coreutils/mkdir.c                                   \
 coreutils/mktemp.c                                  \
 coreutils/mv.c                                      \
 coreutils/nl.c                                      \
 coreutils/od.c                                      \
 coreutils/paste.c                                   \
 coreutils/printenv.c                                \
 coreutils/printf.c                                  \
 coreutils/pwd.c                                     \
 coreutils/readlink.c                                \
 coreutils/realpath.c                                \
 coreutils/rm.c                                      \
 coreutils/rmdir.c                                   \
 coreutils/seq.c                                     \
 coreutils/shred.c                                   \
 coreutils/shuf.c                                    \
 coreutils/sleep.c                                   \
 coreutils/sort.c                                    \
 coreutils/split.c                                   \
 coreutils/stat.c                                    \
 coreutils/sum.c                                     \
 coreutils/sync.c                                    \
 coreutils/tac.c                                     \
 coreutils/tail.c                                    \
 coreutils/tee.c                                     \
 coreutils/test.c                                    \
 coreutils/test_ptr_hack.c                           \
 coreutils/timeout.c                                 \
 coreutils/touch.c                                   \
 coreutils/tr.c                                      \
 coreutils/true.c                                    \
 coreutils/truncate.c                                \
 coreutils/uname.c                                   \
 coreutils/uniq.c                                    \
 coreutils/unlink.c                                  \
 coreutils/usleep.c                                  \
 coreutils/uudecode.c                                \
 coreutils/uuencode.c                                \
 coreutils/wc.c                                      \
 coreutils/whoami.c                                  \
 coreutils/yes.c                                     \
 coreutils/libcoreutils/cp_mv_stat.c                 \
 debianutils/pipe_progress.c                         \
 debianutils/which.c                                 \
 editors/awk.c                                       \
 editors/cmp.c                                       \
 editors/diff.c                                      \
 editors/ed.c                                        \
 editors/patch.c                                     \
 editors/sed.c                                       \
 editors/vi.c                                        \
 findutils/find.c                                    \
 findutils/grep.c                                    \
 findutils/xargs.c                                   \
 libbb/appletlib.c                                   \
 libbb/ask_confirmation.c                            \
 libbb/auto_string.c                                 \
 libbb/bb_bswap_64.c                                 \
 libbb/bb_cat.c                                      \
 libbb/bb_getgroups.c                                \
 libbb/bb_getsockname.c                              \
 libbb/bb_pwd.c                                      \
 libbb/bb_qsort.c                                    \
 libbb/bb_strtonum.c                                 \
 libbb/chomp.c                                       \
 libbb/common_bufsiz.c                               \
 libbb/compare_string_array.c                        \
 libbb/concat_path_file.c                            \
 libbb/concat_subpath_file.c                         \
 libbb/copy_file.c                                   \
 libbb/copyfd.c                                      \
 libbb/crc32.c                                       \
 libbb/default_error_retval.c                        \
 libbb/dump.c                                        \
 libbb/duration.c                                    \
 libbb/endofname.c                                   \
 libbb/executable.c                                  \
 libbb/fclose_nonstdin.c                             \
 libbb/fflush_stdout_and_exit.c                      \
 libbb/fgets_str.c                                   \
 libbb/find_mount_point.c                            \
 libbb/find_pid_by_name.c                            \
 libbb/full_write.c                                  \
 libbb/get_last_path_component.c                     \
 libbb/get_line_from_file.c                          \
 libbb/get_shell_name.c                              \
 libbb/getopt32.c                                    \
 libbb/getopt_allopts.c                              \
 libbb/hash_md5_sha.c                                \
 libbb/herror_msg.c                                  \
 libbb/human_readable.c                              \
 libbb/isdirectory.c                                 \
 libbb/isqrt.c                                       \
 libbb/last_char_is.c                                \
 libbb/lineedit.c                                    \
 libbb/lineedit_ptr_hack.c                           \
 libbb/llist.c                                       \
 libbb/make_directory.c                              \
 libbb/messages.c                                    \
 libbb/missing_syscalls.c                            \
 libbb/mode_string.c                                 \
 libbb/nuke_str.c                                    \
 libbb/parse_config.c                                \
 libbb/parse_mode.c                                  \
 libbb/percent_decode.c                              \
 libbb/perror_msg.c                                  \
 libbb/perror_nomsg_and_die.c                        \
 libbb/platform.c                                    \
 libbb/print_numbered_lines.c                        \
 libbb/printable.c                                   \
 libbb/printable_string.c                            \
 libbb/process_escape_sequence.c                     \
 libbb/procps.c                                      \
 libbb/ptr_to_globals.c                              \
 libbb/read.c                                        \
 libbb/read_printf.c                                 \
 libbb/recursive_action.c                            \
 libbb/remove_file.c                                 \
 libbb/replace.c                                     \
 libbb/run_shell.c                                   \
 libbb/safe_gethostname.c                            \
 libbb/safe_poll.c                                   \
 libbb/safe_strncpy.c                                \
 libbb/safe_write.c                                  \
 libbb/securetty.c                                   \
 libbb/single_argv.c                                 \
 libbb/skip_whitespace.c                             \
 libbb/str_tolower.c                                 \
 libbb/strrstr.c                                     \
 libbb/sysconf.c                                     \
 libbb/time.c                                        \
 libbb/trim.c                                        \
 libbb/u_signal_names.c                              \
 libbb/ubi.c                                         \
 libbb/uuencode.c                                    \
 libbb/verror_msg.c                                  \
 libbb/vfork_daemon_rexec.c                          \
 libbb/wfopen.c                                      \
 libbb/wfopen_input.c                                \
 libbb/xatonum.c                                     \
 libbb/xconnect.c                                    \
 libbb/xfunc_die.c                                   \
 libbb/xfuncs.c                                      \
 libbb/xfuncs_printf.c                               \
 libbb/xgetcwd.c                                     \
 libbb/xreadlink.c                                   \
 libbb/xrealloc_vector.c                             \
 libbb/xregcomp.c                                    \
 libpwdgrp/uidgid_get.c                              \
 loginutils/suw32.c                                  \
 miscutils/bc.c                                      \
 miscutils/iconv.c                                   \
 miscutils/less.c                                    \
 miscutils/man.c                                     \
 miscutils/strings.c                                 \
 miscutils/ts.c                                      \
 miscutils/ttysize.c                                 \
 networking/ftpgetput.c                              \
 networking/ipcalc.c                                 \
 networking/nc.c                                     \
 networking/parse_pasv_epsv.c                        \
 networking/ssl_client.c                             \
 networking/tls.c                                    \
 networking/tls_aes.c                                \
 networking/tls_aesgcm.c                             \
 networking/tls_fe.c                                 \
 networking/tls_pstm.c                               \
 networking/tls_pstm_montgomery_reduce.c             \
 networking/tls_pstm_mul_comba.c                     \
 networking/tls_pstm_sqr_comba.c                     \
 networking/tls_rsa.c                                \
 networking/wget.c                                   \
 networking/whois.c                                  \
 procps/kill.c                                       \
 procps/pgrep.c                                      \
 procps/pidof.c                                      \
 procps/ps.c                                         \
 procps/watch.c                                      \
 shell/ash.c                                         \
 shell/ash_ptr_hack.c                                \
 shell/math.c                                        \
 shell/random.c                                      \
 shell/shell_common.c                                \
 util-linux/cal.c                                    \
 util-linux/getopt.c                                 \
 util-linux/hexdump.c                                \
 util-linux/hexdump_xxd.c                            \
 util-linux/rev.c

V = "\"1.32.0.git\""

D = \
 -I include \
 -I libbb \
 -DHAVE_STRING_H=1 \
 -DHAVE_CONFIG_H=0 \
 -DBB_VER=$V \
 -D_LARGEFILE_SOURCE \
 -D_LARGEFILE64_SOURCE \
 -D_FILE_OFFSET_BITS=64 \
 -D_GNU_SOURCE

DR = \
 -D BB_VER=$V \
 -D BB_VERSION=1 \
 -D BB_PATCHLEVEL=32 \
 -D BB_SUBLEVEL=0 \
 -D BB_EXTRAVERSION=1 \
 -I include

AR = $(CC) $M -ar

O = $(patsubst %.c,%.o,$S)
O1 = libbb/appletlib.o # main
B = sh.exe
A = lib.a
# L = -ladvapi32 -luser32 -lpsapi -luserenv
# R = $(patsubst %.o)

M = -m32
MR = -Fpe-i386

DIRS = $(sort $(dir $S))
MF = -MD -MF $*.d

all : $B

$B : $(O1) $A $R
	$(CC) $M -o $@ $^ $L $(LDFLAGS)

$A : $O
	rm -f $@ && $(AR) rcs $@ $^

%.o : %.c
	$(CC) $M -o $@ -c $< $(CFLAGS) $D $(MF)

-include $(patsubst %.o,%.d,$O)
