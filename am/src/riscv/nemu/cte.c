#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
        case 11: 
#ifdef __riscv_e
          uint32_t call_number = c->gpr[15]; //a5
#else
          uint32_t call_number = c->gpr[17]; //a7
#endif
          switch(call_number) {
            case -1: ev.event = EVENT_YIELD; break;
            default:
              ev.event = EVENT_SYSCALL; break;
          }
          break;

      default: ev.event = EVENT_ERROR; break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
  }

  return c;
}
extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
    uint32_t *stack = kstack.end; //kernel stack top
    stack -= 32 + 4;
    for(int i = 0; i < 32; i++) {
        stack[i] = 0;
    }
    //stack[2] = (uint32_t)((uint32_t*)kstack.start + 1024);
    stack[10] = (uint32_t)arg;
    stack[32] = 11; //mcause
    stack[33] = 0x1800U; //mstatus
    stack[34] = (uint32_t)entry; //mepc
    stack[35] = 0; //addr space
                   //
    uint32_t *begin = kstack.start;
    *begin = (uint32_t)stack;

    return (Context *)stack;
}

void yield() {
#ifdef __riscv_e
    //use a5 or a7 to get system call ID
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
