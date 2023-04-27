/* missing declarations from mes-libc */

#define sig_atomic_t int

#define EWOULDBLOCK EAGAIN

#define O_NONBLOCK 00004000

#define S_ISVTX 0001000

#define S_IFSOCK 0140000

#define S_ISCHR(m)	(((m) & S_IFMT) == S_IFCHR)

#define S_ISBLK(m)	(((m) & S_IFMT) == S_IFBLK)

#define S_ISSOCK(m)	(((m) & S_IFMT) == S_IFSOCK)

#define S_ISLNK(m)	(((m) & S_IFMT) == S_IFLNK)

#define WNOHANG 1

#define	WEXITSTATUS(status)	(((status) & 0xff00) >> 8)

#define	WTERMSIG(status)	((status) & 0x7f)

#define	WIFEXITED(status)	(WTERMSIG(status) == 0)

int sys_siglist (int x);
