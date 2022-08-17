// Basic tool for creating symbolic links
// Usage: ln0 <source> <destination>

#include <fcntl.h>
#include <unistd.h>

int symlink(char const* a, char const* b)
{
	asm("LOAD_EFFECTIVE_ADDRESS_ebx %8"
	    "LOAD_INTEGER_ebx"
	    "LOAD_EFFECTIVE_ADDRESS_ecx %4"
	    "LOAD_INTEGER_ecx"
	    "LOAD_IMMEDIATE_eax %83"
	    "INT_80");
}

int main(int argc, char** argv)
{
  symlink(argv[1], argv[2]);
}
