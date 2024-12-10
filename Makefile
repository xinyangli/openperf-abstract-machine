# Makefile for AbstractMachine Kernels and Libraries
include scripts/helpers/rules.mk

### *Get a more readable version of this Makefile* by `make html` (requires python-markdown)
html:
	# cat Makefile | sed 's/^\([^#]\)/    \1/g' | markdown_py > Makefile.html
	cat Makefile | markdown_py > Makefile.html
.PHONY: html

## 1. Basic Setup and Checks

### Default to create a bare-metal kernel image
ifeq ($(MAKECMDGOALS),)
  MAKECMDGOALS  = image
  .DEFAULT_GOAL = image
endif

### Override checks when `make clean/clean-all/html`
ifeq ($(findstring $(MAKECMDGOALS),clean|clean-all|html),)

### Check: environment variable `$AM_HOME` looks sane
ifeq ($(wildcard $(AM_HOME)/am/include/am.h),)
  $(error $$AM_HOME must be an AbstractMachine repo)
endif

### Check: environment variable `$ARCH` must be in the supported list
ARCHS = $(basename $(notdir $(shell ls $(AM_HOME)/scripts/*.mk)))
ifeq ($(filter $(ARCHS), $(ARCH)), )
  $(error Expected $$ARCH in {$(ARCHS)}, Got "$(ARCH)")
endif

### Extract instruction set architecture (`ISA`) and platform from `$ARCH`. Example: `ARCH=x86_64-qemu -> ISA=x86_64; PLATFORM=qemu`
ARCH_SPLIT = $(subst -, ,$(ARCH))
ISA        = $(word 1,$(ARCH_SPLIT))
PLATFORM   = $(word 2,$(ARCH_SPLIT))

### Checks end here
endif

## 2. General Compilation Targets

### Create the destination directory (`build/$ARCH`)
WORK_DIR  ?= $(shell pwd)
DST_DIR   ?= $(WORK_DIR)/build/$(ARCH)
LIB_BUILDDIR ?= $(DST_DIR)/lib
INSTALLDIR ?= $(WORK_DIR)/build/install/$(ARCH)

## 3. General Compilation Flags

### (Cross) compilers, e.g., mips-linux-gnu-g++
CC        ?= $(CROSS_COMPILE)gcc
AS        := $(CC)
CXX       ?= $(CROSS_COMPILE)g++
LD        ?= $(CROSS_COMPILE)ld
AR        ?= $(CROSS_COMPILE)ar
OBJDUMP   ?= $(CROSS_COMPILE)objdump
OBJCOPY   ?= $(CROSS_COMPILE)objcopy
READELF   ?= $(CROSS_COMPILE)readelf

CXXFLAGS +=  $(CFLAGS) -ffreestanding -fno-rtti -fno-exceptions
ASFLAGS  += $(INCFLAGS)
LDFLAGS  += -z noexecstack
INTERFACE_LDFLAGS  += -z noexecstack

## 4. Arch-Specific Configurations

### Fall back to native gcc/binutils if there is no cross compiler
ifeq ($(wildcard $(shell which $(CC))),)
  $(info #  $(CC) not found; fall back to default gcc and binutils)
  CROSS_COMPILE := riscv64-unknown-linux-gnu-
endif

## 5. Compilation Rules

### Build libam

#### Include archetecture specific build flags
include $(AM_HOME)/scripts/$(ARCH).mk

#### Generating build rules with ADD_LIBRARY call. Target specific build flags can be tuned via changing prefixed variables (AM_ here)
AM_INCPATH += $(AM_HOME)/am/include $(AM_HOME)/am/src $(AM_HOME)/klib/include
AM_CFLAGS  += -lm -g -O3 -MMD -Wall $(addprefix -I, $(AM_INCPATH)) \
              -D__ISA__=\"$(ISA)\" -D__ISA_$(shell echo $(ISA) | tr a-z A-Z)__ \
              -D__ARCH__=$(ARCH) -D__ARCH_$(shell echo $(ARCH) | tr a-z A-Z | tr - _) \
              -D__PLATFORM__=$(PLATFORM) -D__PLATFORM_$(shell echo $(PLATFORM) | tr a-z A-Z | tr - _) \
              -DARCH_H=\"$(ARCH_H)\" \
              -fno-asynchronous-unwind-tables -fno-builtin -fno-stack-protector \
              -Wno-main -U_FORTIFY_SOURCE -fvisibility=hidden

$(eval $(call ADD_LIBRARY,$(LIB_BUILDDIR)/libam-$(ARCH).a,AM_))

ALL := am
all: $(addsuffix -$(ARCH).a, $(addprefix $(LIB_BUILDDIR)/lib, $(ALL)))

### Rule (link): objects (`*.o`) and libraries (`*.a`) -> `IMAGE.elf`, the final ELF binary to be packed into image (ld)
$(IMAGE).elf: $(OBJS) $(LIBS)
	@echo + LD "->" $(IMAGE_REL).elf
	@$(LD) $(LDFLAGS) -o $(IMAGE).elf --start-group $(LINKAGE) --end-group

## 6. Miscellaneous

### Build order control
image: image-dep
archive: $(ARCHIVE)
image-dep: $(OBJS) $(LIBS)
	@echo \# Creating image [$(ARCH)]
.PHONY: image image-dep archive run $(LIBS) install

install: $(INSTALL_DIR)/flags.mk

### Install rules
$(addprefix $(INSTALL_DIR)/, $(LIBS)): %: 

$(INSTALL_DIR)/flags.mk: 
	@echo "CFLAGS += " $(INTERFACE_CFLAGS) > $(DST_DIR)/flags.mk
	@echo "LDFLAGS += " $(INTERFACE_LDFLAGS) >> $(DST_DIR)/flags.mk

### Clean a single project (remove `build/`)
clean:
	rm -rf Makefile.html $(WORK_DIR)/build/
.PHONY: clean

### Clean all sub-projects within depth 2 (and ignore errors)
CLEAN_ALL = $(dir $(shell find . -mindepth 2 -name Makefile))
clean-all: $(CLEAN_ALL) clean
$(CLEAN_ALL):
	-@$(MAKE) -s -C $@ cleaear

