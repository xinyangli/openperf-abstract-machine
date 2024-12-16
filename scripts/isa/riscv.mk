AM_CFLAGS        += -static -fno-pic -mstrict-align -ffreestanding
AM_ASFLAGS       += -static -fno-pic -O0

INTERFACE_CFLAGS += -static -mcmodel=medany -mstrict-align -ffreestanding
INTERFACE_ASFLAGS += -static -mcmodel=medany
INTERFACE_LDFLAGS += 

# overwrite ARCH_H defined in $(AM_HOME)/Makefile
ARCH_H := arch/riscv.h
