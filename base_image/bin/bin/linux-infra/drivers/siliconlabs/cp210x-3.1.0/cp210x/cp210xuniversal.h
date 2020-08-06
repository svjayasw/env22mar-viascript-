/*
 * cp210x.h - Interface definitions
 *
 * Silicon Laboratories CP210x Serial Adaptor Driver for Linux 2.4 and 2.6 kernels
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
 *      	Copyright (C) 2000 Inside Out Networks, All rights reserved.
 *      	Copyright (C) 2001-2002 Greg Kroah-Hartman <greg@kroah.com>
 * 
 * This code was also based on the original Silicon Laboratories
 *	CP2101/CP2102 USB to RS232 serial adaptor driver CP2101.c:
 *		Copyright (C) 2005 Craig Shelley (craig@microtron.org.uk)
 *
 *
 *
 * The following devices are supported with this driver:
 *	CP2101
 *	CP2102
 *	CP2103
 *
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
 * See Documentation/usb/usb-serial.txt for more information on using this driver
 *
 * 03-June-2008 dgo
 *	Initial Release
 *
 */


#ifndef __LINUX_USB_SERIAL_CP210X_H
#define __LINUX_USB_SERIAL_CP210X_H

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
//#include <linux/types.h>

#ifdef LINUX26

#include <linux/moduleparam.h>
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,18))
#include <linux/usb/serial.h>
#else
//#include "usb-serial.h"
#include "../drivers/usb/serial/usb-serial.h"
#endif

#else
#include <linux/config.h>
#include "../drivers/usb/serial/usb-serial.h"
#endif



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

#ifdef LINUX26

#ifndef USB_ASYNC_UNLINK
#define USB_ASYNC_UNLINK (0)
#endif

#else //LINUX26

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,4,28))

/* get and set the port private data pointer helper functions */
static inline void *usb_get_serial_port_data (struct usb_serial_port *port)
{
	return port->private;
}

static inline void usb_set_serial_port_data (struct usb_serial_port *port, void *data)
{
	port->private = data;
}

/* get and set the serial private data pointer helper functions */
static inline void *usb_get_serial_data (struct usb_serial *serial)
{
	return serial->private;
}

static inline void usb_set_serial_data (struct usb_serial *serial, void *data)
{
	serial->private = data;
}

#endif
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
#ifdef LINUX26

#define DEV_ERR(dev,format,arg...)		dev_err(dev,format, ## arg)
#define USB_KILL_URB				usb_kill_urb

#define USB_SUBMIT_URB_ATOMIC(_x_)		usb_submit_urb(_x_ , GFP_ATOMIC)
#define USB_SUBMIT_URB_KERNEL(_x_)		usb_submit_urb(_x_ , GFP_KERNEL)

#else /* !LINUX26 */

#define DEV_ERR(dev,format,arg...)		err(format, ## arg)
#define USB_KILL_URB				usb_unlink_urb

#define USB_SUBMIT_URB_ATOMIC(_x_)		usb_submit_urb(_x_)
#define USB_SUBMIT_URB_KERNEL(_x_)		usb_submit_urb(_x_)

#endif /* LINUX26 */




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
#define SILABSER_GET_BAUDRATE				0x1D
#define SILABSER_SET_BAUDRATE				0x1E



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
static void cp210x_handle_new_modem_status	(struct usb_serial_port* port,
						unsigned int modem_status);

static void cp210x_handle_new_line_status	(struct usb_serial_port* port);

static int cp210x_control_thread		(void*);

static int cp210x_start_control_thread		(struct usb_serial_port*);

static void cp210x_stop_control_thread		(struct usb_serial_port*);

static void cp210x_cleanup_port			(struct usb_serial_port*);

static int  silabs_cp210x_open			(struct usb_serial_port*,
						struct file*);

static void silabs_cp210x_close			(struct usb_serial_port*,
						struct file*);
		
static int  silabs_cp210x_tiocmget		(struct usb_serial_port *,
						struct file *); 

static int  silabs_cp210x_tiocmset		(struct usb_serial_port *,
						struct file *, 
						unsigned int,
						unsigned int);

static void silabs_cp210x_break_ctl		(struct usb_serial_port*,
						int);

static int  silabs_cp210x_startup		(struct usb_serial *);

static void silabs_cp210x_shutdown		(struct usb_serial*);

static void silabs_cp210x_throttle		(struct usb_serial_port *port);

static void silabs_cp210x_unthrottle		(struct usb_serial_port *port);

static void silabs_cp210x_read_bulk_callback	(struct urb *urb);

static void silabs_cp210x_write_bulk_callback	(struct urb *urb);

static int silabs_cp210x_ioctl			(struct usb_serial_port *port,
						struct file *file,
						unsigned int cmd,
						unsigned long arg);

static void cp210x_get_termios			(struct usb_serial_port*);

static int cp210x_get_serialstat		(struct usb_serial_port *port);

static int cp210x_get_commprops			(struct usb_serial_port *port);

static int silabs_cp210x_write_room		(struct usb_serial_port *port);

static int silabs_cp210x_chars_in_buffer	(struct usb_serial_port *port);

static int cp210x_get_partnum			(struct usb_serial_port *port);

static int silabs_cp210x_write			(struct usb_serial_port *port,
						int from_user,
						const unsigned char *buf,
						int count);

static void silabs_cp210x_set_termios		(struct usb_serial_port *port,
						struct ktermios *old_termio);

static int silabs_cp210x_calc_num_ports		(struct usb_serial *serial);




#ifdef LINUX26

static int silabs_cp210x_write_wrapper		(struct usb_serial_port *port,
						const unsigned char *buf,
						int count);

static int silabs_cp210x_probe			(struct usb_interface *interface,
						const struct usb_device_id *id);


#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,23))
static int silabs_cp210x_suspend		(struct usb_serial *serial,
						pm_message_t message);

static int silabs_cp210x_resume			(struct usb_serial *serial);
#endif

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,18))
static void silabs_cp210x_read_bulk_callback_wrapper	(struct urb *urb, struct pt_regs *regs);

static void silabs_cp210x_write_bulk_callback_wrapper	(struct urb *urb, struct pt_regs *regs);
#endif

#else //LINUX26

static void silabs_cp210x_read_bulk_callback_wrapper	(struct urb *urb, struct pt_regs *regs);

static void silabs_cp210x_write_bulk_callback_wrapper	(struct urb *urb, struct pt_regs *regs);

#endif //LINUX26





enum cp210x_type {
	none,
	cp2101,
	cp2102,
	cp2103,
	cp2105
};



// Table 7. Communication Properties Response
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
	__u8*				uniProvName;
};



// Table 8. Serial Status Response
struct SerialStat {
	__u32				ulErrors;
	__u32				ulHoldReasons;
	__u32				ulAmountIn_InQueue;
	__u32				ulAmountIn_OutQueue;
	__u8				bEofReceived;
	__u8				bWaitForImmediate;
	__u8				bReserved;
};
	


// Table 10. ulControlHandshake
#define CtrlHandshake_DTR_Mask			0x00000003
#define CtrlHandshake_AlwaysZero_Mask		0x00000004	/* Reserved- always zero */
#define CtrlHandshake_CTS_Handshake_Mask	0x00000008	/* 0: status; 1: handshake */
#define CtrlHandshake_DSR_Handshake_Mask	0x00000010	/* 0: status; 1: handshake */
#define CtrlHandshake_DCD_Handshake_Mask	0x00000020	/* 0: status; 1: handshake */
#define CtrlHandshake_DSR_Sensitivity_Mask	0x00000040	/* 0: status; 1: discards data */
#define CtrlHandshake_Reserved_Mask		0xFFFFFF80	/* Reserved */

#define CtrlHandshake_DTR_Inactive		0x00000000	/* DTR is held inactive */
#define CtrlHandshake_DTR_Active		0x00000001	/* DTR is held active */
#define CtrlHandshake_DTR_Firmware		0x00000002	/* DTR is controlled by port firmware */
#define CtrlHandshake_DTR_Reserved		0x00000003	/* Reserved */



// Table 11. ulFlowReplace
#define FlowReplace_Auto_Transmit_Mask		0x00000001	/* 0: Off; 1: firmware processes received Xon/Xoff chars */
#define FlowReplace_Auto_Receive_Mask		0x00000002	/* 0: Off; 1: firmware will transmit Xon/Xoff chars */
#define FlowReplace_Error_Char_Mask		0x00000004	/* 0: character is discarded; 1: ERROR character is inserted */
#define FlowReplace_NULL_Striping_Mask		0x00000008	/* 0: off; 1: device will strip NULL characters */
#define FlowReplace_Break_Char_Mask		0x00000010	/* 0: only bit error mask set; 1: mask set ahd BREAK char inserted */
#define FlowReplace_Reserved_Mask		0x00000020	/* Reserved */
#define FlowReplace_RTS_Mask			0x000000C0
#define FlowReplace_Always_Zero			0x7FFFFF00	/* Reverved - Must be written as zero */
#define FlowReplace_XOFF_Continue_Mask		0x80000000

#define FlowReplace_RTS_Statically_Inactive	0x00000000	/* RTS is held inactive */
#define FlowReplace_RTS_Statically_Active	0x00000040	/* RTS is held active */
#define FlowReplace_RTS_Receive_Flow		0x00000080	/* RTS is controlled by port firmware for receive flow */
#define FlowReplace_RTS_Transmit_Active		0x000000C0	/* RTS held active while transmitting */




	
// Table 9. Flow Control Setting/Response
struct CommFlow {
	__u32				controlHandshake;
	__u32				flowReplace;
	__u32				ulXonLimit;
	__u32				ulXoffLimit;
};



// Table 12. Special Characters Response
#define SpecialChars_bEofChar_Mask	0x01
#define SpecialChars_bErrorChar_Mask	0x02
#define SpecialChars_bBreakChar_Mask	0x04
#define SpecialChars_bEventChar_Mask	0x08
#define SpecialChars_bXonChar_Mask	0x10
#define SpecialChars_bXoffChar_Mask	0x20





// jiffies time out values.
#define TIMEOUT_1ms		((1*HZ)/1000)	/* 1 milliseconds */
#define TIMEOUT_10ms		((1*HZ)/100)	/* 10 milliseconds */
#define TIMEOUT_100ms		((1*HZ)/10)	/* 100 milliseconds */
#define TIMEOUT_1s		((1*HZ))	/* 1 second */

#ifndef SERIAL_MAGIC
	#define SERIAL_MAGIC	0x6702
#endif

#ifndef PORT_MAGIC
#define PORT_MAGIC		0x7301
#endif

#if 0
/* receive port state */
enum RXSTATE {
	EXPECT_HDR1 = 0,	/* Expect header byte 1 */
	EXPECT_HDR2 = 1,	/* Expect header byte 2 */
	EXPECT_DATA = 2,	/* Expect 'RxBytesRemaining' data */
	EXPECT_HDR3 = 3,	/* Expect header byte 3 */
};
#endif

/* Transmit Fifo 
 * This Transmit queue is an extension of the Rx buffer. 
 * The maximum amount of data buffered in both the
 * Rx buffer (maxTxCredits) and this buffer will never exceed maxTxCredits.
 */
struct circular_buf_txfifo {
	unsigned int		head;	/* index to head pointer (write) */
	unsigned int		tail;	/* index to tail pointer (read)  */
	unsigned int		count;	/* Bytes in queue */
	unsigned int		size;	/* Max size of queue (equal to MaxTxCredits) */
	unsigned char		*fifo;	/* allocated Buffer */
};



struct cp210x_port_private {
	__u16						txCredits;		/* our current credits for this port */
	__u16						maxTxCredits;		/* the max size of the port */
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	struct semaphore			controlPipeMutex;
#else
	struct mutex				controlPipeMutex;
#endif

	struct circular_buf_txfifo	circular_buf_txfifo;	/* transmit fifo -- size will be maxTxCredits */
	struct urb					*write_urb;		/* write URB for this port */
	char						write_busy;		/* TRUE while a write URB is outstanding */

	__u8						shadowLCR;		/* last LCR value received */
	//__u8						shadowMCR;		/* last MCR value received */
	__u8						shadowMSR;		/* last MSR value received */
	__u8						shadowLSR;		/* last LSR value received */
	__u8						shadowXonChar;		/* last value set as XON char */
	__u8						shadowXoffChar;		/* last value set as XOFF char */
	__u8						validDataMask;
	__u32						baudRate;

	char						open;
	char						openPending;
	char						commandPending;
	char						closePending;
	char						chaseResponsePending;

	wait_queue_head_t			wait_control;
	wait_queue_head_t			wait_open;
	wait_queue_head_t			wait_command;		/* for sleeping while waiting for command to finish */
	wait_queue_head_t			delta_msr_wait;		/* for sleeping while waiting for msr change to happen */

	struct async_icount			icount;
	struct usb_serial_port		*port;				/* loop back to the owner of this object */

/*****************************************/

	spinlock_t					portLock;
	char						throttled;
	char						throttle_req;
	struct SerialStat			serialstat;
	struct CommProps			commprops;
	struct termios				orig_termios;
	struct termios				curr_termios;
	struct task_struct			task_struct;
	__u8						termios_initialized;
	__u8						mcr;
	__u8						msr;
	__u8						lsr;
	__u8						line_control;
	__u8						run_cp210x_control_thread;


	__u8						bulk_in_endpoint;	/* the bulk in endpoint handle */
	unsigned char				*bulk_in_buffer;	/* the buffer we use for the bulk in endpoint */
	struct urb					*read_urb;			/* our bulk read urb */
	__u8						bulk_out_endpoint;	/* the bulk out endpoint handle */

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
	struct completion			portThreadComplete;
#else
	struct task_struct			*cp210x_task;
#endif

	__u8						bInterfaceNumber;
};


struct cp210x_serial_private {

	struct usb_serial			*serial;		/* loop back to the owner of this object */
	spinlock_t					devLock;
	enum cp210x_type			devType;
	int							numberOfPorts;
};



static struct usb_device_id silabs_cp210x_device_ids[] = {
	{ USB_DEVICE(0x0FCF, 0x1003) }, /* Dynastream ANT development board */
	{ USB_DEVICE(0x10A6, 0xAA26) }, /* Knock-off DCU-11 cable */
	{ USB_DEVICE(0x10AB, 0x10C5) }, /* Siemens MC60 Cable */
	{ USB_DEVICE(0x10B5, 0xAC70) }, /* Nokia CA-42 USB */
	{ USB_DEVICE(0x10C4, 0x803B) }, /* Pololu USB-serial converter */
	{ USB_DEVICE(0x10C4, 0x8066) }, /* Argussoft In-System Programmer */
	{ USB_DEVICE(0x10C4, 0x807A) }, /* Crumb128 board */
	{ USB_DEVICE(0x10C4, 0x80CA) }, /* Degree Controls Inc */
	{ USB_DEVICE(0x10C4, 0x80F6) }, /* Suunto sports instrument */
	{ USB_DEVICE(0x10C4, 0x813D) }, /* Burnside Telecom Deskmobile */
	{ USB_DEVICE(0x10C4, 0x814A) }, /* West Mountain Radio RIGblaster P&P */
	{ USB_DEVICE(0x10C4, 0x814B) }, /* West Mountain Radio RIGtalk */
	{ USB_DEVICE(0x10C4, 0x815E) }, /* Helicomm IP-Link 1220-DVM */
	{ USB_DEVICE(0x10C4, 0x81C8) }, /* Lipowsky Industrie Elektronik GmbH, Baby-JTAG */
	{ USB_DEVICE(0x10C4, 0x81E2) }, /* Lipowsky Industrie Elektronik GmbH, Baby-LIN */
	{ USB_DEVICE(0x10C4, 0x8218) }, /* Lipowsky Industrie Elektronik GmbH, HARP-1 */
	{ USB_DEVICE(0x10C4, 0xEA60) }, /* Silicon Labs factory default */
	{ USB_DEVICE(0x10C4, 0xEA61) }, /* Silicon Labs factory default */
	{ USB_DEVICE(0x10C4, 0xEA70) }, /* Silicon Labs Dual Port factory default */
	{ USB_DEVICE(0x10C5, 0xEA61) }, /* Silicon Labs MobiData GPRS USB Modem */
	{ USB_DEVICE(0x13AD, 0x9999) }, /* Baltech card reader */
	{ USB_DEVICE(0x16D6, 0x0001) }, /* Jablotron serial interface */
	{}
};
MODULE_DEVICE_TABLE (usb, silabs_cp210x_device_ids);



#ifdef LINUX26

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,23))

/*
 *
 *  Distributions 2.6.23 and above
 *
 */



//
// From Linux linux-2.6.23.i686/include/linux/usb/serial.h
//
static struct usb_driver silabs_cp210x_driver = {
	.name					= "silabs_cp210x_cp210x",
	.probe					= silabs_cp210x_probe,
	.disconnect				= usb_serial_disconnect,
	.id_table				= silabs_cp210x_device_ids,
	.no_dynamic_id				= 1,
};



//
// From Linux linux-2.6.23.i686/include/linux/usb/serial.h
//
static struct usb_serial_driver silabs_cp210x_device = {
	//.description
	.id_table				= silabs_cp210x_device_ids,
#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,26))
	.num_interrupt_in			= 0,
	.num_interrupt_out			= 0,
	.num_bulk_in				= 1,
	.num_bulk_out				= 1,
#endif	
	.num_ports				= 1,
	//.driver_list
	.driver = {
		.owner				= THIS_MODULE,
		.name				= "SiLabs-cp210x",
	},
	.usb_driver				= &silabs_cp210x_driver,
	//.dynids
	//.probe
	.attach					= silabs_cp210x_startup,
	//.calc_num_ports			= silabs_cp210x_calc_num_ports,
	.shutdown				= silabs_cp210x_shutdown,
	//.port_probe
	//.port_remove
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
	//.read_int_callback			// not supported by cp210x
	//.write_int_callback			// not supported by cp210x
	.read_bulk_callback		= silabs_cp210x_read_bulk_callback,
	.write_bulk_callback	= silabs_cp210x_write_bulk_callback,
};



#elif (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,23) && LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,15))



/*
 *
 *  Distributions 2.6.15 through 2.6.22
 *
 */



//
// From Linux linux-2.6.22.i686/include/linux/usb/serial.h
// &
// From Linux linux-2.6.21.i686/include/linux/usb/serial.h
//
static struct usb_driver silabs_cp210x_driver = {
	.name					= "silabs_cp210x_cp210x",
	.probe					= silabs_cp210x_probe,
	.disconnect				= usb_serial_disconnect,
	.id_table				= silabs_cp210x_device_ids,
#if (LINUX_VERSION_CODE > KERNEL_VERSION(2,6,15))
	.no_dynamic_id				= 1,
#endif
};



//
// From Linux linux-2.6.22.i686/include/linux/usb/serial.h
// &
// From Linux linux-2.6.21.i686/include/linux/usb/serial.h
//
static struct usb_serial_driver silabs_cp210x_device = {
	//.description
	.id_table				= silabs_cp210x_device_ids,
	.num_interrupt_in			= 0,
	.num_interrupt_out			= 0,
	.num_bulk_in				= 1,
	.num_bulk_out				= 1,
	.num_ports				= 1,
	//.driver_list
	.driver = {
		.owner				= THIS_MODULE,
		.name				= "SiLabs-cp210x",
	},
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,21))
	.usb_driver				= &silabs_cp210x_driver,
	//.dynids
#endif	
	//.probe
	.attach					= silabs_cp210x_startup,
	//.calc_num_ports
	.shutdown				= silabs_cp210x_shutdown,
	//.port_probe
	//.port_remove
	.open					= silabs_cp210x_open,
	.close					= silabs_cp210x_close,
	.write					= silabs_cp210x_write_wrapper,
	.write_room				= silabs_cp210x_write_room,
	.ioctl					= silabs_cp210x_ioctl,
	.set_termios				= silabs_cp210x_set_termios,
	.break_ctl				= silabs_cp210x_break_ctl,
	.chars_in_buffer			= silabs_cp210x_chars_in_buffer,
	.throttle				= silabs_cp210x_throttle,
	.unthrottle				= silabs_cp210x_unthrottle,
	.tiocmget				= silabs_cp210x_tiocmget,
	.tiocmset				= silabs_cp210x_tiocmset,
	//.read_int_callback			// not supported by cp210x
	//.write_int_callback			// not supported by cp210x
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,18))
	.read_bulk_callback			= silabs_cp210x_read_bulk_callback_wrapper,
	.write_bulk_callback			= silabs_cp210x_write_bulk_callback_wrapper,
#else
	.read_bulk_callback			= silabs_cp210x_read_bulk_callback,
	.write_bulk_callback			= silabs_cp210x_write_bulk_callback,
#endif	
};



#else // > 2.6.15



/*
 *
 *  Distributions 2.6.0 through 2.6.14
 *
 */
static struct usb_driver silabs_cp210x_driver = {
	.owner					= THIS_MODULE,
	.name					= "silabs_cp210x_cp210x",
	.probe					= silabs_cp210x_probe,
	.disconnect				= usb_serial_disconnect,
	.id_table				= silabs_cp210x_device_ids,
};



static struct usb_serial_device_type silabs_cp210x_device = {
	.owner					= THIS_MODULE,		
	.name					= "silabs_cp210x_cp210x",
	//.short_name
	.id_table				= silabs_cp210x_device_ids,
	.num_interrupt_in			= 0,
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,10))
	.num_interrupt_out			= 0,
#endif
	.num_bulk_in				= 1,
	.num_bulk_out				= 1,
	.num_ports				= 1,
	//.driver_list;
	.driver = {
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,10))
		.owner				= THIS_MODULE,
#endif
		.name				= "SiLabs-cp210x",
	},
	//.probe
	.attach					= silabs_cp210x_startup,
	//.calc_num_ports

	.shutdown				= silabs_cp210x_shutdown,

	//.port_probe
	//.port_remove

	/* serial function calls */
	.open					= silabs_cp210x_open,
	.close					= silabs_cp210x_close,
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,10))
	.write					= silabs_cp210x_write_wrapper,
#else
	.write					= silabs_cp210x_write,
#endif	
	.write_room				= silabs_cp210x_write_room,
	.ioctl					= silabs_cp210x_ioctl,
	.set_termios				= silabs_cp210x_set_termios,
	.break_ctl				= silabs_cp210x_break_ctl,
	.chars_in_buffer			= silabs_cp210x_chars_in_buffer,
	.throttle				= silabs_cp210x_throttle,
	.unthrottle				= silabs_cp210x_unthrottle,
	.tiocmget				= silabs_cp210x_tiocmget,
	.tiocmset				= silabs_cp210x_tiocmset,
	//.read_int_callback			// not supported by cp210x
	//.write_int_callback			// not supported by cp210x
	.read_bulk_callback			= silabs_cp210x_read_bulk_callback_wrapper,
	.write_bulk_callback			= silabs_cp210x_write_bulk_callback_wrapper,
};
#endif // > 2.6.15



//  LINUX26	 LINUX26	 LINUX26	 LINUX26
// ^^^^^^^^^	^^^^^^^^^	^^^^^^^^^	^^^^^^^^^
// |||||||||	|||||||||	|||||||||	|||||||||
//
//



#else // LINUX26



//
//
//|||||||||	|||||||||	|||||||||	|||||||||
//vvvvvvvvv	vvvvvvvvv	vvvvvvvvv	vvvvvvvvv       
// LINUX24	 LINUX24	 LINUX24	 LINUX24



/*
 *
 *  Distributions 2.4.36 and prior
 *
 */
 


//
// From Linux linux-2.4.36.i686/include/linux/usb/serial.h
//
static struct usb_serial_device_type silabs_cp210x_device = {
	.owner					= THIS_MODULE,
	.name					= "SiLabs-cp210x",
	.id_table				= silabs_cp210x_device_ids,
	.num_interrupt_in			= 0,
	.num_bulk_in				= 1,
	.num_bulk_out				= 1,
	.num_ports				= 1,
	//.driver_list
	.startup				= silabs_cp210x_startup,
	.shutdown				= silabs_cp210x_shutdown,
	.open					= silabs_cp210x_open,
	.close					= silabs_cp210x_close,
	.write					= silabs_cp210x_write,
	.write_room				= silabs_cp210x_write_room,
	.ioctl					= silabs_cp210x_ioctl,
	.set_termios				= silabs_cp210x_set_termios,
	.break_ctl				= silabs_cp210x_break_ctl,
	.chars_in_buffer			= silabs_cp210x_chars_in_buffer,
	.throttle				= silabs_cp210x_throttle,
	.unthrottle				= silabs_cp210x_unthrottle,
	//.read_int_callback			// not supported by cp210x
	.read_bulk_callback			= silabs_cp210x_read_bulk_callback,
	.write_bulk_callback			= silabs_cp210x_write_bulk_callback,
};
#endif // LINUX26
#endif
