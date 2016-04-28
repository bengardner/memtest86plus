/**
 * @file cpu1900.c
 * Routines to interact with the CPU1900 FPGA.
 */
#include "io.h"     // outb()
#include "stdint.h" // bool


/**
 * Called from test_start() in main.c.
 * May get called multiple times.
 */
void hardware_init(void)
{
	static int did_init;

	if (!did_init) {
		did_init = 1;

		/* disable the watchdog */
		outb(0x02, 0x1113);

		/* Set status and DTE LEDs */
		outb(19,  0x1107);   /* status: blink rate 2 sec */
		outb(115, 0x1108);   /* status: GREEN, duty ~90% on/10% off */
		outb(4,   0x1109);   /* DTE: blink rate 0.5 sec */
		outb(127, 0x110a);   /* DTE: GREEN, duty 100% on/0% off */
	}
}


/**
 * Called from common_err(). May be called multiple times per error.
 */
void hardware_fail(void)
{
	outb(128 | 63, 0x110a);   /* DTE: RED, duty 50% on/50% off */
}
