.section entry, "ax"
.globl _start
.type _start, @function

_start:
  mv s0, zero
  la sp, _stack_pointer

  lui t0, %hi(_trm_init)   # Load upper 20 bits
  addi t0, t0, %lo(_trm_init)  # Add lower 12 bits
  jalr ra, t0, 0           # Jump and link register
