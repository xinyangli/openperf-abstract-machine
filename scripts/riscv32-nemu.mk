include $(AM_HOME)/scripts/isa/riscv.mk
include $(AM_HOME)/scripts/platform/nemu.mk
AM_CFLAGS  += -DISA_H=\"riscv/riscv.h\" -march=rv32im_zicsr -mabi=ilp32
KLIB_CFLAGS += -march=rv32im_zicsr -mabi=ilp32
AM_LDFLAGS += -melf32lriscv
INTERFACE_CFLAGS += -march=rv32im_zicsr -mabi=ilp32

AM_SRCS += am/src/riscv/nemu/start.S \
           am/src/riscv/nemu/cte.c \
           am/src/riscv/nemu/trap.S \
           am/src/riscv/nemu/vme.c
