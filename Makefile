# Makefile for MemTest86+
#
# Author:		Chris Brady
# Created:		January 1, 1996


#
# Path for the floppy disk device
#
FDISK=/dev/fd0

AS=as -32
CC=gcc

CFLAGS= -Wall -march=i486 -m32 -O0 -fomit-frame-pointer -fno-builtin \
	-ffreestanding -fPIC $(SMP_FL) -fno-stack-protector -fgnu89-inline

ifneq ($(SERIAL_CONSOLE_DEFAULT),)
	CFLAGS += -DSERIAL_CONSOLE_DEFAULT=$(SERIAL_CONSOLE_DEFAULT)
endif

ifneq ($(SERIAL_BAUD_RATE),)
	CFLAGS += -DSERIAL_BAUD_RATE=$(SERIAL_BAUD_RATE)
endif

ifneq ($(SERIAL_TTY),)
	CFLAGS += -DSERIAL_TTY=$(SERIAL_TTY)
endif

# This reverts a change introduced with recent binutils (post
# http://sourceware.org/bugzilla/show_bug.cgi?id=10569).  Needed to
# ensure Multiboot header is within the limit offset.
LD += -z max-page-size=0x1000

OBJS= head.o reloc.o main.o test.o init.o lib.o patn.o screen_buffer.o \
      config.o cpuid.o linuxbios.o pci.o memsize.o spd.o error.o dmi.o controller.o \
      smp.o vmem.o random.o multiboot.o

all: clean memtest.bin memtest

# Link it statically once so I know I don't have undefined
# symbols and then link it dynamically so I have full
# relocation information
memtest_shared: $(OBJS) memtest_shared.lds Makefile
	$(LD) --warn-constructors --warn-common -static -T memtest_shared.lds \
	 -o $@ $(OBJS) && \
	$(LD) -shared -Bsymbolic -T memtest_shared.lds -o $@ $(OBJS)

memtest_shared.bin: memtest_shared
	objcopy -O binary $< memtest_shared.bin

memtest: memtest_shared.bin memtest.lds
	$(LD) -s -T memtest.lds -b binary memtest_shared.bin -o $@

head.s: head.S config.h defs.h test.h
	$(CC) -E -traditional $< -o $@

bootsect.s: bootsect.S config.h defs.h
	$(CC) -E -traditional $< -o $@

setup.s: setup.S config.h defs.h
	$(CC) -E -traditional $< -o $@

memtest.bin: memtest_shared.bin bootsect.o setup.o memtest.bin.lds
	$(LD) -T memtest.bin.lds bootsect.o setup.o -b binary \
	memtest_shared.bin -o memtest.bin

reloc.o: reloc.c
	$(CC) -c $(CFLAGS) -fno-strict-aliasing reloc.c

test.o: test.c
	$(CC) -c -Wall -march=i486 -m32 -O0 -fomit-frame-pointer -fno-builtin -ffreestanding test.c

random.o: random.c
	$(CC) -c -Wall -march=i486 -m32 -O3 -fomit-frame-pointer -fno-builtin -ffreestanding random.c

# rule for build number generation
build_number:
	sh make_buildnum.sh

clean:
	rm -f *.o *.s *.iso memtest.bin memtest memtest_shared \
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
