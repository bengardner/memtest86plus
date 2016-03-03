# Makefile for MemTest86+
#
# Author:		Chris Brady
# Created:		January 1, 1996

include ../coreboot/.xcompile

CC:=$(GCC_CC_x86_32)
CFLAGS:=$(GCC_CFLAGS_x86_32)
COMPILER_RT:=$(GCC_COMPILER_RT_x86_32)
COMPILER_RT_FLAGS:=$(GCC_COMPILER_RT_FLAGS_x86_32)

CPP:=$(CPP_x86_32)
AS:=$(AS_x86_32)
LD:=$(LD_x86_32)
NM:=$(NM_x86_32)
OBJCOPY:=$(OBJCOPY_x86_32)
OBJDUMP:=$(OBJDUMP_x86_32)
READELF:=$(READELF_x86_32)
STRIP:=$(STRIP_x86_32)
AR:=$(AR_x86_32)
GNATBIND:=$(GNATBIND_x86_32)
CROSS_COMPILE:=$(CROSS_COMPILE_x86_32)

AS += -32

SERIAL_CONSOLE_DEFAULT:=1
SERIAL_TTY:=0

#
# Path for the floppy disk device
#
FDISK=/dev/fd0

MEMTEST_CFLAGS := -Wall -march=i486 -m32 -fomit-frame-pointer -fno-builtin
MEMTEST_CFLAGS += -MMD -ffreestanding

CFLAGS := $(MEMTEST_CFLAGS) -O0 -fPIC $(SMP_FL) -fno-stack-protector -fgnu89-inline

# This reverts a change introduced with recent binutils (post
# http://sourceware.org/bugzilla/show_bug.cgi?id=10569).  Needed to
# ensure Multiboot header is within the limit offset.
LD += -z max-page-size=0x1000

ifneq ($(SERIAL_CONSOLE_DEFAULT),)
CFLAGS+= -DSERIAL_CONSOLE_DEFAULT=$(SERIAL_CONSOLE_DEFAULT)
endif
ifneq ($(SERIAL_TTY),)
CFLAGS+= -DSERIAL_TTY=$(SERIAL_TTY)
endif
ifneq ($(SERIAL_BAUD_RATE),)
CFLAGS+= -DSERIAL_BAUD_RATE=$(SERIAL_BAUD_RATE)
endif

OBJS= _head.o reloc.o main.o test.o init.o lib.o patn.o screen_buffer.o \
      cpu1900.o \
      config.o cpuid.o linuxbios.o pci.o memsize.o spd.o error.o dmi.o controller.o \
      smp.o vmem.o random.o multiboot.o
DEPS=${OBJS:.o=.d}

-include $(DEPS)

all: clean memtest.bin memtest.elf

com1:
	$(MAKE) all SERIAL_CONSOLE_DEFAULT=1 SERIAL_TTY=0

com2:
	$(MAKE) all SERIAL_CONSOLE_DEFAULT=1 SERIAL_TTY=1

com3:
	$(MAKE) all SERIAL_CONSOLE_DEFAULT=1 SERIAL_TTY=2

com4:
	$(MAKE) all SERIAL_CONSOLE_DEFAULT=1 SERIAL_TTY=3

# Link it statically once so I know I don't have undefined
# symbols and then link it dynamically so I have full
# relocation information
memtest_shared: $(OBJS) memtest_shared.lds Makefile
	$(LD) --warn-constructors --warn-common -static -T memtest_shared.lds \
	 -o $@ $(OBJS) && \
	$(LD) -shared -Bsymbolic -T memtest_shared.lds -o $@ $(OBJS)

memtest_shared.bin: memtest_shared
	$(OBJCOPY) -O binary $< memtest_shared.bin

memtest.elf: memtest_shared.bin memtest.lds
	$(LD) -s -T memtest.lds -b binary memtest_shared.bin -o $@

_head.s: head.S config.h defs.h test.h
	$(CC) -MMD -E -traditional $< -o $@

_bootsect.s: bootsect.S config.h defs.h
	$(CC) -MMD -E -traditional $< -o $@

_setup.s: setup.S config.h defs.h
	$(CC) -MMD -E -traditional $< -o $@

memtest.bin: memtest_shared.bin _bootsect.o _setup.o memtest.bin.lds
	$(LD) -T memtest.bin.lds _bootsect.o _setup.o -b binary \
	memtest_shared.bin -o memtest.bin

reloc.o: reloc.c
	$(CC) $(CFLAGS) -fno-strict-aliasing -c reloc.c

test.o: test.c
	$(CC) $(MEMTEST_CFLAGS) -O0 -c test.c

random.o: random.c
	$(CC) $(MEMTEST_CFLAGS) -O3 -c random.c

# rule for build number generation
build_number:
	sh make_buildnum.sh

distclean:
	make clean
	rm -f .xcompile

clean:
	rm -f *.o *.s *.d *.iso memtest.bin memtest.elf memtest_shared \
		memtest_shared.bin memtest.iso

iso:
	make all
	./makeiso.sh

install: all
	dd <memtest.bin >$(FDISK) bs=8192

install-precomp:
	dd <precomp.bin >$(FDISK) bs=8192

dos: all
	cat mt86+_loader memtest.bin > memtest.exe
