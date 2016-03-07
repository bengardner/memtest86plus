/*
 * MemTest86+ V5 Specific code (GPL V2.0)
 * By Samuel DEMEULEMEESTER, sdemeule@memtest.org
 * http://www.canardpc.com - http://www.memtest.org
 * ------------------------------------------------
 * config.h - MemTest-86  Version 3.3
 *
 * Compile time configuration options
 *
 * Released under version 2 of the Gnu Public License.
 * By Chris Brady
 */

/* CONSERVATIVE_SMP - If set to 0, SMP will be enabled by default */
/* Might be enabled in future revision after extensive testing */
/* In all cases, SMP is disabled by defaut on server platform */
#ifndef CONSERVATIVE_SMP
#define CONSERVATIVE_SMP 1
#endif

/* BEEP_MODE - Beep on error. Default off, Change to 1 to enable */
#ifndef BEEP_MODE
#define BEEP_MODE 0
#endif

/* BEEP_END_NO_ERROR - Beep at end of each pass without error. Default off, Change to 1 to enable */
#ifndef BEEP_END_NO_ERROR
#define BEEP_END_NO_ERROR 0
#endif

/* PARITY_MEM - Enables support for reporting memory parity errors */
/*	Experimental, normally enabled */
#ifndef PARITY_MEM
#define PARITY_MEM
#endif

/* SERIAL_CONSOLE_DEFAULT -  The default state of the serial console. */
/*	This is normally off since it slows down testing.  Change to a 1 */
/*	to enable. */
#ifndef SERIAL_CONSOLE_DEFAULT
#define SERIAL_CONSOLE_DEFAULT 0
#endif

/* SERIAL_TTY - The default serial port to use. 0=ttyS0, 1=ttyS1, 2=ttyS2, 3=ttyS3 */
#ifndef SERIAL_TTY
#define SERIAL_TTY 0
#endif

/* SERIAL_BAUD_RATE - Baud rate for the serial console */
#ifndef SERIAL_BAUD_RATE
#define SERIAL_BAUD_RATE 115200
#endif

/* SCRN_DEBUG - extra check for SCREEN_BUFFER
 */
/* #define SCRN_DEBUG */

/* APM - Turns off APM at boot time to avoid blanking the screen */
/*	Normally enabled */
#define APM_OFF

/* USB_WAR - Enables a workaround for errors caused by BIOS USB keyboard */
/*	and mouse support*/
/*	Normally enabled */
#define USB_WAR

/* coreboot version number for memtest86+ - 3 characters. */
#define COREBOOT_VERSION_NUMBER_STRING "001"

/* The memtest version string with the coreboot badge (28 chars total)
 * This is 25 characters plus the 3 character version number.
 *                             "0123456789012345678901234567" */
#define MEMTEST_VERSION_STRING "Memtest86+ 5.01 coreboot " COREBOOT_VERSION_NUMBER_STRING

/* Location of flashing '+' symbol */
#define MEMTEST_PLUS_LOCATION 9
