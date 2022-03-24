#ifndef RB_WASM_SUPPORT_SETJMP_H
#define RB_WASM_SUPPORT_SETJMP_H

typedef void* jmp_buf;

int setjmp(jmp_buf env);

void longjmp(jmp_buf env, int val);

#endif
