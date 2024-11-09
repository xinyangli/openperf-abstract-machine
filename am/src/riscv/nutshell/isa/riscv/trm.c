#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

extern char _heap_start;
extern char _pmem_end;

int main(const char *args);
void __am_init_uartlite(void);
void __am_uartlite_putchar(char ch);

Area heap = {
  .start = &_heap_start,
  .end = &_pmem_end,
};

void putch(char ch) {
  __am_uartlite_putchar(ch);
}

void halt(int code) {
  printf("Before 0x0005006b\n");
  __asm__ volatile("mv a0, %0; .word 0x0005006b" : :"r"(code));

  // should not reach here during simulation
  printf("Exit with code = %d\n", code);

  // should not reach here on FPGA
  while (1);
}

extern char __am_mainargs;
static const char *mainargs = &__am_mainargs;
void _trm_init() {
  __am_init_uartlite();
  int ret = main(mainargs);
  halt(ret);
}
