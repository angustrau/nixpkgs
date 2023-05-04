# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>

# SPDX-License-Identifier: GPL-3.0-or-later

CC      = tcc -static
AR      = tcc -ar

CFLAGS  = -I lib \
          -DVERSION=\"1.4.7\" \
          -DPACKAGE_BUGREPORT=\"bug-m4@gnu.org\" \
          -DPACKAGE_STRING=\"GNU\ M4\ 1.4.7\" \
          -DPACKAGE=\"m4\" \
          -DPACKAGE_NAME=\"GNU\ M4\" \
          -DHAVE_STDINT_H=1 \
          -DHAVE_DECL___FPENDING=0 \
					-DPENDING_OUTPUT_N_BYTES=1 \
          -D__getopt_argv_const=const \
          -DSYSCMD_SHELL=\"/bin/sh\" \
					-DHAVE_SNPRINTF=1

LDFLAGS = -L . -lm4 -static

.PHONY: all

LIB_SRC = cloexec close-stream dup-safer error exitfail fd-safer fopen-safer __fpending getopt getopt1 mkstemp mkstemp-safer regex strcasecmp tempname tmpfile-safer obstack printf-parse printf-args verror xalloc-die xasprintf xmalloc vasprintf vasnprintf xvasprintf
LIB_OBJECTS = $(addprefix lib/, $(addsuffix .o, $(LIB_SRC)))

M4_SRC = stubs m4 builtin debug eval format freeze input macro output path symtab
M4_OBJ = $(addprefix src/, $(addsuffix .o, $(M4_SRC)))

all: src/m4

src/m4: libm4.a $(M4_OBJ)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

libm4.a: $(LIB_OBJECTS)
	$(AR) cr $@ $^

%.o : %.c lib/config.h
	$(CC) -c -o $@ $< $(CFLAGS)

lib/config.h:
	touch lib/config.h

install: all
	install -D src/m4 $(DESTDIR)$(PREFIX)/bin/m4
