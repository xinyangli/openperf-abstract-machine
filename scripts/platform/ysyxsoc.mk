AM_SRCS := riscv/ysyxsoc/start.S \
           riscv/ysyxsoc/trm.c \
           riscv/ysyxsoc/ioe.c \
           riscv/ysyxsoc/timer.c \
           riscv/ysyxsoc/input.c \
           riscv/ysyxsoc/cte.c \
           riscv/ysyxsoc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDFLAGS   += -T $(AM_HOME)/scripts/linker-soc.ld \
						 --defsym=_mrom_start=0x20000000 --defsym=_sram_start=0x0f000000 \
						 --defsym=_entry_offset=0x0 --defsym=_sram_limit=0x2000 #-M
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
.PHONY: $(AM_HOME)/am/src/riscv/ysyxsoc/trm.c 

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

ref= $(NEMU_HOME)/riscv32-nemu-interpreter-so

run: image
	make -f $(NPC_HOME)/scripts/sim.mk  all
	$(NPC_HOME)/build/ysyxSoCFull $(IMAGE).bin $(ref)
gdb: image
	make -f $(NPC_HOME)/scripts/sim.mk all
	gdb --args $(NPC_HOME)/build/npc $(IMAGE).bin
