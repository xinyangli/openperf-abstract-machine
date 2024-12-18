AM_SRCS := am/src/native/trm.c \
           am/src/native/ioe.c \
           am/src/native/cte.c \
           am/src/native/trap.S \
           am/src/native/vme.c \
           am/src/native/mpe.c \
           am/src/native/platform.c \
           am/src/native/ioe/input.c \
           am/src/native/ioe/timer.c \
           am/src/native/ioe/gpu.c \
           am/src/native/ioe/uart.c \
           am/src/native/ioe/audio.c \
           am/src/native/ioe/disk.c \

AM_CFLAGS  += -fpie $(shell sdl2-config --cflags)
INTERFACE_CFLAGS += -fpie
INTERFACE_LDFLAGS += $(shell sdl2-config --libs) -ldl -lm

# gdb: image
# 	gdb -ex "handle SIGUSR1 SIGUSR2 SIGSEGV noprint nostop" $(IMAGE)
