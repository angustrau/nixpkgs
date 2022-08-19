#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv, char** envp)
{
  char **newargs = calloc(argc + 4, sizeof(char*));
  newargs[0] = "@kaem@";
  newargs[1] = "--strict";
  newargs[2] = "--file";
  newargs[3] = argv[1];
  newargs[4] = "--";

  int i;
  for (i = 2; i < argc; i = i + 1)
  {
    newargs[i+3] = argv[i];
    fputs(argv[i], stdout);
    fputs("\n", stdout);
  }
  
  int code = execve("@kaem@", newargs, envp);

  free(newargs);
  return code;
}
