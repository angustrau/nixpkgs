/** declared but unimplemented when JOBS=0 */

int bgcmd(int argc, char **argv) {
  return -1;
}

int fgcmd(int argc, char **argv) {
  return -1;
}

int ulimitcmd(int argc, char **argv) {
  return -1;
}

/** mes-libc stubs */

int sigsuspend(const void *mask) {
  return -1;
}

int sigfillset(void *set) {
  return -1;
}

int wait3(int *wstatus, int options, void *rusage) {
  return waitpid(-1, wstatus, options);
}