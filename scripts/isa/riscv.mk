AM_CFLAGS        += -static -fno-pic -march=rv64g -mcmodel=medany  -mstrict-align
AM_ASFLAGS       += -static -fno-pic -march=rv32g_zicsr -mcmodel=medany -O0
AM_LDFLAGS       += -melf64lriscv -O2

# overwrite ARCH_H defined in $(AM_HOME)/Makefile
ARCH_H := arch/riscv.h
