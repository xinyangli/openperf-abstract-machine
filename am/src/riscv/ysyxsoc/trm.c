#include "riscv/riscv.h"
#include <am.h>
#include <klib-macros.h>
#include <stdint.h>
#include <string.h>

#define HEAP_SIZE 0x1000
extern char _heap_start;
int main(const char *args);

Area heap = RANGE(&_heap_start, &_heap_start + HEAP_SIZE);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void uart_16550_init(void) {
#define UART_BASE 0x10000000U
#define UART_TX 0
#define UART_DLL 0
#define UART_IER 1
#define UART_DLM 1
#define UART_FCR 2
#define UART_LCR 3
#define UART_LSR 5
  //1. set the Line Control Register to the desired line control parameters.
  //Set bit 7 to '1' to allow access to the Divisor Latches.
  outb(UART_BASE + UART_LCR, 0b10000111);

  //2. Set the Divisor Latches, MSB first, LSB next. We don't care the value at present.
#define BATE_RATE 115200
#define CLK_FREQ 3686400
  uint16_t divisor = CLK_FREQ / ( 16 * BATE_RATE );
  //uint16_t divisor = 20;

  outb(UART_BASE + UART_DLM, divisor >> 8);
  outb(UART_BASE + UART_DLL, divisor);

  //3. Set the bit '7' of LCR to '0' to disable access to Divisor Latches.
  outb(UART_BASE + UART_LCR, 0b00000111);
  //4. Set the FIFO trigger level.
  outb(UART_BASE + UART_FCR, 0b11000111);
  //5. Enable desired interrupts.
  outb(UART_BASE + UART_IER, 0b00000000);


}

void putch(char ch) {
  //Check the status of the send queue before output.
  while(!(inb(UART_BASE + UART_LSR) & 0b00100000));
  outb(UART_BASE + UART_TX, ch);
}

void halt(int code) {
    asm volatile("mv a0, %0; ebreak" :: "r"(code));
    while (1);
}

void clear_bss(void) {
  extern char _sbss;
  extern char _ebss;
  memset(&_sbss, 0, &_ebss - &_sbss);
}

extern char _sdata;
extern char _data_size;
extern char _data_load_start;

void _trm_init() {
  memcpy(&_sdata, &_data_load_start, (size_t)&_data_size);
  clear_bss();
  uart_16550_init();
  int ret = main(mainargs);
  halt(ret);
} 
