# This file is from nutshell's am
CROSS_COMPILE := riscv64-unknown-linux-gnu-
COMMON_FLAGS  := -fno-pic -march=rv64g -mcmodel=medany
CFLAGS        += $(COMMON_FLAGS) -static
ASFLAGS       += $(COMMON_FLAGS) -O0
LDFLAGS       += -melf64lriscv
ARCH_H := arch/riscv.h
