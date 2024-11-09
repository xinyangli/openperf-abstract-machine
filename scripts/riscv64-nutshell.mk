include $(AM_HOME)/scripts/isa/riscv.mk

AM_SRCS := riscv/nutshell/isa/riscv/boot/start.S \
           riscv/nutshell/common/mainargs.S \
					 riscv/nutshell/isa/riscv/trm.c \
           riscv/nutshell/common/uartlite.c \
           riscv/nutshell/common/ioe.c \
           riscv/nutshell/common/timer.c \
           platform/dummy/input.c \
           platform/dummy/video.c \
           platform/dummy/audio.c \
           platform/dummy/cte.c \
           platform/dummy/vme.c \
					 platform/dummy/mpe.c \

COMMON_CFLAGS += -march=rv64im_zicsr -mabi=lp64  # overwrite
LDFLAGS       +=  -melf64lriscv                   # overwrite

CFLAGS += -I$(AM_HOME)/am/src/riscv/nutshell/include -DISA_H=\"riscv.h\"
ASFLAGS += -DMAINARGS=\"$(mainargs)\" # for mainargs.S, modify in the future
CFLAGS += -DMAINARGS=\"$(mainargs)\" # for trm.c
.PHONY: $(AM_HOME)/am/src/riscv/nutshell/common/mainargs.S

LDFLAGS += -L $(AM_HOME)/am/src/riscv/nutshell/ldscript
LDFLAGS += -T $(AM_HOME)/am/src/riscv/nutshell/isa/riscv/boot/loader64.ld

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	$(NUTSHELL_HOME)/build/emu --no-diff -i $(abspath $(IMAGE).bin)


