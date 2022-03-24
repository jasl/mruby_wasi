#include <setjmp.h>

int setjmp(__attribute__ ((unused)) jmp_buf env) { return 0; }

void longjmp(__attribute__ ((unused)) jmp_buf env, __attribute__ ((unused)) int val) {}
