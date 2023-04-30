# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2021 Paul Dersey <pdersey@gmail.com>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>

# SPDX-License-Identifier: GPL-3.0-or-later

CC      = tcc -static

CFLAGS = -I vms \
				 -DGETGROUPS_T=gid_t \
				 -DGETPGRP_VOID=1 \
				 -DHAVE_ALLOCA=1 \
				 -DHAVE_ALLOCA_H=1 \
				 -DHAVE_ST_BLKSIZE=1 \
				 -DHAVE_SYS_WAIT_H=1 \
				 -DHAVE_VPRINTF=1 \
				 -DRETSIGTYPE=void \
				 -DSTDC_HEADERS=1 \
				 -DTIME_WITH_SYS_TIME=1 \
				 -DHAVE_STRINGIZE=1 \
				 -DREGEX_MALLOC=1 \
				 -DSPRINTF_RET=int \
				 -DHAVE_MEMCMP=1 \
				 -DHAVE_MEMCPY=1 \
				 -DHAVE_MEMSET=1 \
				 -DHAVE_STRCHR=1 \
				 -DHAVE_STRERROR=1 \
				 -DHAVE_STRFTIME=1 \
				 -DHAVE_STRTOD=1 \
				 -DHAVE_SYSTEM=1 \
				 -DHAVE_LIMITS_H=1 \
				 -DHAVE_MEMORY_H=1 \
				 -DHAVE_STDARG_H=1 \
				 -DHAVE_STRING_H=1 \
				 -DHAVE_SYS_PARAM_H=1 \
				 -DHAVE_UNISTD_H=1 \
         -DDEFPATH=\"$(PREFIX)/share/awk\" \
         -DBITOPS=1

.PHONY: all

GAWK_SRC = stubs array awktab builtin dfa eval field getopt getopt1 gawkmisc io main missing msg node random re regex version
GAWK_OBJ = $(addsuffix .o, $(GAWK_SRC))

all: gawk

gawk: $(GAWK_OBJ)
	$(CC) -o $@ $^

awktab.c: awk.y
	yacc -d $^
	mv y.tab.c $@

install: all
	install -D gawk $(DESTDIR)$(PREFIX)/bin/gawk
	ln -s $(PREFIX)/bin/gawk $(DESTDIR)$(PREFIX)/bin/awk
