/*
  SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
  SPDX-FileCopyrightText: 2021 fosslinux <fosslinux@aussies.space>

  SPDX-License-Identifier: GPL-2.0-or-later

  mbstate_t is a struct that is required. However, it is not defined by mes libc.
  This implementation was taken from glibc 2.32. 
*/

#ifndef ____mbstate_t_defined
#define ____mbstate_t_defined 1

/* Integral type unchanged by default argument promotions that can
   hold any value corresponding to members of the extended character
   set, as well as at least one value that does not correspond to any
   member of the extended character set.  */
#ifndef __WINT_TYPE__
# define __WINT_TYPE__ unsigned int
#endif

/* Conversion state information.  */
typedef struct
{
  int __count;
  union
  {
    __WINT_TYPE__ __wch;
    char __wchb[4];
  } __value;		/* Value so far.  */
} mbstate_t;

#endif
