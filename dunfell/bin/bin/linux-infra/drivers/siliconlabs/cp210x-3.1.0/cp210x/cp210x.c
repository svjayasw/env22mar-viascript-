/*
 * cp210x.c
 *
 * Silicon Laboratories CP210x Serial Adaptor Driver for Linux
 *
 * Copyrigt:	(C) 2008 Silicon Labs
 * Author:	Douglas Olson
 *
 * Contact:	mcutools@silabs.com
 *
 * Copyright (C) 1999 - 2002 Greg Kroah-Hartman (greg@kroah.com)
 *
 * A special thanks to R. Steve McKown for help with port configuration,
 *	usb descriptor and gpio management (smckown@titaniummirror.com).
 *
 * Portions of this driver are based on drivers/usb/serial/io_edgeport.c
 *	which is:
 *		Copyright (C) 2000 Inside Out Networks, All rights reserved.
 *		Copyright (C) 2001-2002 Greg Kroah-Hartman <greg@kroah.com>
 *
 * This code was also based on the original Silicon Laboratories
 *	CP2101/CP2102 USB to RS232 serial adaptor driver CP2101.c:
 *		Copyright (C) 2005 Craig Shelley (craig@microtron.org.uk)
 *
 * Updated for latest devices and version 2.6.29
 *	Copyright (C) 2009 by Firmlogix <rmsith@firmlogix.com>
 *	Support from Silicon Laboratories Inc. <MCU.Tools@silabs.com>
 *
 * The following devices are supported with this driver:
 *	CP2101
 *	CP2102
 *	CP2103
 *	CP2104
 *	CP2105
 *
 *
 * GNU GPL
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 2 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111 USA
 *
 *	This program is largely derived from work by the linux-usb group
 *	and associated source files.  Please see the usb/serial files for
 *	individual credits and copyrights.
 *
 *
 * Support
 *	In case of questions or problems, please write to the contact e-mail
 *	address mentioned above.
 *
 *	The latest version of the driver can be found at
 *	http:
 *
 * See Documentation/usb/usb-serial.txt for more information
 * on using this driver
 *
 * 03-June-2008 dgo
 *	Initial Release
 *
 * 22-August-2008 Paragon
 *	Bugfix in cp210x_internal_ioctl( ) when calling IOCTL_GPIOSET:
 *	Return value must be 0 when cp210x_gpioset() returns 0 (correct)
 *
 */
/* version from 2.6.29/30 */

#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/tty.h>
#include <linux/tty_driver.h>
#include <linux/tty_flip.h>
#include <linux/module.h>
#include <linux/spinlock.h>
#include <linux/version.h>

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 26))
#include "cp210xuniversal.c"
#else
#include <linux/mutex.h>
#include <linux/kthread.h>

/*
 * Debug
 */
static int debug;

#include <linux/usb.h>
#include <linux/serial.h>
//#include "cp210x.h"


/*
 *  Setup versioning
 */
#ifndef KERNEL_VERSION
#define KERNEL_VERSION(a,b,c) ((a)*65536 + (b)*256 + (c))
#endif

#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,0)

#ifdef LINUX26
#undef LINUX26
#endif

#define LINUX26
#endif


/*
 *  Include the proper header files
 */

#include <linux/moduleparam.h>
#include <linux/usb/serial.h>


#ifndef __user
/* no checker support, so we unconditionally define this as (null) */
#define __user
#endif



#ifndef __iomem
/* no checker support, so we unconditionally define this as (null) */
#define __iomem
#endif

#ifndef NULL
#define NULL
#endif

#ifndef FALSE
#define FALSE (0)
#endif

#ifndef TRUE
#define TRUE (1)
#endif

#ifndef SILABS_SUCCESS
#define SILABS_SUCCESS (0)
#endif

#ifndef SILABS_FAIL
#define SILABS_FAIL	(-1)
#endif

#ifndef __le32
#define __le32	u32
#endif

#ifndef gfp_t
#define gfp_t		int
#endif

#ifndef USB_ASYNC_UNLINK
#define USB_ASYNC_UNLINK (0)
#endif


#ifndef ktermios
#define ktermios	termios
#endif


/*
 * Private Redefinitions From serial.h etc.
 */

// Required for XON/XOFF support
#define SILABS_RELEVANT_IFLAG(iflag) \
	(iflag & (IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK|IXON|IXOFF))

/*
 *
 */

/*#define DEV_ERR(dev,format,arg...) dev_err(dev, format, ## arg)*/
//#define USB_KILL_URB usb_kill_urb

//#define USB_SUBMIT_URB_ATOMIC(_x_) usb_submit_urb(_x_ , GFP_ATOMIC)
//#define USB_SUBMIT_URB_KERNEL(_x_) usb_submit_urb(_x_ , GFP_KERNEL)

/*
 * Configuration Request Types
 */
#define REQTYPE_HOST_TO_DEVICE			0x41
#define REQTYPE_DEVICE_TO_HOST			0xc1

/*
 * Configuration Request Codes
 */
#define SILABSER_IFC_ENABLE_REQUEST_CODE	0x00
#define SILABSER_SET_BAUDDIV_REQUEST_CODE	0x01
#define SILABSER_GET_BAUDDIV_REQUEST_CODE	0x02
#define SILABSER_SET_LINE_CTL_REQUEST_CODE	0x03
#define SILABSER_GET_LINE_CTL_REQUEST_CODE	0x04
#define SILABSER_SET_BREAK_REQUEST_CODE		0x05
#define SILABSER_IMM_CHAR_REQUEST_CODE		0x06
#define SILABSER_SET_MHS_REQUEST_CODE		0x07
#define SILABSER_GET_MDMSTS_REQUEST_CODE	0x08
#define SILABSER_SET_XON_REQUEST_CODE		0x09
#define SILABSER_SET_XOFF_REQUEST_CODE		0x0A
#define SILABSER_SET_EVENTMASK_REQUEST_CODE	0x0B
#define SILABSER_GET_EVENTMASK_REQUEST_CODE	0x0C
#define SILABSER_SET_CHAR_REQUEST_CODE		0x0D
#define SILABSER_GET_CHARS_REQUEST_CODE		0x0E
#define SILABSER_GET_PROPS_REQUEST_CODE		0x0f
#define SILABSER_GET_COMM_STATUS_REQUEST_CODE	0x10
#define SILABSER_RESET_REQUEST_CODE		0x11
#define SILABSER_PURGE_REQUEST_CODE		0x12
#define SILABSER_SET_FLOW_REQUEST_CODE		0x13
#define SILABSER_GET_FLOW_REQUEST_CODE		0x14
#define SILABSER_EMBED_EVENTS_REQUEST_CODE	0x15
#define SILABSER_GET_EVENTSTATE_REQUEST_CODE	0x16
#define SILABSER_SET_CHARS_REQUEST_CODE		0x19
#define SILABSER_GET_BAUDRATE			0x1D
#define SILABSER_SET_BAUDRATE			0x1E

/*
 * CP2103 GPIO Configuration
 */
#define SILABS_GPIO_REQTYPE_HOST_TO_DEVICE	0x40
#define SILABS_GPIO_REQTYPE_DEVICE_TO_HOST	0xc0
#define SILABS_GPIO_SPECIFIC			0xff
#define SILABS_GPIO_READ_LATCH			0x0b
#define SILABS_GPIO_WRITE_LATCH			0xe1
#define SILABS_GPIO_KEY_VALUE			0x37

#define CP210x_GPIO_0				0x01
#define CP210x_GPIO_1				0x02
#define CP210x_GPIO_2				0x04
#define CP210x_GPIO_3				0x08

/*
 * SILABSER_IFC_ENABLE_REQUEST_CODE
 */
#define UART_ENABLE				0x0001
#define UART_DISABLE				0x0000

/*
 * SILABSER_SET_BAUDDIV_REQUEST_CODE
 */
#define BAUD_RATE_GEN_FREQ			0x384000

/*
 * SILABSER_SET_LINE_CTL_REQUEST_CODE
 */
#define BITS_DATA_MASK				0x0f00
#define BITS_DATA_5				0x0500
#define BITS_DATA_6				0x0600
#define BITS_DATA_7				0x0700
#define BITS_DATA_8				0x0800
#define BITS_DATA_9				0x0900

#define BITS_PARITY_MASK			0x00f0
#define BITS_PARITY_NONE			0x0000
#define BITS_PARITY_ODD				0x0010
#define BITS_PARITY_EVEN			0x0020
#define BITS_PARITY_MARK			0x0030
#define BITS_PARITY_SPACE			0x0040

#define BITS_STOP_MASK				0x000f
#define BITS_STOP_1				0x0000
#define BITS_STOP_1_5				0x0001
#define BITS_STOP_2				0x0002

/*
 * SILABSER_SET_BREAK_REQUEST_CODE
 */
#define BREAK_ON				0x0001
#define BREAK_OFF				0x0000

/*
 * SILABSER_SET_MHS_REQUEST_CODE
 */
#define MCR_DTR					0x0001
#define MCR_RTS					0x0002
#define MCR_ALL					0x0003
#define MSR_CTS					0x0010
#define MSR_DSR					0x0020
#define MSR_RING				0x0040
#define MSR_DCD					0x0080
#define MSR_ALL					0x00F0

#define CONTROL_WRITE_DTR			0x0100
#define CONTROL_WRITE_RTS			0x0200

#define LSR_BREAK				0x0001
#define LSR_FRAMING_ERROR			0x0002
#define LSR_HW_OVERRUN				0x0004
#define LSR_QUEUE_OVERRUN			0x0008
#define LSR_PARITY_ERROR			0x0010
#define LSR_ALL					0x001F

/*
 * IOCTLs - dgo make sure we have no conflicts here
 */
#define IOCTL_GPIOGET				0x8000
#define IOCTL_GPIOSET				0x8001

#define IOCTL_PROPGET				0x8002

#define IOCTL_PROPGETLENGTH			0x8004

#define IOCTL_FLOW_CONTROLGET			0x8006
#define IOCTL_FLOW_CONTROLSET			0x8007

#define IOCTL_SPECIAL_CHARGET			0x8008
#define IOCTL_SPECIAL_CHARSET			0x8009

#define IOCTL_XOFFSET				0x800b
#define IOCTL_XONSET				0x800d

#define IOCTL_EMBED_EVENTS			0x8015


/*
 * Function Prototypes
 */
static void cp210x_handle_new_modem_status(struct usb_serial_port *port,
						unsigned int modem_status);

static void cp210x_handle_new_line_status(struct usb_serial_port *port);

static int cp210x_control_thread(void *port);

static int cp210x_start_control_thread(struct usb_serial_port *port);

static void cp210x_stop_control_thread(struct usb_serial_port *port);

static void cp210x_cleanup_port(struct usb_serial_port *port);

static int  silabs_cp210x_open(struct tty_struct *tty,
				struct usb_serial_port *port,
				struct file *filp);

static void silabs_cp210x_close(struct tty_struct *tty,
				struct usb_serial_port *port,
				struct file *filp);

static int  silabs_cp210x_tiocmget(struct tty_struct *tty, struct file *file);

static int  silabs_cp210x_tiocmset(struct tty_struct *tty, struct file *file,
					unsigned int set, unsigned int clear);

static void silabs_cp210x_break_ctl(struct tty_struct *tty, int break_state);

static int  silabs_cp210x_startup(struct usb_serial *serial);

static void silabs_cp210x_shutdown(struct usb_serial *serial);

static void silabs_cp210x_throttle(struct tty_struct *tty);

static void silabs_cp210x_unthrottle(struct tty_struct *tty);

static void silabs_cp210x_read_bulk_callback(struct urb *urb);

static void silabs_cp210x_write_bulk_callback(struct urb *urb);

static int silabs_cp210x_ioctl(struct tty_struct *tty, struct file *file,
				unsigned int cmd, unsigned long arg);

static void cp210x_get_termios(struct usb_serial_port *port);

static int cp210x_get_serialstat(struct usb_serial_port *port);

static int cp210x_get_commprops(struct usb_serial_port *port);

static int silabs_cp210x_write_room(struct tty_struct *tty);

static int silabs_cp210x_chars_in_buffer(struct tty_struct *tty);

static int cp210x_get_partnum(struct usb_serial_port *port);

static int silabs_cp210x_write(struct usb_serial_port *port,
						int from_user,
						const unsigned char *buf,
						int count);

static void silabs_cp210x_set_termios(struct tty_struct *tty,
					struct usb_serial_port *port,
					struct ktermios *old);

static int silabs_cp210x_calc_num_ports(struct usb_serial *serial);

static int silabs_cp210x_write_wrapper(struct tty_struct *tty,
					struct usb_serial_port *port,
					const unsigned char *buf, int count);

static int silabs_cp210x_probe(struct usb_interface *interface,
						const struct usb_device_id *id);

static int silabs_cp210x_suspend(struct usb_serial *serial,
						pm_message_t message);

static int silabs_cp210x_resume(struct usb_serial *serial);

enum cp210x_type {
	none,
	cp2101,
	cp2102,
	cp2103,
	cp2105
};

/* Table 7. Communication Properties Response */
struct CommProps {
	__u16				wLength;
	__u16				bcdVersion;
	__u32				ulSericeMask;
	__u32				ulReserved1;
	__u32				ulMaxTxQueue;
	__u32				ulMaxRxQueue;
	__u32				ulMaxBaud;
	__u32				ulProvSubType;
	__u32				ulProvCapabilities;
	__u32				ulSettableParams;
	__u32				ulSettableBaud;
	__u16				wSettableData;
	__u16				wSettableStopParity;
	__u32				ulCurrentTxQueue;
	__u32				ulCurrentRxQueue;
	__u32				ulProvSpec1;
	__u32				ulProvSpec2;
	__u8				*uniProvName;
};

/* Table 8. Serial Status Response */
struct SerialStat {
	__u32				ulErrors;
	__u32				ulHoldReasons;
	__u32				ulAmountIn_InQueue;
	__u32				ulAmountIn_OutQueue;
	__u8				bEofReceived;
	__u8				bWaitForImmediate;
	__u8				bReserved;
};

/* Table 10. ulControlHandshake *?
#define CtrlHandshake_DTR_Mask			0x00000003
/* Reserved- always zero */
#define CtrlHandshake_AlwaysZero_Mask		0x00000004

/* 0: status; 1: handshake */
#define CtrlHandshake_CTS_Handshake_Mask	0x00000008

/* 0: status; 1: handshake */
#define CtrlHandshake_DSR_Handshake_Mask	0x00000010

/* 0: status; 1: handshake */
#define CtrlHandshake_DCD_Handshake_Mask	0x00000020

/* 0: status; 1: discards data */
#define CtrlHandshake_DSR_Sensitivity_Mask	0x00000040

/* Reserved */
#define CtrlHandshake_Reserved_Mask		0xFFFFFF80

/* DTR is held inactive */
#define CtrlHandshake_DTR_Inactive		0x00000000

/* DTR is held active */
#define CtrlHandshake_DTR_Active		0x00000001

/* DTR is controlled by port firmware */
#define CtrlHandshake_DTR_Firmware		0x00000002

/* Reserved */
#define CtrlHandshake_DTR_Reserved		0x00000003


/* Table 11. ulFlowReplace */
/* 0: Off; 1: firmware processes received Xon/Xoff chars */
#define FlowReplace_Auto_Transmit_Mask		0x00000001

/* 0: Off; 1: firmware will transmit Xon/Xoff chars */
#define FlowReplace_Auto_Receive_Mask		0x00000002

/* 0: character is discarded; 1: ERROR character is inserted */
#define FlowReplace_Error_Char_Mask		0x00000004

/* 0: off; 1: device will strip NULL characters */
#define FlowReplace_NULL_Striping_Mask		0x00000008

/* 0: only bit error mask set; 1: mask set ahd BREAK char inserted */
#define FlowReplace_Break_Char_Mask		0x00000010

/* Reserved */
#define FlowReplace_Reserved_Mask		0x00000020

#define FlowReplace_RTS_Mask			0x000000C0

/* Reverved - Must be written as zero */
#define FlowReplace_Always_Zero			0x7FFFFF00

#define FlowReplace_XOFF_Continue_Mask		0x80000000

/* RTS is held inactive */
#define FlowReplace_RTS_Statically_Inactive	0x00000000

/* RTS is held active */
#define FlowReplace_RTS_Statically_Active	0x00000040

/* RTS is controlled by port firmware for receive flow */
#define FlowReplace_RTS_Receive_Flow		0x00000080

/* RTS held active while transmitting */
#define FlowReplace_RTS_Transmit_Active		0x000000C0

/* Table 9. Flow Control Setting/Response */
struct CommFlow {
	__u32				controlHandshake;
	__u32				flowReplace;
	__u32				ulXonLimit;
	__u32				ulXoffLimit;
};

/* Table 12. Special Characters Response */
#define SpecialChars_bEofChar_Mask	0x01
#define SpecialChars_bErrorChar_Mask	0x02
#define SpecialChars_bBreakChar_Mask	0x04
#define SpecialChars_bEventChar_Mask	0x08
#define SpecialChars_bXonChar_Mask	0x10
#define SpecialChars_bXoffChar_Mask	0x20

/* jiffies time out values. */
#define TIMEOUT_1ms	((1*HZ)/1000)	/* 1 milliseconds */
#define TIMEOUT_10ms	((1*HZ)/100)	/* 10 milliseconds */
#define TIMEOUT_100ms	((1*HZ)/10)	/* 100 milliseconds */
#define TIMEOUT_1s	((1*HZ))	/* 1 second */

#ifndef SERIAL_MAGIC
	#define SERIAL_MAGIC	0x6702
#endif

#ifndef PORT_MAGIC
#define PORT_MAGIC		0x7301
#endif

/* Transmit Fifo
 * This Transmit queue is an extension of the Rx buffer.
 * The maximum amount of data buffered in both the
 * Rx buffer (maxTxCredits) and this buffer will never exceed maxTxCredits.
 */
struct circular_buf_txfifo {
	unsigned int	head;	/* index to head pointer (write) */
	unsigned int	tail;	/* index to tail pointer (read)  */
	unsigned int	count;	/* Bytes in queue */
	unsigned int	size;	/* Max size of queue (equal to MaxTxCredits) */
	unsigned char	*fifo;	/* allocated Buffer */
};



struct cp210x_port_private {
	__u16		txCredits;	/* our current credits for port */
	__u16		maxTxCredits;	/* the max size of the port */
	struct mutex				controlPipeMutex;
	/* transmit fifo -- size will be maxTxCredits */
	struct circular_buf_txfifo	circular_buf_txfifo;
	struct urb	*write_urb;	/* write URB for this port */
	char		write_busy;	/* 1 if a write URB is outstanding */

	__u8		shadowLCR;	/* last LCR value received */
	__u8		shadowMSR;	/* last MSR value received */
	__u8		shadowLSR;	/* last LSR value received */
	__u8		shadowXonChar;	/* last value set as XON char */
	__u8		shadowXoffChar;	/* last value set as XOFF char */
	__u8		validDataMask;
	__u32		baudRate;

	char		open;
	char		openPending;
	char		commandPending;
	char		closePending;
	char		chaseResponsePending;

	wait_queue_head_t	wait_control;
	wait_queue_head_t	wait_open;
	/* for sleeping while waiting for command to finish */
	wait_queue_head_t	wait_command;
	/* for sleeping while waiting for msr change to happen */
	wait_queue_head_t	delta_msr_wait;

	struct async_icount	icount;
	/* loop back to the owner of this object */
	struct usb_serial_port	*port;

	spinlock_t		portLock;
	char			throttled;
	char			throttle_req;
	struct SerialStat	serialstat;
	struct CommProps	commprops;
	struct termios		orig_termios;
	struct termios		curr_termios;
	struct task_struct	task_struct;
	__u8			termios_initialized;
	__u8			mcr;
	__u8			msr;
	__u8			lsr;
	__u8			line_control;
	__u8			run_cp210x_control_thread;

	__u8			bulk_in_endpoint;
	unsigned char		*bulk_in_buffer;
	struct urb		*read_urb;
	__u8			bulk_out_endpoint;

	struct task_struct	*cp210x_task;
	__u8			bInterfaceNumber;
};


struct cp210x_serial_private {
	/* loop back to the owner of this object */
	struct usb_serial	*serial;
	spinlock_t		devLock;
	enum cp210x_type	devType;
	int			numberOfPorts;
};


/*
 * Version Information
 */
#define DRIVER_VERSION "v1.10.0"
#define DRIVER_AUTHOR "RMS"
#define DRIVER_DESC "Silicon Labs CP210x USB Serial Adaptor Driver"

static struct usb_device_id silabs_cp210x_device_ids[] = {
{ USB_DEVICE(0x0471, 0x066A) }, /* AKTAKOM ACE-1001 cable */
{ USB_DEVICE(0x0489, 0xE000) }, /* Pirelli Broadband S.p.A, DP-L10 SIP/GSM */
{ USB_DEVICE(0x08e6, 0x5501) }, /* Gemalto Prox-PU/CU smartcard reader */
{ USB_DEVICE(0x0FCF, 0x1003) }, /* Dynastream ANT development board */
{ USB_DEVICE(0x0FCF, 0x1004) }, /* Dynastream ANT2USB */
{ USB_DEVICE(0x0FCF, 0x1006) }, /* Dynastream ANT development board */
{ USB_DEVICE(0x10A6, 0xAA26) }, /* Knock-off DCU-11 cable */
{ USB_DEVICE(0x10AB, 0x10C5) }, /* Siemens MC60 Cable */
{ USB_DEVICE(0x10B5, 0xAC70) }, /* Nokia CA-42 USB */
{ USB_DEVICE(0x10C4, 0x800A) }, /* SPORTident BSM7-D-USB main station */
{ USB_DEVICE(0x10C4, 0x803B) }, /* Pololu USB-serial converter */
{ USB_DEVICE(0x10C4, 0x8053) }, /* Enfora EDG1228 */
{ USB_DEVICE(0x10C4, 0x8054) }, /* Enfora GSM2228 */
{ USB_DEVICE(0x10C4, 0x8066) }, /* Argussoft In-System Programmer */
{ USB_DEVICE(0x10C4, 0x807A) }, /* Crumb128 board */
{ USB_DEVICE(0x10C4, 0x80CA) }, /* Degree Controls Inc */
{ USB_DEVICE(0x10C4, 0x80DD) }, /* Tracient RFID */
{ USB_DEVICE(0x10C4, 0x80F6) }, /* Suunto sports instrument */
{ USB_DEVICE(0x10C4, 0x8115) }, /* Arygon NFC/Mifare Reader */
{ USB_DEVICE(0x10C4, 0x813D) }, /* Burnside Telecom Deskmobile */
{ USB_DEVICE(0x10C4, 0x814A) }, /* West Mountain Radio RIGblaster P&P */
{ USB_DEVICE(0x10C4, 0x814B) }, /* West Mountain Radio RIGtalk */
{ USB_DEVICE(0x10C4, 0x815E) }, /* Helicomm IP-Link 1220-DVM */
{ USB_DEVICE(0x10C4, 0x819F) }, /* MJS USB Toslink Switcher */
{ USB_DEVICE(0x10C4, 0x81A6) }, /* ThinkOptics WavIt */
{ USB_DEVICE(0x10C4, 0x81AC) }, /* MSD Dash Hawk */
{ USB_DEVICE(0x10C4, 0x81C8) }, /* Lipowsky Industrie Elektronik, Baby-JTAG */
{ USB_DEVICE(0x10C4, 0x81E2) }, /* Lipowsky Industrie Elektronik, Baby-LIN */
{ USB_DEVICE(0x10C4, 0x81E7) }, /* Aerocomm Radio */
{ USB_DEVICE(0x10C4, 0x8218) }, /* Lipowsky Industrie Elektronik, HARP-1 */
{ USB_DEVICE(0x10C4, 0x822B) }, /* Modem EDGE(GSM) Comander 2 */
{ USB_DEVICE(0x10C4, 0x826B) }, /* Cygnal Fasttrax GPS demostration module */
{ USB_DEVICE(0x10c4, 0x8293) }, /* Telegesys ETRX2USB */
{ USB_DEVICE(0x10C4, 0x8341) }, /* Siemens MC35PU GPRS Modem */
{ USB_DEVICE(0x10C4, 0x83A8) }, /* Amber Wireless AMB2560 */
{ USB_DEVICE(0x10C4, 0x846E) }, /* BEI USB Sensor Interface (VCP) */
{ USB_DEVICE(0x10C4, 0xEA60) }, /* Silicon Labs factory default */
{ USB_DEVICE(0x10C4, 0xEA61) }, /* Silicon Labs factory default */
{ USB_DEVICE(0x10C4, 0xEA70) }, /* Silicon Labs Dual Port factory default */
{ USB_DEVICE(0x10C4, 0xF001) }, /* Elan Digital Systems USBscope50 */
{ USB_DEVICE(0x10C4, 0xF002) }, /* Elan Digital Systems USBwave12 */
{ USB_DEVICE(0x10C4, 0xF003) }, /* Elan Digital Systems USBpulse100 */
{ USB_DEVICE(0x10C4, 0xF004) }, /* Elan Digital Systems USBcount50 */
{ USB_DEVICE(0x10C5, 0xEA61) }, /* Silicon Labs MobiData GPRS USB Modem */
{ USB_DEVICE(0x13AD, 0x9999) }, /* Baltech card reader */
{ USB_DEVICE(0x166A, 0x0303) }, /* Clipsal 5500PCU C-Bus USB interface */
{ USB_DEVICE(0x16D6, 0x0001) }, /* Jablotron serial interface */
{ USB_DEVICE(0x18EF, 0xE00F) }, /* ELV USB-I2C-Interface */
{ } /* Terminating Entry */
};

MODULE_DEVICE_TABLE(usb, silabs_cp210x_device_ids);

/*
 *
 *  Distributions 2.6.23 and above
 *
 */

static struct usb_driver silabs_cp210x_driver = {
.name					= "silabs_cp210x_cp210x",
.probe					= silabs_cp210x_probe,
.disconnect				= usb_serial_disconnect,
.id_table				= silabs_cp210x_device_ids,
.no_dynamic_id				= 1,
};

static struct usb_serial_driver silabs_cp210x_device = {
.id_table				= silabs_cp210x_device_ids,
.num_ports				= 1,
.driver = {
.owner				= THIS_MODULE,
.name				= "SiLabs-cp210x",
},
.usb_driver				= &silabs_cp210x_driver,
.attach					= silabs_cp210x_startup,
/* the shutdown field was removed with newer kernels             */
/*.shutdown				= silabs_cp210x_shutdown,*/
.suspend				= silabs_cp210x_suspend,
.resume					= silabs_cp210x_resume,
.open					= silabs_cp210x_open,
.close					= silabs_cp210x_close,
.write					= silabs_cp210x_write_wrapper,
.write_room				= silabs_cp210x_write_room,
.ioctl					= silabs_cp210x_ioctl,
.set_termios			= silabs_cp210x_set_termios,
.break_ctl				= silabs_cp210x_break_ctl,
.chars_in_buffer		= silabs_cp210x_chars_in_buffer,
.throttle				= silabs_cp210x_throttle,
.unthrottle				= silabs_cp210x_unthrottle,
.tiocmget				= silabs_cp210x_tiocmget,
.tiocmset				= silabs_cp210x_tiocmset,
.read_bulk_callback		= silabs_cp210x_read_bulk_callback,
.write_bulk_callback	= silabs_cp210x_write_bulk_callback,
};

/*
 * cp210x_get_config_bytes
 * Reads from the SILABS configuration registers
 * 'size' is specified in bytes.
 * 'data' is a pointer to a pre-allocated array of bytes large
 * enough to hold 'size' bytes (with 4 bytes to each integer)
 */
static int cp210x_get_config_bytes(struct usb_serial_port *port, u8 request,
		unsigned char *data, int size)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);
	struct usb_serial *serial = port->serial;
	u8 *buf;
	int result, i;

	mutex_lock(&port_priv->controlPipeMutex);
	buf = kmalloc(size * sizeof(u8), GFP_KERNEL);
	memset(buf, 0, size * sizeof(u8));

	if (!buf) {
		mutex_unlock(&port_priv->controlPipeMutex);
		dev_err(&port->dev, "%s - out of memory.\n", __func__);
		return -ENOMEM;
	}

	/* Issue the request, attempting to read 'size' bytes */
	result = usb_control_msg(serial->dev,
					usb_rcvctrlpipe(serial->dev, 0),
					request,
					REQTYPE_DEVICE_TO_HOST,
					0x0000,
					port_priv->bInterfaceNumber,
					buf,
					size,
					300);

	/* Convert data into an array of integers */
	for (i = 0; i < size; i++)
		data[i] = buf[i];

	kfree(buf);

	if ((result != size) && (request != SILABSER_GET_PROPS_REQUEST_CODE)) {
		mutex_unlock(&port_priv->controlPipeMutex);
		dev_err(&port->dev,
			"%s - get_config_bytes unable to send config request, "
			"request=0x%x size=%d result=%d\n",
			__func__, request, size, result);
		return -EPROTO;
	}
	mutex_unlock(&port_priv->controlPipeMutex);
	return result;
}

/*
 * cp210x_get_config
 * Reads from the SILABS configuration registers
 * 'size' is specified in bytes.
 * 'data' is a pointer to a pre-allocated array of integers large
 * enough to hold 'size' bytes (with 4 bytes to each integer)
 */

static int cp210x_get_config(struct usb_serial_port *port, u8 request,
		unsigned int *data, int size)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	struct usb_serial *serial = port->serial;

	__le32 *buf;

	int result, i, length;

	mutex_lock(&port_priv->controlPipeMutex);

	/* Number of integers required to contain the array */
	length = (((size - 1) | 3) + 1)/4;

	buf = kcalloc(length, sizeof(__le32), GFP_KERNEL);

	if (!buf) {
		mutex_unlock(&port_priv->controlPipeMutex);
		dev_err(&port->dev, "%s - out of memory.\n", __func__);
		return -ENOMEM;
	}

	memset(buf, 0, length * sizeof(__le32));

	/* Issue the request, attempting to read 'size' bytes */
	result = usb_control_msg(serial->dev,
					usb_rcvctrlpipe(serial->dev, 0),
					request,
					REQTYPE_DEVICE_TO_HOST,
					0x0000,
					port_priv->bInterfaceNumber,
					buf,
					size,
					300);

	/* Convert data into an array of integers */
	for (i = 0; i < length; i++)
		data[i] = le32_to_cpu(buf[i]);

	kfree(buf);

	if (result != size) {
		mutex_unlock(&port_priv->controlPipeMutex);
		dev_err(&port->dev,
				"%s - get_config did not send config request, "
				"request=0x%x size=%d result=%d\n",
				__func__, request, size, result);
		return -EPROTO;
	}

	mutex_unlock(&port_priv->controlPipeMutex);
	return 0;
}

/*
 * cp210x_set_config
 * Writes to the SILABS configuration registers
 * Values less than 16 bits wide are sent directly
 * 'size' is specified in bytes.
 */
static int cp210x_set_config(struct usb_serial_port *port, u8 request,
		unsigned int *data, int size)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	struct usb_serial *serial = port->serial;

	__le32 *buf;

	int result, i, length;

	mutex_lock(&port_priv->controlPipeMutex);

	if (size == 0) {
		result = usb_control_msg(
				serial->dev,
				usb_sndctrlpipe(serial->dev, 0),
				request,
				REQTYPE_HOST_TO_DEVICE,
				data[0],
				port_priv->bInterfaceNumber,
				NULL,
				0,
				300);

		if (result < 0) {
			mutex_unlock(&port_priv->controlPipeMutex);

			dev_err(&port->dev,
				"%s - set_config unable to send request, "
				"request=0x%x size=%d result=%d data=%d\n",
				__func__, request, size, result, data[0]);
			return -EPROTO;

		}
	} else {
		/* Number of integers required to contain the array */
		length = (((size - 1) | 3) + 1)/4;

		buf = kmalloc(length * sizeof(__le32), GFP_KERNEL);

		if (!buf) {
			mutex_unlock(&port_priv->controlPipeMutex);
			dev_err(&port->dev, "%s - out of memory.\n", __func__);
			return -ENOMEM;
		}

		/* Array of integers into bytes */
		for (i = 0; i < length; i++)
			buf[i] = cpu_to_le32(data[i]);

		result = usb_control_msg(
				serial->dev,
				usb_sndctrlpipe(serial->dev, 0),
				request,
				REQTYPE_HOST_TO_DEVICE,
				0x0000,
				port_priv->bInterfaceNumber,
				buf,
				size,
				300);

		kfree(buf);

		if (result != size) {
			mutex_unlock(&port_priv->controlPipeMutex);
			dev_err(&port->dev,
				"%s - set_config unable to send request, "
				"request=0x%x size=%d result=%d\n",
				__func__, request, size, result);
			return -EPROTO;
		}
	}

	mutex_unlock(&port_priv->controlPipeMutex);
	return 0;
}

/*
 * cp210x_set_config_single
 * Convenience function for calling cp210x_set_config on single data values
 * without requiring an integer pointer
 */
static inline int cp210x_set_config_single(struct usb_serial_port *port,
		u8 request, unsigned int data)
{
	return cp210x_set_config(port, request, &data, 0);
}

/* get the tty_struct if valid port */
struct tty_struct *get_tty_port(struct usb_serial_port *usb_port)
{
    if (usb_port && (0 != usb_port->port.tty))
		return usb_port->port.tty;
    return 0;
}

int silabs_cp210x_open(struct tty_struct *tty,
			struct usb_serial_port *port, struct file *filp)
{
	struct usb_serial				*serial;
	struct cp210x_serial_private	*serial_priv;
	struct cp210x_port_private		*port_priv;
	int result = 0;
	int timeout = 0;
	int open_retry_cnt = 5;
	char *throttled;
	char *throttle_req;

	int *write_urb_busy;
	port_priv = usb_get_serial_port_data(port);

	if (port_priv == NULL) {
		dev_err(&port->dev,
			"%s - port %d port_priv == NULL\n",
			__func__,
			port->number);
		return -ENODEV;
	}

	serial = port->serial;

	serial_priv = usb_get_serial_data(serial);

	if (serial_priv == NULL) {
		dev_err(&port->dev,
			"%s - port %d serial_priv == NULL\n",
			__func__,
			port->number);
		return -ENODEV;
	}

	port_priv->bInterfaceNumber =
		serial->interface->cur_altsetting->desc.bInterfaceNumber;
	write_urb_busy = &port->write_urb_busy;
	throttled = &port->throttled;
	throttle_req = &port->throttle_req;

	usb_clear_halt(serial->dev, port->write_urb->pipe);
	usb_clear_halt(serial->dev, port->read_urb->pipe);

/*
 * force low_latency on so that our tty_push actually forces the data through,
 * otherwise it is scheduled, and with high data rates (like with OHCI) data
 * can get lost.
 */
	if (get_tty_port(port))
		get_tty_port(port)->low_latency = 1;

	if (serial->num_bulk_in) {
		port_priv->bulk_in_buffer = port->bulk_in_buffer;
		port_priv->bulk_in_endpoint = port->bulk_in_endpointAddress;
		port_priv->read_urb = port->read_urb;

		port_priv->bulk_out_endpoint = port->bulk_out_endpointAddress;

		/* Start reading from the device */
		usb_fill_bulk_urb(port->read_urb,
					serial->dev,
					usb_rcvbulkpipe(serial->dev,
						port->bulk_in_endpointAddress),
					port->read_urb->transfer_buffer,
					port->read_urb->transfer_buffer_length,
					silabs_cp210x_read_bulk_callback,
					port);

		port_priv->read_urb->dev = serial_priv->serial->dev;
		result = usb_submit_urb(port_priv->read_urb, GFP_KERNEL);
		if (result) {
			dev_err(&port->dev,
				"%s - resubmit read error: %d on port %d\n",
				__func__,
				result,
				port->number);
			return result;
		}
	}

	/* initialize our wait queues */
	init_waitqueue_head(&port_priv->wait_open);
	init_waitqueue_head(&port_priv->wait_control);
	init_waitqueue_head(&port_priv->delta_msr_wait);
	init_waitqueue_head(&port_priv->wait_command);

	/* initialize our icount structure */
	memset(&(port_priv->icount), 0x00, sizeof(port_priv->icount));

	/* initialize our port settings */
	port_priv->txCredits		= 0;	/* Can't send any data yet */
	port_priv->mcr			= 0;
	port_priv->line_control		= 0;
	port_priv->chaseResponsePending = FALSE;

	/* clear the throttle flags */
	*throttled = 0;
	*throttle_req = 0;

	/* set write urb to not busy */
	*write_urb_busy = 0;

	/* send a open port command */
	port_priv->openPending		= TRUE;
	port_priv->open			= FALSE;
	port_priv->termios_initialized	= FALSE;

	if (cp210x_set_config_single(port,
				SILABSER_IFC_ENABLE_REQUEST_CODE,
				UART_ENABLE)) {

		dev_err(&port->dev,
			"%s - Unable to enable UART on port %d\n",
			__func__,
			port->number);
		return -EPROTO;
	}

	cp210x_get_serialstat(port);

	/* now wait for the port to be completly opened */
	for ( ; open_retry_cnt && port_priv->open == FALSE; open_retry_cnt--) {
		timeout = 5 * TIMEOUT_100ms;	/* 500 milliseconds */
		while (timeout && port_priv->openPending == TRUE) {
			timeout = interruptible_sleep_on_timeout(
						&port_priv->wait_open,
						timeout);
		}
		cp210x_get_serialstat(port);
	}

	if (port_priv->open == FALSE) {
		/* open timed out */
		dev_err(&port->dev,
			"%s - Open timed out on port %d\n",
			__func__,
			port->number);
		port_priv->openPending = FALSE;
		return -ENODEV;
	}

	port_priv->lsr = (__u8) port_priv->serialstat.ulErrors;
	cp210x_get_commprops(port);

	/* Use N_TTY_BUF_SIZE (4096) or PAGE_SIZE */
	port_priv->maxTxCredits = min((port_priv->commprops.ulCurrentTxQueue),
						(unsigned int) N_TTY_BUF_SIZE);

	/* create the circular_buf_txfifo */
	port_priv->circular_buf_txfifo.head	= 0;
	port_priv->circular_buf_txfifo.tail	= 0;
	port_priv->circular_buf_txfifo.count	= 0;
	port_priv->circular_buf_txfifo.size	= port_priv->maxTxCredits;
	port_priv->circular_buf_txfifo.fifo	=
				kmalloc(port_priv->maxTxCredits, GFP_KERNEL);

	if (!port_priv->circular_buf_txfifo.fifo) {
		dev_err(&port->dev,
			"%s - out of kernel memory circular_buf_txfifo.fifo\n",
			__func__);
		silabs_cp210x_close(tty, port, filp);
		return -ENOMEM;
	}

	port_priv->write_urb = usb_alloc_urb(0, GFP_ATOMIC);
	if (!port_priv->write_urb) {
		dev_err(&port->dev,
			"%s - no more kernel memory write_urb...\n",
			__func__);
		silabs_cp210x_close(tty, port, filp);
		return -ENOMEM;
	}

	if (get_tty_port(port)) {
		/* Save off the original port termios */
		cp210x_get_termios(port);

		/* Configure the termios structure */
		silabs_cp210x_set_termios(tty, port, NULL);
	}

	port_priv->run_cp210x_control_thread = TRUE;
	cp210x_start_control_thread(port);

	port_priv->txCredits = port_priv->maxTxCredits;	/* allow writes */
	return result;
}

static void cp210x_close_port(struct usb_serial_port *port)
{
	struct usb_serial *serial = port->serial;

	struct cp210x_port_private	*port_priv;

	port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d", __func__, port->number);

	if (serial != NULL && serial->dev) {
		/* shutdown any bulk reads that might be going on */
		if (serial->num_bulk_out) {
			usb_kill_urb(port->write_urb);
			if (port_priv->write_urb)
				usb_kill_urb(port_priv->write_urb);
		}
		if (serial->num_bulk_in) {
			port->read_urb->transfer_flags &= ~USB_ASYNC_UNLINK;
			usb_kill_urb(port->read_urb);
		}
	}

	kfree(usb_get_serial_port_data(port));
	usb_set_serial_port_data(port, NULL);
}

static void cp210x_cleanup_port(struct usb_serial_port *port)
{
	struct usb_serial *serial = port->serial;

	struct cp210x_port_private	*port_priv;

	port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d", __func__, port->number);

	if (serial != NULL && serial->dev) {
		/* shutdown any bulk reads that might be going on */
		if (serial->num_bulk_out) {
			usb_kill_urb(port->write_urb);
			if (port_priv->write_urb)
				usb_kill_urb(port_priv->write_urb);
		}
		if (serial->num_bulk_in) {
			port->read_urb->transfer_flags &= ~USB_ASYNC_UNLINK;
			usb_kill_urb(port->read_urb);
		}
	}
}

void silabs_cp210x_close(struct tty_struct *tty,
			struct usb_serial_port *port, struct file *filp)
{
	struct usb_serial			*serial;
	struct cp210x_serial_private		*serial_priv;
	struct cp210x_port_private		*port_priv;
	unsigned int c_cflag;
	unsigned long flags;
	unsigned int modem_ctl[4];

	serial = port->serial;
	if (!serial)
		return;

	serial_priv = usb_get_serial_data(serial);
	port_priv = usb_get_serial_port_data(port);

	if (serial_priv == NULL)
		return;

	if (port_priv == NULL)
		return;

	dbg("%s - port %d", __func__, port->number);

	port_priv->run_cp210x_control_thread = FALSE;
	kthread_stop(port_priv->cp210x_task);

	if (serial->dev) {
		if (get_tty_port(port)) {
			c_cflag = get_tty_port(port)->termios->c_cflag;
			if (c_cflag & HUPCL) {
				/* drop DTR and RTS */
				spin_lock_irqsave(&port_priv->portLock, flags);
				port_priv->line_control = 0;

				spin_unlock_irqrestore(&port_priv->portLock,
								flags);

				cp210x_get_config(port,
						SILABSER_GET_FLOW_REQUEST_CODE,
						modem_ctl,
						16);

				/* Turn everything off */
				modem_ctl[0] &= CtrlHandshake_Reserved_Mask;
				modem_ctl[1] &= FlowReplace_Reserved_Mask;

				cp210x_set_config(port,
						SILABSER_SET_FLOW_REQUEST_CODE,
						modem_ctl,
						16);
			}
		}

		/* shutdown our urbs */
		dbg("%s - shutting down urbs", __func__);
		cp210x_cleanup_port(port);

		port_priv->open = FALSE;
	}

	cp210x_stop_control_thread(port);

	cp210x_set_config_single(port,
				SILABSER_IFC_ENABLE_REQUEST_CODE,
				UART_DISABLE);

	usb_free_urb(port_priv->write_urb);
	port_priv->write_urb = 0;

	kfree(port_priv->circular_buf_txfifo.fifo);
}

/*
 * cp210x_get_termios
 * Reads the baud rate, data bits, parity, stop bits and flow control mode
 * from the device, corrects any unsupported values, and configures the
 * termios structure to reflect the state of the device
 */
static void cp210x_get_termios(struct usb_serial_port *port)
{
	unsigned int cflag, iflag, modem_ctl[4];
	int baud;
	int bits;

	unsigned long flags;

	struct cp210x_port_private		*port_priv;
	struct tty_struct *tty_port = get_tty_port(port) ;

	dbg("%s - port %d", __func__, port->number);

	port_priv = usb_get_serial_port_data(port);

	if ((!tty_port) || (!tty_port->termios)) {
		dbg("%s - no tty structures", __func__);
		return;
	}

	cflag = 0;
	iflag = 0;

	cp210x_get_config(port, SILABSER_GET_BAUDRATE, &baud, 4);

	dbg("%s - baud rate = %d", __func__, baud);
	switch (baud) {
	/*
	 * The baud rates which are commented out below
	 * appear to be supported by the device
	 * but are non-standard
	 */
	case 0:
		cflag |= B0;
		break;
	case 50:
		cflag |= B50;
		break;
	case 75:
		cflag |= B75;
		break;
	case 110:
		cflag |= B110;
		break;
	case 134:
		cflag |= B134;
		break;
	case 150:
		cflag |= B150;
		break;
	case 200:
		cflag |= B200;
		break;
	case 300:
		cflag |= B300;
		break;
	case 600:
		cflag |= B600;
		break;
	case 1200:
		cflag |= B1200;
		break;
	case 1800:
		cflag |= B1800;
		break;
	case 2400:
		cflag |= B2400;
		break;
	case 4800:
		cflag |= B4800;
		break;
	case 9600:
		cflag |= B9600;
		break;
	case 19200:
		cflag |= B19200;
		break;
	case 38400:
		cflag |= B38400;
		break;
	case 57600:
		cflag |= B57600;
		break;
	case 115200:
		cflag |= B115200;
		break;
	case 230400:
		cflag |= B230400;
		break;
	case 460800:
		cflag |= B460800;
		break;
	case 500000:
		cflag |= B500000;
		break;
	case 576000:
		cflag |= B500000;
		break;
	case 921600:
		cflag |= B921600;
		break;
	case 1000000:
		cflag |= B1000000;
		break;
	/*
	 * case 1500000:
		cflag |= B1500000;
		break;
	 * case 2000000:
		cflag |= B2000000;
		break;
	 * case 2500000:
		cflag |= B2500000;
		break;
	 * case 3000000:
		cflag |= B3000000;
		break;
	 * case 3500000:
		cflag |= B3500000;
		break;
	 * case 4000000:
		cflag |= B4000000;
		break;
	*/
	default:
		dbg("%s - Baud rate is not supported, "
				"using 9600 baud", __func__);
		cflag |= B9600;
		baud = 9600;
		cp210x_set_config(port, SILABSER_SET_BAUDRATE, &baud, 4);

		break;
	}

	cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE, &bits, 2);
	switch (bits & BITS_DATA_MASK) {
	case BITS_DATA_5:
		dbg("%s - data bits = 5", __func__);
		cflag |= CS5;

		break;
	case BITS_DATA_6:
		dbg("%s - data bits = 6", __func__);
		cflag |= CS6;

		break;
	case BITS_DATA_7:
		dbg("%s - data bits = 7", __func__);
		cflag |= CS7;

		break;
	case BITS_DATA_8:
		dbg("%s - data bits = 8", __func__);
		cflag |= CS8;

		break;
	case BITS_DATA_9:
		dbg("%s - data bits = 9 (not supported, "
				"using 8 data bits)", __func__);
		cflag |= CS8;
		bits &= ~BITS_DATA_MASK;
		bits |= BITS_DATA_8;
		cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits);

		break;
	default:
		dbg("%s - Unknown number of data bits, "
				"using 8", __func__);
		cflag |= CS8;
		bits &= ~BITS_DATA_MASK;
		bits |= BITS_DATA_8;
		cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits);

		break;
	}

	switch (bits & BITS_PARITY_MASK) {
	case BITS_PARITY_NONE:
		dbg("%s - parity = NONE", __func__);
		cflag &= ~PARENB;
		break;
	case BITS_PARITY_ODD:
		dbg("%s - parity = ODD", __func__);
		cflag |= (PARENB|PARODD);
		break;
	case BITS_PARITY_EVEN:
		dbg("%s - parity = EVEN", __func__);
		cflag &= ~PARODD;
		cflag |= PARENB;
		break;
	case BITS_PARITY_MARK:
		dbg("%s - parity = MARK (not supported, "
				"disabling parity)", __func__);
		cflag &= ~PARENB;
		bits &= ~BITS_PARITY_MASK;
		cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits);

		break;
	case BITS_PARITY_SPACE:
		dbg("%s - parity = SPACE (not supported, "
				"disabling parity)", __func__);
		cflag &= ~PARENB;
		bits &= ~BITS_PARITY_MASK;
		cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits);

		break;
	default:
		dbg("%s - Unknown parity mode, "
				"disabling parity", __func__);
		cflag &= ~PARENB;
		bits &= ~BITS_PARITY_MASK;
		cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits);

		break;
	}

	switch (bits & BITS_STOP_MASK) {
	case BITS_STOP_1:
		dbg("%s - stop bits = 1", __func__);
		break;
	case BITS_STOP_1_5:
		dbg("%s - stop bits = 1.5 (not supported, "
				"using 1 stop bit)", __func__);
		bits &= ~BITS_STOP_MASK;
		cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits);

		break;
	case BITS_STOP_2:
		dbg("%s - stop bits = 2", __func__);
		cflag |= CSTOPB;
		break;
	default:
		dbg("%s - Unknown number of stop bits, "
				"using 1 stop bit", __func__);
		bits &= ~BITS_STOP_MASK;
		cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits);

		break;
	}

	cp210x_get_config(port, SILABSER_GET_FLOW_REQUEST_CODE, modem_ctl, 16);

	if (modem_ctl[0] & CtrlHandshake_CTS_Handshake_Mask) {
		dbg("%s - flow control = CRTSCTS", __func__);
		cflag |= CRTSCTS;
	} else if ((modem_ctl[1] & FlowReplace_Auto_Transmit_Mask) ||
				modem_ctl[1] &
				FlowReplace_Auto_Receive_Mask) {

		dbg("%s - flow control = XONXOFF", __func__);

		if (modem_ctl[1] & FlowReplace_Auto_Transmit_Mask)
			iflag |= IXOFF;

		if (modem_ctl[1] & FlowReplace_Auto_Receive_Mask)
			iflag |= IXON;

	} else {
		dbg("%s - flow control = NONE", __func__);
		cflag &= ~CRTSCTS;
		iflag = ~(IXOFF | IXON);
	}

	spin_lock_irqsave(&port_priv->portLock, flags);
	if (port_priv->termios_initialized == FALSE) {
		port_priv->orig_termios.c_iflag = iflag;
		port_priv->orig_termios.c_oflag = tty_port->termios->c_oflag;
		port_priv->orig_termios.c_cflag = cflag;
		port_priv->orig_termios.c_lflag = tty_port->termios->c_lflag;
		port_priv->orig_termios.c_line = tty_port->termios->c_line;
	} else {
		port_priv->curr_termios.c_iflag = iflag;
		port_priv->curr_termios.c_oflag = tty_port->termios->c_oflag;
		port_priv->curr_termios.c_cflag = cflag;
		port_priv->curr_termios.c_lflag = tty_port->termios->c_lflag;
		port_priv->curr_termios.c_line = tty_port->termios->c_line;
	}
	spin_unlock_irqrestore(&port_priv->portLock, flags);

}

static void silabs_cp210x_set_termios(struct tty_struct *tty,
		struct usb_serial_port *port, struct ktermios *old_termios)

{
	int baud = 0;
	unsigned int cflag, old_cflag = 0, old_iflag = 0;
	unsigned int modem_ctl[4];
	unsigned int iflag;
	unsigned int bits;

	unsigned long flags;

	unsigned char vstop;
	unsigned char vstart;
	unsigned char set_chars[6];

	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d, initialized %d",
		__func__,
		port->number,
		port_priv->termios_initialized);

	if ((!get_tty_port(port)) || (!get_tty_port(port)->termios)) {
		dbg("%s - no tty structures", __func__);
		return;
	}

	cflag = get_tty_port(port)->termios->c_cflag;
	iflag = get_tty_port(port)->termios->c_iflag;

	/* Check that they really want us to change something */
	if (old_termios) {
		if ((cflag == old_termios->c_cflag) &&
		  (SILABS_RELEVANT_IFLAG(get_tty_port(port)->termios->c_iflag)
			== SILABS_RELEVANT_IFLAG(old_termios->c_iflag))) {
			dbg("%s - nothing to change...", __func__);
			return;
		}

		old_cflag = old_termios->c_cflag;
		old_iflag = old_termios->c_iflag;
	}

	spin_lock_irqsave(&port_priv->portLock, flags);
	if (port_priv->termios_initialized == FALSE) {
		old_cflag = ~cflag;
		old_iflag = ~iflag;
		port_priv->termios_initialized = TRUE;
	}
	spin_unlock_irqrestore(&port_priv->portLock, flags);

	/* If the baud rate is to be updated*/
	if ((cflag & CBAUD) != (old_cflag & CBAUD)) {
		switch (cflag & CBAUD) {
		/*
		 * The baud rates which are commented out below
		 * appear to be supported by the device
		 * but are non-standard
		 */
		case B0:
			baud = 0;
			break;
		case B50:
			baud = 50;
			break;
		case B75:
			baud = 75;
			break;
		case B110:
			baud = 110;
			break;
		case B134:
			baud = 134;
			break;
		case B150:
			baud = 150;
			break;
		case B200:
			baud = 200;
			break;
		case B300:
			baud = 300;
			break;
		case B600:
			baud = 600;
			break;
		case B1200:
			baud = 1200;
			break;
		case B1800:
			baud = 1800;
			break;
		case B2400:
			baud = 2400;
			break;
		case B4800:
			baud = 4800;
			break;
		case B9600:
			baud = 9600;
			break;
		case B19200:
			baud = 19200;
			break;
		case B38400:
			baud = 38400;
			break;
		case B57600:
			baud = 57600;
			break;
		case B115200:
			baud = 115200;
			break;
		case B230400:
			baud = 230400;
			break;
		case B460800:
			baud = 460800;
			break;
		case B921600:
			baud = 921600;
			break;
		case B1000000:
			baud = 1000000;
			break;
		/*
		 * case B1500000:
			baud = 1500000;
			break;
		 * case B2000000:
			baud = 2000000;
			break;
		 * case B2500000:
			baud = 2500000;
			break;
		 * case B3000000:
			baud = 3000000;
			break;
		 * case B4000000:
			baud = 4000000;
			break;
		 */
		default:
			dev_err(&port->dev, "silabs driver does not "
				"support the baudrate requested "
				"using 9600 baud\n");
			baud = 9600;
			break;
		}

		dbg("%s - Setting baud rate to %d baud", __func__, baud);
		if (cp210x_set_config(port, SILABSER_SET_BAUDRATE, &baud, 4))
			dev_err(&port->dev,
				"Baud rate requested not supported\n");
	}

	/* If the number of data bits is to be updated */
	if ((cflag & CSIZE) != (old_cflag & CSIZE)) {
		cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE,
				  &bits, 2);
		bits &= ~BITS_DATA_MASK;
		switch (cflag & CSIZE) {
		case CS5:
			bits |= BITS_DATA_5;
			dbg("%s - data bits = 5", __func__);
			break;
		case CS6:
			bits |= BITS_DATA_6;
			dbg("%s - data bits = 6", __func__);
			break;
		case CS7:
			bits |= BITS_DATA_7;
			dbg("%s - data bits = 7", __func__);
			break;
		case CS8:
			bits |= BITS_DATA_8;
			dbg("%s - data bits = 8", __func__);
			break;
		/*case CS9:
			bits |= BITS_DATA_9;
			dbg("%s - data bits = 9", __func__);
			break;*/
		default:
			dev_err(&port->dev, "silabs driver does not "
				"support the number of bits requested,"
				" using 8 bit mode\n");
			bits |= BITS_DATA_8;
			break;
		}

		if (cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits))

			dev_err(&port->dev,
			"Number of data bits requested not supported\n");
	}

	if ((cflag & (PARENB|PARODD)) != (old_cflag & (PARENB|PARODD))) {
		cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE,
				  &bits, 2);
		bits &= ~BITS_PARITY_MASK;
		if (cflag & PARENB) {
			if (cflag & PARODD) {
				bits |= BITS_PARITY_ODD;
				dbg("%s - parity = ODD", __func__);
			} else {
				bits |= BITS_PARITY_EVEN;
				dbg("%s - parity = EVEN", __func__);
			}
		}

		dbg("%s - Setting parity to %d parity", __func__, bits);
		if (cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits))

			dev_err(&port->dev,
				"Parity mode not supported by device\n");
	}

	if ((cflag & CSTOPB) != (old_cflag & CSTOPB)) {
		cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE,
				  &bits, 2);
		bits &= ~BITS_STOP_MASK;
		if (cflag & CSTOPB) {
			bits |= BITS_STOP_2;
			dbg("%s - stop bits = 2", __func__);
		} else {
			bits |= BITS_STOP_1;
			dbg("%s - stop bits = 1", __func__);
		}

		dbg("%s - Setting stop bits to %d stop bits", __func__, bits);
		if (cp210x_set_config_single(port,
					SILABSER_SET_LINE_CTL_REQUEST_CODE,
					bits))
			dev_err(&port->dev,
			"Number of stop bits requested not supported\n");
	}

	if (((cflag & CRTSCTS) != (old_cflag & CRTSCTS)) ||
		((iflag & IXOFF) != (old_iflag & IXOFF)) ||
		((iflag & IXON) != (old_iflag & IXON))) {

		/*
		 * Flow Control has changed
		*/
		cp210x_get_config(port, SILABSER_GET_FLOW_REQUEST_CODE,
				  modem_ctl, 16);
		dbg("%s - read modem controls = 0x%.4x 0x%.4x 0x%.4x 0x%.4x",
				__func__, modem_ctl[0], modem_ctl[1],
				modem_ctl[2], modem_ctl[3]);

		modem_ctl[0] &= CtrlHandshake_Reserved_Mask;
		modem_ctl[1] &= (FlowReplace_Reserved_Mask |
					FlowReplace_Error_Char_Mask |
					FlowReplace_Break_Char_Mask);

		if (cflag & CRTSCTS) {
			modem_ctl[0] |= (CtrlHandshake_CTS_Handshake_Mask |
						CtrlHandshake_DTR_Active);

			modem_ctl[1] |= FlowReplace_RTS_Receive_Flow;

			dbg("%s - flow control = CRTSCTS", __func__);

		} else if ((iflag & IXOFF) || (iflag & IXON)) {
			vstart = get_tty_port(port)->termios->c_cc[VSTART];
			vstop = get_tty_port(port)->termios->c_cc[VSTOP];

			cp210x_get_config_bytes(port,
						SILABSER_GET_CHARS_REQUEST_CODE,
						set_chars,
						6);

			set_chars[4] = vstart;
			set_chars[5] = vstop;

			cp210x_set_config(port,
					SILABSER_SET_CHARS_REQUEST_CODE,
					(uint *) set_chars,
					6);

			if (iflag & IXOFF)
				modem_ctl[1] |= FlowReplace_Auto_Transmit_Mask;

			if (iflag & IXON)
				modem_ctl[1] |= FlowReplace_Auto_Receive_Mask;

			dbg("%s - flow control = XONXOFF", __func__);

		} else {
			modem_ctl[0] |= CtrlHandshake_DTR_Active;
			modem_ctl[1] |= FlowReplace_RTS_Statically_Active;
			dbg("%s - flow control = NONE", __func__);
		}

		dbg("%s - write modem controls = 0x%.4x 0x%.4x 0x%.4x 0x%.4x",
				__func__, modem_ctl[0], modem_ctl[1],
				modem_ctl[2], modem_ctl[3]);
		cp210x_set_config(port,
				SILABSER_SET_FLOW_REQUEST_CODE,
				modem_ctl,
				16);

	}

	/* Save off the new port termios */
	cp210x_get_termios(port);

}

static int silabs_cp210x_tiocmset(struct tty_struct *tty, struct file *file,
				unsigned int set, unsigned int clear)
{
	unsigned long flags;
	struct usb_serial_port *port = tty->driver_data;
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	unsigned int mcr;
	unsigned int line_control;

	dbg("%s - port %d", __func__, port->number);

	spin_lock_irqsave(&port_priv->portLock, flags);

	mcr = port_priv->mcr;
	line_control = port_priv->line_control;

	if (set & TIOCM_RTS) {
		line_control |= MCR_RTS;
		line_control |= CONTROL_WRITE_RTS;
		mcr |= MCR_RTS;
	}
	if (set & TIOCM_DTR) {
		line_control |= MCR_DTR;
		line_control |= CONTROL_WRITE_DTR;
		mcr |= MCR_DTR;
	}
	if (clear & TIOCM_RTS) {
		line_control &= ~MCR_RTS;
		line_control |= CONTROL_WRITE_RTS;
		mcr &= ~MCR_RTS;
	}
	if (clear & TIOCM_DTR) {
		line_control &= ~MCR_DTR;
		line_control |= CONTROL_WRITE_DTR;
		mcr &= ~MCR_DTR;
	}

	port_priv->mcr = mcr;
	port_priv->line_control = line_control;

	spin_unlock_irqrestore(&port_priv->portLock, flags);

	dbg("%s - control = 0x%.4x", __func__, line_control);

	/* set the new MCR value in the device */
	return cp210x_set_config_single(port,
					SILABSER_SET_MHS_REQUEST_CODE,
					line_control);

	return 0;
}

static int silabs_cp210x_tiocmget(struct tty_struct *tty, struct file *file)
{
	unsigned long flags;
	struct usb_serial_port *port = tty->driver_data;
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	unsigned int msr;
	unsigned int mcr;
	unsigned int line_control;

	int result = 0;

	dbg("%s - port %d", __func__, port->number);

	cp210x_get_config(port, SILABSER_GET_MDMSTS_REQUEST_CODE,
			  &line_control, 1);

	mcr = line_control & MCR_ALL;
	msr = line_control & MSR_ALL;

	result = ((mcr & MCR_DTR) ? TIOCM_DTR : 0)
		|((mcr & MCR_RTS) ? TIOCM_RTS : 0)
		|((msr & MSR_CTS) ? TIOCM_CTS : 0)
		|((msr & MSR_DSR) ? TIOCM_DSR : 0)
		|((msr & MSR_RING) ? TIOCM_RI  : 0)
		|((msr & MSR_DCD) ? TIOCM_CD  : 0);

	spin_lock_irqsave(&port_priv->portLock, flags);

	port_priv->mcr = mcr;
	port_priv->mcr = msr;
	port_priv->line_control = line_control;

	spin_unlock_irqrestore(&port_priv->portLock, flags);

	dbg("%s - control = 0x%.2x", __func__, line_control);

	return result;
}

static void silabs_cp210x_break_ctl(struct tty_struct *tty, int break_state)
{
	int state;
	struct usb_serial_port *port = tty->driver_data;
	dbg("%s - port %d", __func__, port->number);

	if (break_state == -1)
		state = BREAK_ON;
	else
		state = BREAK_OFF;

	dbg("%s - turning break %s", __func__,
		state == BREAK_OFF ? "off" : "on");

	cp210x_set_config_single(port, SILABSER_SET_BREAK_REQUEST_CODE, state);
}

/*
 * cp2101_ctlmsg
 * A generic usb control message interface.
 * Returns the actual size of the data read or written within the message, 0
 * if no data were read or written, or a negative value to indicate an error.
 */
static int cp2101_ctlmsg(struct usb_serial_port *port, u8 request,
		u8 requestype, u16 value, u16 index, void *data, u16 size)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	struct usb_device *dev = port->serial->dev;
	u8 *tbuf;
	int ret;

	mutex_lock(&port_priv->controlPipeMutex);
	tbuf = kmalloc(size, GFP_KERNEL);
	if (!tbuf) {
		mutex_unlock(&port_priv->controlPipeMutex);
		return -ENOMEM;
	}

	if (requestype & 0x80) {
		ret = usb_control_msg(dev, usb_rcvctrlpipe(dev, 0), request,
			requestype, value, port_priv->bInterfaceNumber,
			tbuf, size, 300);

		if (ret > 0 && size)
			memcpy(data, tbuf, size);
	} else {
		if (size)
			memcpy(tbuf, data, size);

		ret = usb_control_msg(dev, usb_sndctrlpipe(dev, 0), request,
			requestype, value, port_priv->bInterfaceNumber,
			tbuf, size, 300);
	}
	kfree(tbuf);

	if (ret < 0 && ret != -EPIPE) {
		dev_printk(KERN_DEBUG,
				&dev->dev,
				"cp2101: control failed cmd rqt %u "
				"rq %u len %u ret %d\n",
				requestype,
				request,
				size,
				ret);
	}
	mutex_unlock(&port_priv->controlPipeMutex);
	return ret;
}

static int cp210x_get_partnum(struct usb_serial_port *port)
{
	int ret = -1;

	u8 addr;

	struct usb_serial *serial = port->serial;
	struct cp210x_serial_private *serial_priv =
			usb_get_serial_data(serial);

	serial_priv->devType = none;
	serial_priv->numberOfPorts = silabs_cp210x_calc_num_ports(serial) ;
	if (2 == serial_priv->numberOfPorts) {
		serial_priv->devType = cp2105;
	} else {
		addr = port->bulk_out_endpointAddress &
			USB_ENDPOINT_NUMBER_MASK;

		if (addr == 0x03 || addr == 0x02) {
			serial_priv->devType = cp2101;
			ret = 0;
		} else if (addr == 0x01) {

			ret = cp2101_ctlmsg(port,
						0xff,
						0xc0,
						0x370b,
						0x00,
						&addr,
						1);

			if (ret == 1) {
				if (addr == 2) {
					ret = 0;
					serial_priv->devType = cp2102;
				} else {
					ret = 0;
					serial_priv->devType = cp2103;
				}
			}
		}
	}

	return ret;
};

static int cp210x_gpioget(struct usb_serial_port *port, u8* gpio)
{
	int ret;

	dbg("%s - port %d", __func__, port->number);

	/* FIXME: how about REQTYPE_DEVICE_TO_HOST instead of 0xc0? */
	ret = cp2101_ctlmsg(port, 0xff, 0xc0, 0x00c2, 0, gpio, 1);

	dbg("%s - gpio = 0x%.2x (%d)", __func__, *gpio, ret);

	return (ret == 1) ? 0 : -1;
}

/* Set all gpio simultaneously */
static int cp210x_gpioset(struct usb_serial_port *port, uint16_t arg)
{
	dbg("%s - port %d, gpio = 0x%.2x", __func__, port->number, arg);
    return cp2101_ctlmsg(port, 0xff, 0x40, 0x37e1, arg, 0, 0);
}

static int cp210x_get_serialstat(struct usb_serial_port *port)
{
	int results = SILABS_SUCCESS;
	unsigned char		buffer[19];
	unsigned long flags;

	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	results = cp210x_get_config_bytes(port,
					SILABSER_GET_COMM_STATUS_REQUEST_CODE,
					buffer,
					19);
	if (results == -EPROTO)
		return -EPROTO;

	if (results) {
		port_priv->serialstat.ulErrors =
			le32_to_cpu(buffer[0] |
				(buffer[1] << 8) |
				(buffer[2] << 16) |
				(buffer[3] << 24));

		port_priv->serialstat.ulHoldReasons =
			le32_to_cpu(buffer[4] |
				(buffer[5] << 8) |
				(buffer[6] << 16) |
				(buffer[7] << 24));

		port_priv->serialstat.ulAmountIn_InQueue =
			le32_to_cpu(buffer[8] |
				(buffer[9] << 8) |
				(buffer[10] << 16) |
				(buffer[11] << 24));

		port_priv->serialstat.ulAmountIn_OutQueue =
			le32_to_cpu(buffer[12] |
				(buffer[13] << 8) |
				(buffer[14] << 16) |
				(buffer[15] << 24));

		port_priv->serialstat.bEofReceived = buffer[16];
		port_priv->serialstat.bWaitForImmediate = buffer[17];
	}

	spin_lock_irqsave(&port_priv->portLock, flags);

	if (port_priv->termios_initialized == FALSE) {
		if (!(port_priv->serialstat.ulErrors & 0x1F) &&
		    !(port_priv->serialstat.ulHoldReasons & 0x7F)) {
			port_priv->open = TRUE;
			port_priv->openPending = FALSE;
		} else {
			port_priv->open = FALSE;
			results = SILABS_FAIL;
		}
	}

	spin_unlock_irqrestore(&port_priv->portLock, flags);

	return results;
}

static int cp210x_get_commprops(struct usb_serial_port *port)
{
	int results = 0;
	unsigned char		buffer[256];

	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	results = cp210x_get_config_bytes(port,
					SILABSER_GET_PROPS_REQUEST_CODE,
					buffer,
					256);

	if (results) {
		port_priv->commprops.wLength =
			le16_to_cpu(buffer[0] | (buffer[1] << 8));
		port_priv->commprops.bcdVersion =
			le16_to_cpu(buffer[2] | (buffer[3] << 8));
		port_priv->commprops.ulSericeMask =
			le32_to_cpu(buffer[4] |
				(buffer[5] << 8) |
				(buffer[6] << 16) |
				(buffer[7] << 24));

		port_priv->commprops.ulReserved1 =
			le32_to_cpu(buffer[8] |
				(buffer[9] << 8) |
				(buffer[10] << 16) |
				(buffer[11] << 24));

		port_priv->commprops.ulMaxTxQueue =
			le32_to_cpu(buffer[12] |
				(buffer[13] << 8) |
				(buffer[14] << 16) |
				(buffer[15] << 24));

		port_priv->commprops.ulMaxRxQueue =
			le32_to_cpu(buffer[16] |
				(buffer[17] << 8) |
				(buffer[18] << 16) |
				(buffer[19] << 24));

		port_priv->commprops.ulMaxBaud =
			le32_to_cpu(buffer[20] |
				(buffer[21] << 8) |
				(buffer[22] << 16) |
				(buffer[23] << 24));

		port_priv->commprops.ulProvSubType =
			le32_to_cpu(buffer[24] |
				(buffer[25] << 8) |
				(buffer[26] << 16) |
				(buffer[27] << 24));

		port_priv->commprops.ulProvCapabilities =
			le32_to_cpu(buffer[28] |
				(buffer[29] << 8) |
				(buffer[30] << 16) |
				(buffer[31] << 24));

		port_priv->commprops.ulSettableParams =
			le32_to_cpu(buffer[32] |
				(buffer[33] << 8) |
				(buffer[34] << 16) |
				(buffer[35] << 24));

		port_priv->commprops.ulSettableBaud =
			le32_to_cpu(buffer[36] |
				(buffer[37] << 8) |
				(buffer[38] << 16) |
				(buffer[39] << 24));

		port_priv->commprops.wSettableData =
			le16_to_cpu(buffer[40] |
				(buffer[41] << 8));

		port_priv->commprops.wSettableStopParity =
			le16_to_cpu(buffer[42] |
				(buffer[43] << 8));

		port_priv->commprops.ulCurrentTxQueue =
			le32_to_cpu(buffer[44] |
				(buffer[45] << 8) |
				(buffer[46] << 16) |
				(buffer[47] << 24));

		port_priv->commprops.ulCurrentRxQueue =
			le32_to_cpu(buffer[48] |
				(buffer[49] << 8) |
				(buffer[50] << 16) |
				(buffer[51] << 24));

		port_priv->commprops.ulProvSpec1 =
			le32_to_cpu(buffer[52] |
				(buffer[53] << 8) |
				(buffer[54] << 16) |
				(buffer[55] << 24));

		port_priv->commprops.ulProvSpec2 =
			le32_to_cpu(buffer[56] |
				(buffer[57] << 8) |
				(buffer[58] << 16) |
				(buffer[59] << 24));

		port_priv->commprops.uniProvName = NULL;
	}

	return results;
}

static int cp210x_internal_ioctl(struct usb_serial_port *port,
					struct file *file,
					unsigned int cmd,
					unsigned long arg)
{
	__u8			gpio = 0;
	int			results = 0;
	unsigned int		data = 0;
	unsigned char		buffer[256];
	unsigned int		modem_ctl[4];
	unsigned char		set_chars[6];

	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	struct CommFlow		cp2101_commflow;

	struct usb_serial *serial = port->serial;
	struct cp210x_serial_private *serial_priv =
					usb_get_serial_data(serial);

	dbg("%s %d cmd = 0x%04x", __func__, port->number, cmd);

	switch (cmd) {

	case IOCTL_EMBED_EVENTS:
		{
			if (copy_from_user(&data,
					(void __user *)arg,
					sizeof(unsigned int)))

				return -EFAULT;

			cp210x_set_config_single(port,
					SILABSER_EMBED_EVENTS_REQUEST_CODE,
					data);
			return 0;
		}
		break;

	case IOCTL_GPIOGET:
		{
			if (serial_priv->devType >= cp2103) {
				if (!cp210x_gpioget(port, &gpio)) {
					if (copy_to_user((void __user *)arg,
							&gpio,
							sizeof(__u8)))

						return -EFAULT;
				} else
					return -EFAULT;

				return 0;
			} else
				return -ENOIOCTLCMD;
		}
		break;

	case IOCTL_GPIOSET:
		{
			if (serial_priv->devType >= cp2103) {

				if (cp210x_gpioset(port, (uint16_t) arg))
					return -EFAULT;

				return 0;
			} else
				return -ENOIOCTLCMD;
		}
		break;

	case IOCTL_PROPGET:
		{
			if (copy_to_user((void __user *)arg,
					&port_priv->commprops,
					sizeof(struct CommProps)))
				return -EFAULT;

			return 0;
		}
		break;

	case IOCTL_PROPGETLENGTH:
		{
			results = cp210x_get_config_bytes(port,
					SILABSER_GET_PROPS_REQUEST_CODE,
					buffer,
					256);

			if (!results)
				return -EFAULT;

			if (copy_to_user((void __user *)arg,
					&results,
					sizeof(int)))
				return -EFAULT;

			return 0;
		}
		break;

	case IOCTL_FLOW_CONTROLGET:
		{
			cp210x_get_config(port,
					SILABSER_GET_FLOW_REQUEST_CODE,
					modem_ctl,
					16);

			if (copy_to_user((void __user *)arg,
					modem_ctl,
					4 * sizeof(int)))
				return -EFAULT;

			return 0;
		}
		break;

	case IOCTL_FLOW_CONTROLSET:
		{
			if (copy_from_user(&cp2101_commflow,
						(void __user *)arg,
						sizeof(struct CommFlow)))
					return -EFAULT;

			cp210x_get_config(port,
					SILABSER_GET_FLOW_REQUEST_CODE,
					modem_ctl,
					16);

			modem_ctl[0] &= ~4;
			modem_ctl[0] |= cp2101_commflow.controlHandshake;

			modem_ctl[1] &= ~0x7FFFFF20;
			modem_ctl[1] |= cp2101_commflow.flowReplace;

			modem_ctl[2] = cp2101_commflow.ulXonLimit;

			modem_ctl[3] = cp2101_commflow.ulXoffLimit;

			cp210x_set_config(port,
					SILABSER_SET_FLOW_REQUEST_CODE,
					modem_ctl,
					16);

			return 0;
		}
		break;

	case IOCTL_SPECIAL_CHARGET:
		{
			cp210x_get_config_bytes(port,
						SILABSER_GET_CHARS_REQUEST_CODE,
						set_chars,
						6);

			if (copy_to_user((void __user *)arg,
					set_chars,
					6 * sizeof(unsigned char)))
				return -EFAULT;

			return 0;
		}
		break;

	case IOCTL_SPECIAL_CHARSET:
		{
			if (copy_from_user(set_chars,
						(void __user *)arg,
						6 * sizeof(unsigned char)))
					return -EFAULT;

			cp210x_set_config(port,
					SILABSER_SET_CHARS_REQUEST_CODE,
					(uint *)set_chars,
					6);

			return 0;
		}
		break;

	case IOCTL_XOFFSET:
		{
			cp210x_set_config_single(port,
					 SILABSER_SET_XOFF_REQUEST_CODE,
					 0);
			return 0;
		}
		break;

	case IOCTL_XONSET:
		{
			cp210x_set_config_single(port,
					SILABSER_SET_XON_REQUEST_CODE,
					0);
			return 0;
		}
		break;

	default:
		dbg("%s not supported = 0x%04x", __func__, cmd);
		break;
	}

	return -ENOIOCTLCMD;
}

static int silabs_cp210x_ioctl(struct tty_struct *tty, struct file *file,
				unsigned int cmd, unsigned long arg)

{
	DEFINE_WAIT(wait);

	int val = 0;
	struct usb_serial_port *port = tty->driver_data;
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);
	struct async_icount		cnow;
	struct async_icount		cprev;

	dbg("%s %d cmd = 0x%04x", __func__, port->number, cmd);

	switch (cmd) {
	case TIOCMGET:
		{
		int result = silabs_cp210x_tiocmget(tty, file);
		if (copy_to_user((void __user *)arg, &result, sizeof(int)))
			return -EFAULT;
		return 0;
		}
		break;

	case TIOCMBIS:
	case TIOCMBIC:
		val |= (TIOCM_RTS | TIOCM_DTR);
	case TIOCMSET:
		{
		if (!val) {
			if (copy_from_user(&val,
					(void __user *)arg,
					sizeof(int)))
				return -EFAULT;
		}

		if (silabs_cp210x_tiocmset(tty,
					file,
					cmd == TIOCMBIC ? 0 : val,
						cmd == TIOCMBIC ? val : 0))

			return -EFAULT;
		return 0;
		}
		break;

	case TIOCMIWAIT:
		dbg("%s %d TIOCMIWAIT", __func__,  port->number);
		cprev = port_priv->icount;
		while (1) {
			prepare_to_wait(&port_priv->delta_msr_wait,
					&wait, TASK_INTERRUPTIBLE);
			schedule();
			finish_wait(&port_priv->delta_msr_wait, &wait);
			/* see if a signal did it */
			if (signal_pending(current))
				return -ERESTARTSYS;
			cnow = port_priv->icount;
			if (cnow.rng == cprev.rng && cnow.dsr == cprev.dsr &&
			    cnow.dcd == cprev.dcd && cnow.cts == cprev.cts)
				return -EIO; /* no change => error */
			if (((arg & TIOCM_RNG) && (cnow.rng != cprev.rng)) ||
			    ((arg & TIOCM_DSR) && (cnow.dsr != cprev.dsr)) ||
			    ((arg & TIOCM_CD)  && (cnow.dcd != cprev.dcd)) ||
			    ((arg & TIOCM_CTS) && (cnow.cts != cprev.cts))) {
				return 0;
			}
			cprev = cnow;
		}
		/* NOTREACHED */
		break;

	case TCFLSH:
		{
		unsigned char flush_value = 0;

		if (arg == 0) {
			/* flush read */
			flush_value = 0x0a;
		} else if (arg == 1) {
			/* flush write */
			flush_value = 0x05;
			port_priv->circular_buf_txfifo.head = 0;
			port_priv->circular_buf_txfifo.tail = 0;
			port_priv->circular_buf_txfifo.count = 0;
		} else if (arg == 2) {
			/* flush read and write */
			flush_value = 0x0f;
			port_priv->circular_buf_txfifo.head = 0;
			port_priv->circular_buf_txfifo.tail = 0;
			port_priv->circular_buf_txfifo.count = 0;
		} else {
			return -EINVAL;
		}

		cp210x_set_config_single(port,
				 SILABSER_PURGE_REQUEST_CODE,
				 flush_value);
		return 0;
		}
		break;
	default:
		{
		return cp210x_internal_ioctl(port, file, cmd, arg);
		}
		break;
	}

	return -ENOIOCTLCMD;
}

static int silabs_cp210x_resume(struct usb_serial *serial)
{
	struct usb_serial_port *port;
	int i, c = 0, r;

	for (i = 0; i < serial->num_ports; i++) {
		port = serial->port[i];
		if (port->port.count && port->read_urb) {
			r = usb_submit_urb(port->read_urb, GFP_NOIO);
			if (r < 0)
				c++;
		}
	}

	return c ? -EIO : 0;
}

static int silabs_cp210x_suspend(struct usb_serial *serial,
						pm_message_t message)
{
	struct usb_serial_port *port;
	int i ;

	for (i = 0; i < serial->num_ports; i++) {
		port = serial->port[i];
		if (port->port.count && port->write_urb)
			usb_kill_urb(port->write_urb);
	}

	return 0 ;
}

/************************************************************************
 *
 * cp210x_send_port_data()
 *
 *	This routine attempts to write additional UART transmit data
 *	to a port over the USB bulk pipe. It is called (1) when new
 *	data has been written to a port's TxBuffer from higher layers
 *	(2) when the peripheral sends us additional TxCredits indicating
 *	that it can accept more	Tx data for a given port; and (3) when
 *	a bulk write completes successfully and we want to see if we
 *	can transmit more.
 *
 ************************************************************************/
static void cp210x_send_port_data(struct usb_serial_port *port)
{
	struct usb_serial *serial = port->serial;
	struct cp210x_serial_private *serial_priv =
			usb_get_serial_data(serial);
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);
	struct circular_buf_txfifo *fifo = &port_priv->circular_buf_txfifo;
	struct urb			*urb;
	unsigned char			*buffer;

	int		status;
	int		count;
	int		bytesleft;
	int		firsthalf;
	int		secondhalf;

	unsigned long	flags;

	dbg("%s(%d)", __func__, port_priv->port->number);

	spin_lock_irqsave(&port_priv->portLock, flags);

	if (port_priv->write_busy ||
	    !port_priv->open ||
	    (fifo->count == 0)) {
		dbg("%s(%d) EXIT - fifo %d, PendingWrite = %d",
			__func__,
			port_priv->port->number,
			fifo->count,
			port_priv->write_busy);

		goto exit_send;
	}

	if (port_priv->txCredits <
		(port_priv->commprops.ulCurrentTxQueue / 4)) {
		dbg("%s(%d) Not enough credit - fifo %d TxCredit %d",
			__func__,
			port_priv->port->number,
			fifo->count,
			port_priv->txCredits);

		goto exit_send;
	}

	/* lock this write */
	port_priv->write_busy = TRUE;

	/* get a pointer to the write_urb */
	urb = port_priv->write_urb;

	/* if this urb had a transfer buffer already (old transfer) free it */
	if (urb->transfer_buffer != NULL) {
		kfree(urb->transfer_buffer);
		urb->transfer_buffer = NULL;
	}

	/*
	 * build the data header for the buffer and
	 * port that we are about to send out
	 */
	count = fifo->count;
	buffer = kmalloc(count, GFP_ATOMIC);
	if (buffer == NULL) {
		dev_err(&port->dev,
			"%s - no more kernel memory on port %d\n",
			__func__,
			port->number);

		port_priv->write_busy = FALSE;
		goto exit_send;
	}

	/* now copy our data */
	bytesleft =  fifo->size - fifo->tail;
	firsthalf = min(bytesleft, count);
	memcpy(buffer, &fifo->fifo[fifo->tail], firsthalf);
	fifo->tail  += firsthalf;
	fifo->count -= firsthalf;
	if (fifo->tail == fifo->size)
		fifo->tail = 0;

	secondhalf = count-firsthalf;
	if (secondhalf) {
		memcpy(&buffer[firsthalf], &fifo->fifo[fifo->tail], secondhalf);
		fifo->tail  += secondhalf;
		fifo->count -= secondhalf;
	}

	if (count)
		usb_serial_debug_data(debug, &port->dev,
					__func__, count, buffer);

	/* fill up the urb with all of our data and submit it */
	usb_fill_bulk_urb(urb,
				serial_priv->serial->dev,
				usb_sndbulkpipe(serial_priv->serial->dev,
					port->bulk_out_endpointAddress),
				buffer,
				count,
				silabs_cp210x_write_bulk_callback,
				port);

	urb->dev = serial_priv->serial->dev;
	/* decrement the number of credits we have by the number we just sent */
	port_priv->txCredits -= count;
	port_priv->icount.tx += count;

	status = usb_submit_urb(urb, GFP_KERNEL);

	if (status) {
		/* something went wrong */
		dev_err(&port->dev,
			"%s - Send Port Data - Sending URB FAILE\n",
			__func__);

		dbg("%s - usb_submit_urb(write bulk) failed", __func__);
		port_priv->write_busy = FALSE;

		/*revert the count if something bad happened...*/
		port_priv->txCredits += count;
		port_priv->icount.tx -= count;
	}

	dbg("%s wrote %d byte(s) TxCredit %d, Fifo %d",
		__func__,
		count,
		port_priv->txCredits,
		fifo->count);

exit_send:
	spin_unlock_irqrestore(&port_priv->portLock, flags);
}

int silabs_cp210x_write(struct usb_serial_port *port,
			int from_user,
			const unsigned char *buf,
			int count)
{
	struct usb_serial		*serial = port->serial;

	struct cp210x_serial_private *serial_priv =
				usb_get_serial_data(serial);

	struct cp210x_port_private *port_priv =
				usb_get_serial_port_data(port);

	struct circular_buf_txfifo *fifo;
	int copySize;
	int bytesleft;
	int firsthalf;
	int secondhalf;

	unsigned long flags;

	dbg("%s - port %d", __func__, port->number);

	if (port_priv == NULL)
		return -ENODEV;

	if (serial_priv == NULL)
		return -ENODEV;

	spin_lock_irqsave(&port_priv->portLock, flags);

	/* get a pointer to the Tx fifo */
	fifo = &port_priv->circular_buf_txfifo;

	/* calculate number of bytes to put in fifo */
	copySize = min((unsigned int)count,
			(port_priv->txCredits - fifo->count));

	dbg("%s(%d) of %d byte(s) Fifo room  %d -- will copy %d bytes",
		__func__, port->number, count,
		port_priv->txCredits - fifo->count, copySize);

	/* catch writes of 0 bytes which the tty driver likes to give us,
	 * and when txCredits is empty
	 */
	if (copySize == 0) {
		dbg("%s - copySize = Zero", __func__);
		goto finish_write;
	}

	/* queue the data, since we can never overflow the buffer
	 * we do not have to check for full condition
	 *
	 * the copy is done is two parts - first fill to the end of the buffer
	 * then copy the reset from the start of the buffer
	 */
	bytesleft = fifo->size - fifo->head;
	firsthalf = min(bytesleft, copySize);
	dbg("%s - copy %d bytes of %d into fifo ",
		__func__, firsthalf, bytesleft);

	/* now copy our data */
	if (from_user) {
		if (copy_from_user(&fifo->fifo[fifo->head], buf, firsthalf)) {
			copySize = -EFAULT;
			goto finish_write;
		}
	} else {
		memcpy(&fifo->fifo[fifo->head], buf, firsthalf);
	}

	/* update the index and size */
	fifo->head  += firsthalf;
	fifo->count += firsthalf;

	/* wrap the index */
	if (fifo->head == fifo->size)
		fifo->head = 0;

	secondhalf = copySize-firsthalf;

	if (secondhalf) {
		dbg("%s - copy rest of data %d", __func__, secondhalf);
		if (from_user) {
			if (copy_from_user(&fifo->fifo[fifo->head],
						&buf[firsthalf],
						secondhalf)) {

				copySize = -EFAULT;
				goto finish_write;
			}
		} else {
			memcpy(&fifo->fifo[fifo->head],
				&buf[firsthalf],
				secondhalf);
		}
		/* update the index and size */
		fifo->count += secondhalf;
		fifo->head  += secondhalf;
		/* No need to check for wrap since we can not
		 * get to end of fifo in this part
		 */
	}

	if (copySize)
		usb_serial_debug_data(debug, &port->dev,
					__func__, copySize, buf);

finish_write:
	spin_unlock_irqrestore(&port_priv->portLock, flags);

	cp210x_send_port_data(port);

	dbg("%s wrote %d byte(s) TxCredits %d, Fifo %d",
		__func__,
		copySize,
		port_priv->txCredits,
		fifo->count);

	return copySize;
}

int silabs_cp210x_write_wrapper(struct tty_struct *tty,
				struct usb_serial_port *port,
				const unsigned char *buf,
				int count)
{
	return silabs_cp210x_write(port, 0, buf, count);
}

int silabs_cp210x_chars_in_buffer(struct tty_struct *tty)
{
	struct usb_serial_port *port = tty->driver_data;
	struct usb_serial *serial = port->serial;
	int				chars = 0;

	unsigned long flags;

	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d", __func__, port->number);

	if (port_priv == NULL)
		return -ENODEV;

	if (port_priv->closePending == TRUE)
		return -ENODEV;

	if (!port_priv->open) {
		dbg("%s - port not opened", __func__);
		return -EINVAL;
	}

	if (serial->num_bulk_out) {
		spin_lock_irqsave(&port_priv->portLock, flags);

		chars = port_priv->maxTxCredits -
					port_priv->txCredits +
					port_priv->circular_buf_txfifo.count;

		spin_unlock_irqrestore(&port_priv->portLock, flags);
	}

	dbg("%s - returns %d", __func__, chars);
	return chars;
}

int silabs_cp210x_write_room(struct tty_struct *tty)
{
	struct usb_serial_port *port = tty->driver_data;
	struct usb_serial *serial = port->serial;
	int				room = 0;

	unsigned long flags;

	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d", __func__, port->number);

	if (port_priv == NULL)
		return -ENODEV;

	if (port_priv->closePending == TRUE)
		return -ENODEV;

	if (!port_priv->open) {
		dbg("%s - port not opened", __func__);
		return -EINVAL;
	}

	if (serial->num_bulk_out) {

		spin_lock_irqsave(&port_priv->portLock, flags);

		/* total of both buffers is still txCredit */
		room = port_priv->txCredits -
			port_priv->circular_buf_txfifo.count;

		spin_unlock_irqrestore(&port_priv->portLock, flags);
	}

	dbg("%s - returns %d", __func__, room);
	return room;
}

static void cp210x_resubmit_read_urb(struct usb_serial_port *port,
					gfp_t mem_flags)
{
	struct urb *urb = port->read_urb;
	struct usb_serial *serial = port->serial;
	int result;

	if (serial->dev == NULL)
		return;

	/* Continue reading from device */
	usb_fill_bulk_urb(urb, serial->dev,
			usb_rcvbulkpipe(serial->dev,
				port->bulk_in_endpointAddress),
			urb->transfer_buffer,
			urb->transfer_buffer_length,
			silabs_cp210x_read_bulk_callback,
			port);

	if (port->port.count) {
		result = usb_submit_urb(urb, mem_flags);

		if (result)
			dev_err(&port->dev,
				"%s - failed resubmitting read urb, error %d\n",
				__func__,
				result);
	}
}

/* Push data to tty layer and resubmit the bulk read URB */
static void cp210x_flush_and_resubmit_read_urb(struct usb_serial_port *port)
{
	struct urb 			*urb = port->read_urb;
	struct tty_struct		*tty = get_tty_port(port);
	struct usb_serial		*serial = port->serial;

	unsigned char *data = urb->transfer_buffer;

	int	room;
	if (!serial) {
		err("%s - null serial pointer, exiting", __func__);
		return;
	}

	if (urb->status) {
		dbg("%s - nonzero read bulk status received:  %d", __func__,
			urb->status);
			return;
	}

	dbg("%s - port %d", __func__, port->number);

	usb_serial_debug_data(debug, &port->dev, __func__,
				urb->actual_length, data);

	/* Push data to tty */
	if (tty && urb->actual_length) {
		room = tty_buffer_request_room(tty, urb->actual_length);
		if (room) {
			tty_insert_flip_string(tty,
						urb->transfer_buffer,
						room);
			/* is this allowed from an URB callback ? */
			tty_flip_buffer_push(tty);
		}
	}

	/* Schedule the next read _if_ we are still open */
	if (port->port.count)
		cp210x_resubmit_read_urb(port, GFP_ATOMIC);

	return;
}

void silabs_cp210x_read_bulk_callback(struct urb *urb)
{
	struct usb_serial_port *port = (struct usb_serial_port *)urb->context;
	int status = urb->status;

	dbg("%s - port %d", __func__, port->number);

	if (unlikely(status != 0)) {
		dbg("%s - nonzero read bulk status received: %d",
		    __func__, status);
		return;
	}

	/* Handle data and continue reading from device */
	cp210x_flush_and_resubmit_read_urb(port);
}

void silabs_cp210x_write_bulk_callback(struct urb *urb)
{
	struct usb_serial_port *port = (struct usb_serial_port *)urb->context;
	struct cp210x_port_private	*port_priv;

	dbg("%s - port %d", __func__, port->number);

	if (urb == NULL)
		return;
	else
		port = (struct usb_serial_port *)urb->context;
	port_priv = usb_get_serial_port_data(port);

	port->write_urb_busy = 0;

	if (port_priv == NULL)
		return;

	if (urb->status) {
		dbg("%s - nonzero write bulk status received: %d",
			__func__,
			urb->status);
		return;
	}

	if (get_tty_port(port) && port_priv->open) {
		/*
		 * let the tty driver wakeup if it has a
		 * special write_wakeup function
		 */
		usb_serial_port_softint(port);
	}

	spin_lock(&port_priv->portLock);
	port_priv->txCredits += urb->actual_length;
	/* Release the Write URB */
	port_priv->write_busy = FALSE;
	spin_unlock(&port_priv->portLock);

	/* Check if more data needs to be sent */
	cp210x_send_port_data(port);

	return;
}

/*****************************************************************************
 * SerialThrottle
 *	this function is called by the tty driver when it wants to stop the data
 *	being read from the port.
 *****************************************************************************/
void silabs_cp210x_throttle(struct tty_struct *tty)
{
	struct usb_serial_port *port = tty->driver_data;
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	int status;

	dbg("%s - port %d", __func__, port->number);

	if (port_priv == NULL)
		return;

	if (!port_priv->open) {
		dbg("%s - port not opened", __func__);
		return;
	}

	if (!tty) {
		dbg("%s - no tty available", __func__);
		return;
	}

	/* if we are implementing XON/XOFF, send the stop character */
	if (I_IXOFF(tty)) {
		unsigned char stop_char = STOP_CHAR(tty);
		status = cp210x_set_config_single(port,
					 SILABSER_IMM_CHAR_REQUEST_CODE,
					 stop_char);
		if (status <= 0)
			return;
	}

	/* if we are implementing RTS/CTS, toggle that line */
	if (tty->termios->c_cflag & CRTSCTS) {
		port_priv->mcr &= ~MCR_RTS;
		port_priv->line_control &= ~MCR_RTS;
		port_priv->line_control |= CONTROL_WRITE_RTS;

		dbg("%s - control = 0x%.4x", __func__, port_priv->line_control);

		/* set the new MCR value in the device */
		status = cp210x_set_config_single(port,
					SILABSER_SET_MHS_REQUEST_CODE,
					port_priv->line_control);

		if (status != 0)
			return;
	}

	return;
}

/*****************************************************************************
 *	this function is called by the tty driver when it wants to resume the data
 *	being read from the port (called after SerialThrottle is called)
 *****************************************************************************/
void silabs_cp210x_unthrottle(struct tty_struct *tty)
{
	struct usb_serial_port *port = tty->driver_data;
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);
	int status;

	dbg("%s - port %d", __func__, port->number);

	if (port_priv == NULL)
		return;

	if (!port_priv->open) {
		dbg("%s - port not opened", __func__);
		return;
	}

	if (!tty) {
		dbg("%s - no tty available", __func__);
		return;
	}

	/* if we are implementing XON/XOFF, send the start character */
	if (I_IXOFF(tty)) {
		unsigned char start_char = START_CHAR(tty);
		status = cp210x_set_config_single(port,
					 SILABSER_IMM_CHAR_REQUEST_CODE,
					 start_char);

		if (status <= 0)
			return;
	}

	/* if we are implementing RTS/CTS, toggle that line */
	if (tty->termios->c_cflag & CRTSCTS) {
		port_priv->mcr |= MCR_RTS;
		port_priv->line_control |= MCR_RTS;
		port_priv->line_control |= CONTROL_WRITE_RTS;

		dbg("%s - control = 0x%.4x", __func__, port_priv->line_control);

		/* set the new MCR value in the device */
		status = cp210x_set_config_single(port,
					SILABSER_SET_MHS_REQUEST_CODE,
					port_priv->line_control);

		if (status != 0)
			return;
	}

	return;
}

static int silabs_cp210x_calc_num_ports(struct usb_serial *serial)
{
	struct usb_device *dev = serial->dev;

	/*
	 * This is a very simple solution.  If additional Dual or Multi-Port
	 * Device IDs or Product IDs are added, setup a table with
	 * VID, PID, NumPorts
	 */

	if (0xEA70 == le16_to_cpu(dev->descriptor.idProduct))
		return 2;

	return 1;
}

static int silabs_cp210x_probe(struct usb_interface *interface,
				const struct usb_device_id *id)
{
	const struct usb_device_id *id_pattern;

	id_pattern = usb_match_id(interface, silabs_cp210x_device_ids);
	if (id_pattern != NULL)
		return usb_serial_probe(interface, id);

	return -ENODEV;
}

/*****************************************************************************
 * handle_new_msr
 *	this function handles any change to the msr register for a port.
 *****************************************************************************/
static void cp210x_handle_new_modem_status(struct usb_serial_port *port,
						unsigned int modem_status)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	struct  async_icount *icount;

	dbg("%s %02x", __func__, modem_status);

	if ((modem_status & MSR_ALL) != port_priv->msr) {
		icount = &port_priv->icount;

		/* update input line counters */
		if ((modem_status & MSR_CTS) &&
				((modem_status & MSR_CTS) !=
				(port_priv->msr & MSR_CTS))) {
			icount->cts++;
		}
		if ((modem_status & MSR_DSR) &&
				((modem_status & MSR_DSR) !=
				(port_priv->msr & MSR_DSR))) {
			icount->dsr++;
		}
		if ((modem_status & MSR_RING) &&
				((modem_status & MSR_RING) !=
				(port_priv->msr & MSR_RING))) {
			icount->dcd++;
		}
		if ((modem_status & MSR_DCD) &&
				((modem_status & MSR_DCD) !=
				(port_priv->msr & MSR_DCD))) {
			icount->rng++;
		}
		wake_up_interruptible(&port_priv->delta_msr_wait);
	}

	/* Save the new modem status */
	port_priv->msr = modem_status & MSR_ALL;

	return;
}

/*****************************************************************************
 * handle_new_lsr
 *	this function handles any change to the lsr register for a port.
 *****************************************************************************/
static void cp210x_handle_new_line_status(struct usb_serial_port *port)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);

	__u8 newLsr = (__u8) port_priv->serialstat.ulErrors;

	struct  async_icount *icount;

	dbg("%s - %02x", __func__, newLsr);

	if (newLsr & LSR_BREAK) {
		/*
		 * Parity and Framing errors only count if they
		 * occur exclusive of a break being
		 * received.
		 */
		newLsr &= (__u8)(LSR_HW_OVERRUN |
				LSR_QUEUE_OVERRUN |
				LSR_BREAK);
	}

	/* update input line counters */
	icount = &port_priv->icount;
	if (newLsr & LSR_BREAK)
		icount->brk++;

	if (newLsr & LSR_QUEUE_OVERRUN)
		icount->overrun++;

	if (newLsr & LSR_PARITY_ERROR)
		icount->parity++;

	if (newLsr & LSR_FRAMING_ERROR)
		icount->frame++;

	port_priv->lsr = (__u8) port_priv->serialstat.ulErrors & LSR_ALL;
	return;
}

static int cp210x_control_thread(void *theport)
{
	unsigned int	ret_code = 0;
	unsigned int	line_control = 0;
	unsigned long timeout = (TIMEOUT_10ms * 8);
	struct usb_serial_port *port = (struct usb_serial_port *) theport;
	allow_signal(SIGKILL);
	while (!kthread_should_stop()) {
		set_current_state(TASK_INTERRUPTIBLE);

		timeout = schedule_timeout(timeout);

		if (signal_pending(current))
			break;

		if (!timeout) {
			/* check status */
			ret_code = cp210x_get_serialstat(port) ;
			if (!ret_code)
				break;

			cp210x_handle_new_line_status(port);

			if ((cp210x_get_config(port,
					SILABSER_GET_MDMSTS_REQUEST_CODE,
					&line_control,
					1))) {
				break;
			}

			cp210x_handle_new_modem_status(port,
					line_control);

			timeout = (TIMEOUT_10ms * 8);
		} else {
			/* process standard control requests */
		}

	}
	set_current_state(TASK_RUNNING);
	return 0;
}

static int cp210x_start_control_thread(struct usb_serial_port *port)
{
	int ret = 0;

	struct cp210x_port_private *port_priv =
		usb_get_serial_port_data((struct usb_serial_port *) port);

	port_priv->cp210x_task = kthread_create(cp210x_control_thread, port,
						"%s",
						"cp210x_control_thread");

	if (!IS_ERR(port_priv->cp210x_task))
		wake_up_process(port_priv->cp210x_task);
	return ret;
}

static int silabs_cp210x_startup(struct usb_serial *serial)
{
	struct cp210x_serial_private *serial_priv;
	struct cp210x_port_private *port_priv;
	int					i;

	/* CP2101 buffers behave strangely unless device is reset */
	usb_reset_device(serial->dev);

	serial_priv = kmalloc(sizeof(struct cp210x_serial_private), GFP_KERNEL);
	if (!serial_priv)
		return -ENOMEM;

	memset(serial_priv, 0x00, sizeof(struct cp210x_serial_private));
	spin_lock_init(&serial_priv->devLock);
	serial_priv->serial = serial;
	usb_set_serial_data(serial, serial_priv);

	for (i = 0; i < serial->num_ports; ++i) {
		port_priv = kmalloc(sizeof(*port_priv), GFP_KERNEL);
		if (!port_priv)
			return -ENOMEM;

		memset(port_priv, 0x00, sizeof(struct cp210x_port_private));
		spin_lock_init(&port_priv->portLock);

		mutex_init(&port_priv->controlPipeMutex);

		port_priv->port = serial->port[i];
		usb_set_serial_port_data(serial->port[i], port_priv);
		cp210x_get_partnum(serial->port[i]);
	}

	return 0;
}

static void cp210x_stop_control_thread(struct usb_serial_port  *port)
{
	return;
}

void silabs_cp210x_shutdown(struct usb_serial *serial)
{
	int i;

	/* stop reads and writes on all ports */
	for (i = 0; i < serial->num_ports; ++i)
		cp210x_close_port(serial->port[i]);

	kfree(usb_get_serial_data(serial));
	usb_set_serial_data(serial, NULL);
}

static int __init silabs_cp210x_init(void)
{
	int retval = 0;

	retval = usb_serial_register(&silabs_cp210x_device);
	if (retval)
		return retval;

	retval = usb_register(&silabs_cp210x_driver);
	if (retval) {
		/* Failed to register */
		usb_serial_deregister(&silabs_cp210x_device);
		return retval;
	}

	/* Success */
	return 0;
}

static void __exit silabs_cp210x_exit(void)
{
	usb_deregister(&silabs_cp210x_driver);
	usb_serial_deregister(&silabs_cp210x_device);
}

module_init(silabs_cp210x_init);
module_exit(silabs_cp210x_exit);

MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_LICENSE("GPL");

MODULE_VERSION(DRIVER_VERSION);
module_param(debug, bool, S_IRUGO | S_IWUSR);

MODULE_PARM_DESC(debug, "Enable verbose debugging messages");
/* end of #if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6.29)) version for 2.6.29/30 */
#endif
