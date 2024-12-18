AM_SRCS := am/src/platform/nemu/trm.c \
           am/src/platform/nemu/ioe/ioe.c \
           am/src/platform/nemu/ioe/timer.c \
           am/src/platform/nemu/ioe/input.c \
           am/src/platform/nemu/ioe/gpu.c \
           am/src/platform/nemu/ioe/audio.c \
           am/src/platform/nemu/ioe/disk.c \
           am/src/platform/nemu/mpe.c

AM_PUBLIC_CFLAGS := -fdata-sections -ffunction-sections

AM_CFLAGS += $(AM_PUBLIC_CFLAGS) -DMAINARGS=\"$(mainargs)\"
AM_LDFLAGS += -T$(AM_HOME)/scripts/linker.ld $(AM_PUBLIC_LDFLAGS)
AM_INCPATH += $(AM_HOME)/am/src/platform/nemu/include

AM_INTERFACE_CFLAGS += $(AM_PUBLIC_CFLAGS)
AM_INTERFACE_LDFLAGS += -T$(LIB_INSTALLDIR)/ldscripts/linker.ld \
                        -Wl,--defsym=_pmem_start=0x80000000 -Wl,--defsym=_entry_offset=0x0 \
                        -Wl,--gc-sections -Wl,--entry=_start
# We need to tell linker not to use crt0 and stdlib, so that
# startfiles from libam and stdlib from klib can be used. 
AM_INTERFACE_LDFLAGS += -nostartfiles -nostdlib

.PHONY: $(AM_HOME)/am/src/platform/nemu/trm.c

