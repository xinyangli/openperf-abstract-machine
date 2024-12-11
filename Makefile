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
LIB_INSTALLDIR ?= $(INSTALLDIR)/lib
INC_INSTALLDIR ?= $(INSTALLDIR)/include

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
LDFLAGS  += -z noexecstack
INTERFACE_LDFLAGS  += -z noexecstack

## 4. Arch-Specific Configurations

### Fall back to native gcc/binutils if there is no cross compiler
ifeq ($(wildcard $(shell which $(CC))),)
  $(info #  $(CC) not found; fall back to default gcc and binutils)
  CROSS_COMPILE := riscv64-unknown-linux-gnu-
endif

## 5. Compilation Rules

BUILDDIR := $(DST_DIR)
### Build libam

#### Include archetecture specific build flags
include $(AM_HOME)/scripts/$(ARCH).mk

#### Generating build rules with ADD_LIBRARY call. Target specific build flags can be tuned via changing prefixed variables (AM_ here)
AM_INCPATH += $(AM_HOME)/am/include $(AM_HOME)/am/src $(AM_HOME)/klib/include
AM_CFLAGS  += -lm -g -O3 -MMD -Wall $(addprefix -I, $(AM_INCPATH)) \
              -D__ISA__=\"$(ISA)\" -D__ISA_$(shell echo $(ISA) | tr a-z A-Z)__ \
              -D__ARCH__=$(ARCH) -D__ARCH_$(shell echo $(ARCH) | tr a-z A-Z | tr - _) \
              -D__PLATFORM__=$(PLATFORM) -D__PLATFORM_$(shell echo $(PLATFORM) | tr a-z A-Z | tr - _) \
              -DARCH_H=\"$(ARCH_H)\"
AM_INTERFACE_INCPATH += $(AM_HOME)/am/include $(AM_HOME)/klib/include
AM_INTERFACE_CFLAGS += $(addprefix -I, $(AM_INTERFACE_INCPATH:%=$(INC_INSTALLDIR))) \
                       -lm -DARCH_H=\"$(ARCH_H)\" -fno-asynchronous-unwind-tables -fno-builtin -fno-stack-protector \
                       -Wno-main -U_FORTIFY_SOURCE -fvisibility=hidden

$(eval $(call ADD_LIBRARY,$(LIB_BUILDDIR)/libam-$(ARCH).a,AM_))

### Build klib

KLIB_SRCS := $(shell find klib/src/ -name "*.c")

KLIB_INCPATH += $(AM_HOME)/am/include $(AM_HOME)/klib/include
KLIB_CFLAGS += -MMD -Wall $(addprefix -I, $(KLIB_INCPATH)) \
               -DARCH_H=\"$(ARCH_H)\"
KLIB_INTERFACE_INCPATH += $(AM_HOME)/am/include $(AM_HOME)/klib/include
KLIB_INTERFACE_CFLAGS += -DARCH_H=\"$(ARCH_H)\" $(addprefix -I, $(KLIB_INTERFACE_INCPATH:%=$(INC_INSTALLDIR)))

$(eval $(call ADD_LIBRARY,$(LIB_BUILDDIR)/libklib-$(ARCH).a,KLIB_))

LIBS := am klib
libs: $(addsuffix -$(ARCH).a, $(addprefix $(LIB_BUILDDIR)/lib, $(ALL)))
$(LIBS): %: $(addsuffix -$(ARCH).a, $(addprefix $(LIB_BUILDDIR)/lib, %))

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
.PHONY: image image-dep archive run libs $(LIBS) install

### Install rules

INTERFACE_INCPATH += $(sort $(KLIB_INTERFACE_INCPATH) $(AM_INTERFACE_INCPATH))
INTERFACE_CFLAGS += $(sort $(KLIB_INTERFACE_CFLAGS) $(AM_INTERFACE_CFLAGS))
INTERFACE_LDFLAGS += $(sort $(KLIB_LDFLAGS) $(AM_LDFLAGS))

EXPORT_FLAGS_FILE := $(LIB_INSTALLDIR)/make/flags-$(ARCH).mk
EXPORT_FLAGS_TEMPLATE := $(file < $(AM_HOME)/scripts/templates/flags.tmpl)
HELPERS := $(wildcard find scripts/helpers/*.mk)
EXPORT_HELPERS := $(HELPERS:scripts/helpers/%=$(LIB_INSTALLDIR)/make/%)

EXPORTS := $(EXPORT_FLAGS_FILE) $(EXPORT_HELPERS)

$(EXPORT_HELPERS): $(LIB_INSTALLDIR)/make/%: scripts/helpers/%
	@echo + INSTALL $(patsubst $(INSTALLDIR)/%,%,$@)
	@install -dm755 $(dir $@)
	@install -Dm644 $< $(dir $@)

export INTERFACE_CFLAGS INTERFACE_INCPATH INTERFACE_LDFLAGS
$(EXPORT_FLAGS_FILE):
	@echo + INSTALL $(patsubst $(INSTALLDIR)/%,%,$@)
	@install -Dm644 <(printf $(EXPORT_FLAGS_TEMPLATE)) $(EXPORT_FLAGS_FILE)

install-libs: $(LIBS)
	@echo + INSTALL LIBS: $(LIBS) 
	@install -dm755 $(LIB_INSTALLDIR)
	@install -Dm644 $(addsuffix -$(ARCH).a, $(addprefix $(LIB_BUILDDIR)/lib, $(LIBS))) $(LIB_INSTALLDIR)

install-headers: HEADERS := $(shell find $(INTERFACE_INCPATH) -name '*.h')
install-headers: $(HEADERS)	# Headers needs to be reinstalled if they are changed 
	@echo + INSTALL HEADERS: $(INTERFACE_INCPATH)
	@install -dm755 $(INC_INSTALLDIR)
	@cp -r $(addsuffix /*, $(INTERFACE_INCPATH)) $(INC_INSTALLDIR)

install: $(EXPORTS) install-libs install-headers

### Clean a single project (remove `build/`)
clean:
	rm -rf Makefile.html $(WORK_DIR)/build/
.PHONY: clean

### Clean all sub-projects within depth 2 (and ignore errors)
CLEAN_ALL = $(dir $(shell find . -mindepth 2 -name Makefile))
clean-all: $(CLEAN_ALL) clean
$(CLEAN_ALL):
	-@$(MAKE) -s -C $@ cleaear

