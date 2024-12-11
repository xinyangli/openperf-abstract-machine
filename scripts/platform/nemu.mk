AM_SRCS := am/src/platform/nemu/trm.c \
           am/src/platform/nemu/ioe/ioe.c \
           am/src/platform/nemu/ioe/timer.c \
           am/src/platform/nemu/ioe/input.c \
           am/src/platform/nemu/ioe/gpu.c \
           am/src/platform/nemu/ioe/audio.c \
           am/src/platform/nemu/ioe/disk.c \
           am/src/platform/nemu/mpe.c

AM_PUBLIC_CFLAGS := -fdata-sections -ffunction-sections
AM_PUBLIC_LDFLAGS := --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0 \
                     --gc-sections --entry=_start
AM_CFLAGS += $(AM_PUBLIC_CFLAGS)
AM_LDFLAGS += -T$(AM_HOME)/scripts/linker.ld $(AM_PUBLIC_LDFLAGS)

AM_INTERFACE_CFLAGS += $(AM_PUBLIC_CFLAGS)
AM_INTERFACE_LDFLAGS += -T$(LIB_INSTALLDIR)/ldscripts/linker.ld $(AM_PUBLIC_LDFLAGS)

AM_CFLAGS += -DMAINARGS=\"$(mainargs)\"
AM_INCPATH += $(AM_HOME)/am/src/platform/nemu/include
.PHONY: $(AM_HOME)/am/src/platform/nemu/trm.c

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

NEMUFLAGS += -b 
#-l $(shell dirname $(IMAGE).elf)/nemu-log.txt 

run: image
	$(MAKE) -C $(NEMU_HOME) ISA=$(ISA) run ARGS="$(NEMUFLAGS)" IMG=$(IMAGE).bin

gdb: image
	$(MAKE) -C $(NEMU_HOME) ISA=$(ISA) gdb ARGS="$(NEMUFLAGS)" IMG=$(IMAGE).bin
