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
 *		Copyright (C) 2000 Inside Out Networks, All rights reserved.
 *		Copyright (C) 2001-2002 Greg Kroah-Hartman <greg@kroah.com>
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

#define DEV_ERR(dev,format,arg...)		dev_err(dev,format, ## arg)
#define USB_KILL_URB				usb_kill_urb

#define USB_SUBMIT_URB_ATOMIC(_x_)		usb_submit_urb(_x_ , GFP_ATOMIC)
#define USB_SUBMIT_URB_KERNEL(_x_)		usb_submit_urb(_x_ , GFP_KERNEL)

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

static int  silabs_cp210x_open(struct tty_struct *tty,
							   struct usb_serial_port *port, struct file *filp);

static void silabs_cp210x_close(struct tty_struct *tty,
								struct usb_serial_port *port, struct file *filp);
//(struct usb_serial_port*,
//						struct file*);

static int  silabs_cp210x_tiocmget(struct tty_struct *tty, struct file *file);
//(struct usb_serial_port *,
//						struct file *);

static int  silabs_cp210x_tiocmset(struct tty_struct *tty, struct file *file,
								   unsigned int set, unsigned int clear);
//		(struct usb_serial_port *,
//						struct file *,
//						unsigned int,
//						unsigned int);

static void silabs_cp210x_break_ctl(struct tty_struct *tty, int break_state);
//(struct usb_serial_port*,
//	int);

static int  silabs_cp210x_startup		(struct usb_serial *);

static void silabs_cp210x_shutdown		(struct usb_serial*);

static void silabs_cp210x_throttle(struct tty_struct *tty);
//(struct usb_serial_port *port);

static void silabs_cp210x_unthrottle(struct tty_struct *tty);
//(struct usb_serial_port *port);

static void silabs_cp210x_read_bulk_callback	(struct urb *urb);

static void silabs_cp210x_write_bulk_callback	(struct urb *urb);

static int silabs_cp210x_ioctl(struct tty_struct *tty, struct file *file,
							   unsigned int cmd, unsigned long arg);
//(struct usb_serial_port *port,
//						struct file *file,
//						unsigned int cmd,
//						unsigned long arg);

static void cp210x_get_termios			(struct usb_serial_port*);

static int cp210x_get_serialstat		(struct usb_serial_port *port);

static int cp210x_get_commprops			(struct usb_serial_port *port);

static int silabs_cp210x_write_room(struct tty_struct *tty);
// (struct usb_serial_port *port);

static int silabs_cp210x_chars_in_buffer(struct tty_struct *tty);
//(struct usb_serial_port *port);

static int cp210x_get_partnum			(struct usb_serial_port *port);

static int silabs_cp210x_write			(struct usb_serial_port *port,
						int from_user,
						const unsigned char *buf,
						int count);

static void silabs_cp210x_set_termios(struct tty_struct *tty,
									  struct usb_serial_port *port, struct ktermios *old);
//(struct usb_serial_port *port,
//						struct ktermios *old_termio);

static int silabs_cp210x_calc_num_ports		(struct usb_serial *serial);


static int silabs_cp210x_write_wrapper(struct tty_struct *tty, struct usb_serial_port *port,
									   const unsigned char *buf, int count);
//(struct usb_serial_port *port,
//						const unsigned char *buf,
//						int count);

static int silabs_cp210x_probe			(struct usb_interface *interface,
						const struct usb_device_id *id);


static int silabs_cp210x_suspend		(struct usb_serial *serial,
						pm_message_t message);

static int silabs_cp210x_resume			(struct usb_serial *serial);

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
	struct mutex				controlPipeMutex;

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

	struct task_struct			*cp210x_task;
	__u8						bInterfaceNumber;
};


struct cp210x_serial_private {

	struct usb_serial			*serial;		/* loop back to the owner of this object */
	spinlock_t					devLock;
	enum cp210x_type			devType;
	int							numberOfPorts;
};




#endif
