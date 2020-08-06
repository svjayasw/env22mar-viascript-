/*
 * cp210x.c
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
 * Updated for latest devices and version 2.6.29
 *      	Copyright (C) 2009 Silicon Laboratories Inc. <MCU.Tools@silabs.com>
 *			modifications by Firmlogix <rmsith@firmlogix.com>
 *
 * The following devices are supported with this driver:
 *	CP2101
 *	CP2102
 *	CP2103
 *	CP2104
 *	CP2105
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
 * 22-August-2008 Paragon
 *      Bugfix in cp210x_internal_ioctl( ) when calling IOCTL_GPIOSET:
 *      Return value must be 0 when cp210x_gpioset() returns 0 (correct)
 *
 */

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
#include <asm/uaccess.h>

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#include <asm/semaphore.h>
#else
#include <linux/mutex.h>
#endif

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
#else
#include <linux/kthread.h>
#endif


/*
 * Debug
 */
#ifdef CONFIG_USB_SERIAL_DEBUG
	static int debug = 1;
	#define DEBUG 
#else
	static int debug;
	#undef DEBUG 
#endif

#include <linux/usb.h>
#include <linux/serial.h>
#include "cp210xuniversal.h"



/*
 * Version Information
 */
#define DRIVER_VERSION "v1.10.0"
#define DRIVER_AUTHOR "DGO"
#define DRIVER_DESC "Silicon Labs CP210x USB Serial Adaptor Driver"





/*
 * cp210x_get_config_bytes
 * Reads from the SILABS configuration registers
 * 'size' is specified in bytes.
 * 'data' is a pointer to a pre-allocated array of bytes large
 * enough to hold 'size' bytes (with 4 bytes to each integer)
 */
static int cp210x_get_config_bytes(struct usb_serial_port* port, u8 request,
		unsigned char *data, int size)
{
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	struct usb_serial *serial = port->serial;
	u8 *buf;
	int result, i;

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	down(&port_priv->controlPipeMutex);
	//if (down_interruptible(&port_priv->controlPipeMutex))
	//	return -ERESTARTSYS;
#else
	mutex_lock(&port_priv->controlPipeMutex);
#endif
				
	buf = kmalloc (size * sizeof(u8), GFP_KERNEL);
	memset(buf, 0, size * sizeof(u8));

	if (!buf) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
		up(&port_priv->controlPipeMutex);
#else
		mutex_unlock(&port_priv->controlPipeMutex);
#endif
		DEV_ERR(&port->dev,"%s - out of memory.\n", __FUNCTION__);
		return -ENOMEM;
	}

	/* Issue the request, attempting to read 'size' bytes */
	result = usb_control_msg (serial->dev,
					usb_rcvctrlpipe (serial->dev, 0),
					request, 
					REQTYPE_DEVICE_TO_HOST, 
					0x0000,
					port_priv->bInterfaceNumber, 
					buf, 
					size, 
					300);

	/* Convert data into an array of integers */
	for (i=0; i<size; i++) data[i] = buf[i];

	kfree(buf);

	if ((result != size) && (request != SILABSER_GET_PROPS_REQUEST_CODE)) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
		up(&port_priv->controlPipeMutex);
#else
		mutex_unlock(&port_priv->controlPipeMutex);
#endif
		DEV_ERR(&port->dev,"%s - get_config_bytes unable to send config request, "
				"request=0x%x size=%d result=%d\n",
				__FUNCTION__, request, size, result);
		return -EPROTO;
	}

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	up(&port_priv->controlPipeMutex);
#else
	mutex_unlock(&port_priv->controlPipeMutex);
#endif
	return result;
}

/*
 * cp210x_get_config
 * Reads from the SILABS configuration registers
 * 'size' is specified in bytes.
 * 'data' is a pointer to a pre-allocated array of integers large
 * enough to hold 'size' bytes (with 4 bytes to each integer)
 */
static int cp210x_get_config(struct usb_serial_port* port, u8 request,
		unsigned int *data, int size)
{
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	struct usb_serial *serial = port->serial;

	__le32 *buf;

	int result, i, length;

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	down(&port_priv->controlPipeMutex);
	//if (down_interruptible(&port_priv->controlPipeMutex))
	//	return -ERESTARTSYS;
#else
	mutex_lock(&port_priv->controlPipeMutex);
#endif
				
	/* Number of integers required to contain the array */
	length = (((size - 1) | 3) + 1)/4;

#ifdef LINUX26
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,10))
	buf = kcalloc(length, sizeof(__le32), GFP_KERNEL);
#else
	buf = kmalloc(length * sizeof(__le32), GFP_KERNEL);
#endif

#else
	buf = kmalloc(length * sizeof(__le32), GFP_KERNEL);
#endif

	if (!buf) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
		up(&port_priv->controlPipeMutex);
#else
		mutex_unlock(&port_priv->controlPipeMutex);
#endif
		DEV_ERR(&port->dev,"%s - out of memory.\n", __FUNCTION__);
		return -ENOMEM;
	}

	memset(buf, 0, length * sizeof(__le32));

	/* Issue the request, attempting to read 'size' bytes */
	result = usb_control_msg (serial->dev,
					usb_rcvctrlpipe (serial->dev, 0),
					request, 
					REQTYPE_DEVICE_TO_HOST, 
					0x0000,
					port_priv->bInterfaceNumber, 
					buf, 
					size, 
					300);

	/* Convert data into an array of integers */
	for (i=0; i<length; i++) data[i] = le32_to_cpu(buf[i]);

	kfree(buf);

	if (result != size) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
		up(&port_priv->controlPipeMutex);
#else
		mutex_unlock(&port_priv->controlPipeMutex);
#endif
		DEV_ERR(&port->dev,"%s - get_config nable to send config request, "
				"request=0x%x size=%d result=%d\n",
				__FUNCTION__, request, size, result);
		return -EPROTO;
	}

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	up(&port_priv->controlPipeMutex);
#else
	mutex_unlock(&port_priv->controlPipeMutex);
#endif
	return 0;
}


/*
 * cp210x_set_config
 * Writes to the SILABS configuration registers
 * Values less than 16 bits wide are sent directly
 * 'size' is specified in bytes.
 */
static int cp210x_set_config(struct usb_serial_port* port, u8 request,
		unsigned int *data, int size)
{
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	struct usb_serial *serial = port->serial;

	__le32 *buf;

	int result, i, length;

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	down(&port_priv->controlPipeMutex);
	//if (down_interruptible(&port_priv->controlPipeMutex))
	//	return -ERESTARTSYS;
#else
	mutex_lock(&port_priv->controlPipeMutex);
#endif
				
	if (size == 0) {
		result = usb_control_msg (
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
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
			up(&port_priv->controlPipeMutex);
#else
			mutex_unlock(&port_priv->controlPipeMutex);
#endif
			
			DEV_ERR(&port->dev,"%s - set_config unable to send request, "
				"request=0x%x size=%d result=%d data=%d\n",
				__FUNCTION__, request, size, result, data[0]);
			return -EPROTO;

		} 
	}
	else {
		/* Number of integers required to contain the array */
		length = (((size - 1) | 3) + 1)/4;

#ifdef LINUX26
		buf = kmalloc(length * sizeof(__le32), GFP_KERNEL);
#else
		buf = kmalloc(length * sizeof(u32), GFP_KERNEL);
#endif

		if (!buf) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
			up(&port_priv->controlPipeMutex);
#else
			mutex_unlock(&port_priv->controlPipeMutex);
#endif
			
			DEV_ERR(&port->dev,"%s - out of memory.\n", __FUNCTION__);
			return -ENOMEM;
		}

		/* Array of integers into bytes */
		for (i = 0; i < length; i++)
			buf[i] = cpu_to_le32(data[i]);

		result = usb_control_msg (
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
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
			up(&port_priv->controlPipeMutex);
#else
			mutex_unlock(&port_priv->controlPipeMutex);
#endif
			
			DEV_ERR(&port->dev,"%s - set_config unable to send request, "
				"request=0x%x size=%d result=%d\n",
				__FUNCTION__, request, size, result);
			return -EPROTO;
		}
	}

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	up(&port_priv->controlPipeMutex);
#else
	mutex_unlock(&port_priv->controlPipeMutex);
#endif
			
	return 0;
}


/*
 * cp210x_set_config_single
 * Convenience function for calling cp210x_set_config on single data values
 * without requiring an integer pointer
 */
static inline int cp210x_set_config_single(struct usb_serial_port* port,
		u8 request, unsigned int data)
{
	return cp210x_set_config(port, request, &data, 0);
}

/* get the tty_struct if valid port */
inline struct tty_struct *get_tty_port(struct usb_serial_port * usb_port)
{
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29))
    if (usb_port && (0 != usb_port->port.tty))
		return usb_port->port.tty;
    return 0;
#else
    if (usb_port && (0 != usb_port->tty))
		return usb_port->tty;
    return 0;
#endif
}

int silabs_cp210x_open (struct usb_serial_port *port, struct file *filp)
{
	struct usb_serial				*serial;
	struct cp210x_serial_private	*serial_priv;
	struct cp210x_port_private		*port_priv;

#ifdef LINUX26
#else
	struct usb_interface_descriptor		*iface_desc;
#endif

	int result = 0;
	int timeout = 0;
	int open_retry_cnt = 5;
	char *throttled;
	char *throttle_req;

#ifdef LINUX26	
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,13))
	int *write_urb_busy;
#else
	char *write_urb_busy;
#endif

#else	
	char *write_urb_busy;

	if (port_paranoia_check (port, __FUNCTION__)) {
		DEV_ERR(&port->dev,
			"%s - port %d port_paranoia_check failed\n",
			__FUNCTION__,
			port->number);
		return -ENODEV;
	}
#endif	

	port_priv = usb_get_serial_port_data(port);

	if (port_priv == NULL) {
		DEV_ERR(&port->dev,
			"%s - port %d port_priv == NULL\n",
			__FUNCTION__,
			port->number);
		return -ENODEV;
	}

	serial = port->serial;

	serial_priv = usb_get_serial_data(serial);
	
	if (serial_priv == NULL) {
		DEV_ERR(&port->dev,
			"%s - port %d serial_priv == NULL\n",
			__FUNCTION__,
			port->number);
		return -ENODEV;
	}

#ifdef LINUX26
	port_priv->bInterfaceNumber = serial->interface->cur_altsetting->desc.bInterfaceNumber;
#else
	iface_desc = &serial->interface->altsetting[0];
	port_priv->bInterfaceNumber = iface_desc->bInterfaceNumber;
#endif
	
#ifdef LINUX26
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,13))
	write_urb_busy = &port->write_urb_busy;
#else
	write_urb_busy = &port_priv->write_busy;
#endif

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,21))
	throttled = &port->throttled;
	throttle_req = &port->throttle_req;
#else
	throttled = &port_priv->throttled;
	throttle_req = &port_priv->throttle_req;
#endif	
#else		
	write_urb_busy = &port_priv->write_busy;
	throttled = &port_priv->throttled;
	throttle_req = &port_priv->throttle_req;
#endif	
		
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#else
//	if (mutex_lock_interruptible(&port_priv->controlPipeMutex)) {
//		printk("\n\ncp210x open -ERESTARTSYS\n\n");
//		return -ERESTARTSYS;
//	}
#endif
	 
	dbg("%s - Opening port %d", __FUNCTION__, port->number);
	printk("\n\ncp210x openining port %d\n\n", port->number);
	
	usb_clear_halt (serial->dev, port->write_urb->pipe);

	usb_clear_halt (serial->dev, port->read_urb->pipe);

	/* force low_latency on so that our tty_push actually forces the data through, 
	   otherwise it is scheduled, and with high data rates (like with OHCI) data
	   can get lost. */
	if (get_tty_port(port))
		get_tty_port(port)->low_latency = 1;

	if (serial->num_bulk_in) {
		port_priv->bulk_in_buffer = port->bulk_in_buffer;
		port_priv->bulk_in_endpoint = port->bulk_in_endpointAddress;
		port_priv->read_urb = port->read_urb;

		port_priv->bulk_out_endpoint = port->bulk_out_endpointAddress;

		/* Start reading from the device */
#ifdef LINUX26
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,18))
		usb_fill_bulk_urb (port->read_urb,
					serial->dev,
					usb_rcvbulkpipe(serial->dev,
						port->bulk_in_endpointAddress),
					port->read_urb->transfer_buffer,
					port->read_urb->transfer_buffer_length,
					silabs_cp210x_read_bulk_callback_wrapper,
					port);
#else
		usb_fill_bulk_urb (port->read_urb,
					serial->dev,
					usb_rcvbulkpipe(serial->dev,
						port->bulk_in_endpointAddress),
					port->read_urb->transfer_buffer,
					port->read_urb->transfer_buffer_length,
					silabs_cp210x_read_bulk_callback,
					port);
#endif					

		port_priv->read_urb->dev = serial_priv->serial->dev;
			
		result = usb_submit_urb(port_priv->read_urb, GFP_KERNEL);

#else
		FILL_BULK_URB(port->read_urb,
				serial->dev,
				usb_rcvbulkpipe(serial->dev,
					port->bulk_in_endpointAddress),
				port->bulk_in_buffer,
				port->read_urb->transfer_buffer_length,
				silabs_cp210x_read_bulk_callback,
				port);

		port_priv->read_urb->dev = serial_priv->serial->dev;
			
		result = usb_submit_urb(port_priv->read_urb);

#endif

		if (result)
		{
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#else
//			mutex_unlock(&port_priv->controlPipeMutex);
#endif			
			DEV_ERR(&port->dev,
				"%s - failed resubmitting read urb, error %d on port %d\n",
				__FUNCTION__,
				result,
				port->number);
			return result;
		}
	}

	/* initialize our wait queues */
	init_waitqueue_head (&port_priv->wait_open);
	init_waitqueue_head (&port_priv->wait_control);
	init_waitqueue_head (&port_priv->delta_msr_wait);
	init_waitqueue_head (&port_priv->wait_command);

	/* initialize our icount structure */
	memset (&(port_priv->icount), 0x00, sizeof(port_priv->icount));
	
	/* initialize our port settings */
	port_priv->txCredits		= 0;		/* Can't send any data yet */
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
					
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#else
//		mutex_unlock(&port_priv->controlPipeMutex);
#endif			
		DEV_ERR(&port->dev,
			"%s - Unable to enable UART on port %d\n",
			__FUNCTION__,
			port->number);
		return -EPROTO;
	}

	cp210x_get_serialstat(port);
	
	/* now wait for the port to be completly opened */
	for ( ; open_retry_cnt && port_priv->open == FALSE; open_retry_cnt--) {
		timeout = 5 * TIMEOUT_100ms;	// 500 milliseconds
		while (timeout && port_priv->openPending == TRUE) {
			timeout = interruptible_sleep_on_timeout (
						&port_priv->wait_open,
						timeout);
		}
		cp210x_get_serialstat(port);
	}

	if (port_priv->open == FALSE) {
		/* open timed out */
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#else
//		mutex_unlock(&port_priv->controlPipeMutex);
#endif			
		DEV_ERR(&port->dev,
			"%s - Open timed out on port %d\n",
			__FUNCTION__,
			port->number);
		port_priv->openPending = FALSE;
		return -ENODEV;
	}

	port_priv->lsr = (__u8) port_priv->serialstat.ulErrors;

	cp210x_get_commprops(port);

	/* Use N_TTY_BUF_SIZE (4096) or PAGE_SIZE */
	port_priv->maxTxCredits = min ((port_priv->commprops.ulCurrentTxQueue),
						(unsigned int) N_TTY_BUF_SIZE);

	/*
	 * adjust size of circular buffer - no reason to do this since our
	 * buffering works now, it would just need retesting "Untie" the circular
	 * buffer code from tx queue - same here, no need to change something
	 * that has been tested
	 */
	 
	/* create the circular_buf_txfifo */
	port_priv->circular_buf_txfifo.head	= 0;
	port_priv->circular_buf_txfifo.tail	= 0;
	port_priv->circular_buf_txfifo.count	= 0;
	port_priv->circular_buf_txfifo.size	= port_priv->maxTxCredits;
	port_priv->circular_buf_txfifo.fifo	=
				kmalloc (port_priv->maxTxCredits, GFP_KERNEL);


	if (!port_priv->circular_buf_txfifo.fifo) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#else
//		mutex_unlock(&port_priv->controlPipeMutex);
#endif			
		DEV_ERR(&port->dev,
			"%s - no more kernel memory circular_buf_txfifo.fifo...\n",
			__FUNCTION__);
		silabs_cp210x_close (port, filp);
		return -ENOMEM;
	}
	
#ifdef LINUX26
	port_priv->write_urb = usb_alloc_urb(0, GFP_ATOMIC);
	
#else
	port_priv->write_urb = usb_alloc_urb(0);
	
#endif
	if (!port_priv->write_urb) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#else
//		mutex_unlock(&port_priv->controlPipeMutex);
#endif			
		DEV_ERR(&port->dev,
			"%s - no more kernel memory write_urb...\n",
			__FUNCTION__);
		silabs_cp210x_close(port, filp);
		return -ENOMEM;
	}

	if (get_tty_port(port)) {
		/* Save off the original port termios */
		cp210x_get_termios (port);
		
		/* Configure the termios structure */
		silabs_cp210x_set_termios (port, NULL);	

		/* Set the DTR and RTS pins low */
		//silabs_cp210x_tiocmset(port, NULL, TIOCM_DTR | TIOCM_RTS, 0);

	}


	port_priv->run_cp210x_control_thread = TRUE;
	
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
	init_completion(&port_priv->portThreadComplete);
#endif
	
	cp210x_start_control_thread(port);

	port_priv->txCredits = port_priv->maxTxCredits;		// allow writes

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
#else
//	mutex_unlock(&port_priv->controlPipeMutex);
#endif			

	return result;
}




static void cp210x_close_port (struct usb_serial_port *port)
{
	struct usb_serial *serial = port->serial;

	struct cp210x_port_private	*port_priv;
	
	port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (serial != NULL && serial->dev) {
		/* shutdown any bulk reads that might be going on */
		if (serial->num_bulk_out) {
			USB_KILL_URB(port->write_urb);
			if (port_priv->write_urb)
				USB_KILL_URB(port_priv->write_urb);
		}
		if (serial->num_bulk_in) {
			port->read_urb->transfer_flags &= ~USB_ASYNC_UNLINK;
			USB_KILL_URB(port->read_urb);
		}
	}

	kfree (usb_get_serial_port_data(port));
	usb_set_serial_port_data(port, NULL);
}




static void cp210x_cleanup_port (struct usb_serial_port *port)
{
	struct usb_serial *serial = port->serial;

	struct cp210x_port_private	*port_priv;
	
	port_priv = usb_get_serial_port_data(port);


	dbg("%s - port %d", __FUNCTION__, port->number);

	if (serial != NULL && serial->dev) {
		/* shutdown any bulk reads that might be going on */
		if (serial->num_bulk_out) {
			USB_KILL_URB(port->write_urb);
			if (port_priv->write_urb)
				USB_KILL_URB(port_priv->write_urb);
		}
		if (serial->num_bulk_in) {
			port->read_urb->transfer_flags &= ~USB_ASYNC_UNLINK;
			USB_KILL_URB(port->read_urb);
		}
	}
}




void silabs_cp210x_close (struct usb_serial_port *port, struct file * filp)
{
	struct usb_serial			*serial;
	struct cp210x_serial_private		*serial_priv;
	struct cp210x_port_private		*port_priv;
	unsigned int c_cflag;
	unsigned long flags;
	unsigned int modem_ctl[4];

#ifdef LINUX26

	serial = port->serial;

#else
	
	if (port_paranoia_check (port, __FUNCTION__))
		return;

	serial = get_usb_serial (port, __FUNCTION__);
#endif
	
	if (!serial)
		return;
		
	serial_priv = usb_get_serial_data(serial);
	port_priv = usb_get_serial_port_data(port);
	
	if (serial_priv == NULL)
		return;
		
	if (port_priv == NULL)
		return;
    
	dbg("%s - port %d", __FUNCTION__, port->number);
	
	port_priv->run_cp210x_control_thread = FALSE;
	
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
	wait_for_completion(&port_priv->portThreadComplete);
#else
	kthread_stop(port_priv->cp210x_task);
#endif
	
	if (serial->dev) {
		if (get_tty_port(port)) {
			c_cflag = get_tty_port(port)->termios->c_cflag;
			if (c_cflag & HUPCL) {
				/* drop DTR and RTS */
				spin_lock_irqsave(&port_priv->portLock, flags);
				port_priv->line_control = 0;
				
				spin_unlock_irqrestore (&port_priv->portLock,
								flags);
				
				//set_control_lines (port->serial->dev, 0);
				
				cp210x_get_config(port,
						SILABSER_GET_FLOW_REQUEST_CODE,
						modem_ctl,
						16);
				
				dbg("%s - read modem controls = 0x%.4x 0x%.4x 0x%.4x 0x%.4x",
						__FUNCTION__,
						modem_ctl[0],
						modem_ctl[1],
						modem_ctl[2],
						modem_ctl[3]);

				/* Turn everything off */
				modem_ctl[0] &= CtrlHandshake_Reserved_Mask;
				modem_ctl[1] &= FlowReplace_Reserved_Mask;
				
				dbg("%s - write modem controls = 0x%.4x 0x%.4x 0x%.4x 0x%.4x",
						__FUNCTION__,
						modem_ctl[0],
						modem_ctl[1],
						modem_ctl[2],
						modem_ctl[3]);

				cp210x_set_config(port,
						SILABSER_SET_FLOW_REQUEST_CODE,
						modem_ctl,
						16);
			}
		}

		/* shutdown our urbs */
		dbg("%s - shutting down urbs", __FUNCTION__);
		cp210x_cleanup_port(port);
		
		port_priv->open = FALSE;
	}
	
	cp210x_stop_control_thread(port);
	
	cp210x_set_config_single(port,
				SILABSER_IFC_ENABLE_REQUEST_CODE,
				UART_DISABLE);

	if (port_priv->write_urb) {
		usb_free_urb (port_priv->write_urb);
		port_priv->write_urb = 0;
	}
	
	if (port_priv->circular_buf_txfifo.fifo)
		kfree(port_priv->circular_buf_txfifo.fifo);
}




/*
 * cp210x_get_termios
 * Reads the baud rate, data bits, parity, stop bits and flow control mode
 * from the device, corrects any unsupported values, and configures the
 * termios structure to reflect the state of the device
 */
static void cp210x_get_termios (struct usb_serial_port *port)
{
	unsigned int cflag, iflag, modem_ctl[4];
	int baud;
	int bits;

	unsigned long flags;

	struct cp210x_port_private		*port_priv;

	dbg("%s - port %d", __FUNCTION__, port->number);

	port_priv = usb_get_serial_port_data(port);

	if ((!get_tty_port(port)) || (!get_tty_port(port)->termios)) {
		dbg("%s - no tty structures", __FUNCTION__);
		return;
	}

	cflag = 0;
	iflag = 0;

	//cp210x_get_config(port, SILABSER_GET_BAUDDIV_REQUEST_CODE, &baud, 2);
	cp210x_get_config(port, SILABSER_GET_BAUDRATE, &baud, 4);

	/* Convert to baudrate */
	//if (baud)
		//baud = BAUD_RATE_GEN_FREQ / baud;

	dbg("%s - baud rate = %d", __FUNCTION__, baud);
	switch (baud) {
		/*
		 * The baud rates which are commented out below
		 * appear to be supported by the device
		 * but are non-standard
		 */
		case 0:			cflag |= B0;		break;
		case 50:		cflag |= B50;		break;
		case 75:		cflag |= B75;		break;
		case 110:		cflag |= B110;		break;
		case 134:		cflag |= B134;		break;
		case 150:		cflag |= B150;		break;
		case 200:		cflag |= B200;		break;
		case 300:		cflag |= B300;		break;
		case 600:		cflag |= B600;		break;
		case 1200:		cflag |= B1200;		break;
		case 1800:		cflag |= B1800;		break;
		case 2400:		cflag |= B2400;		break;
		case 4800:		cflag |= B4800;		break;
		case 9600:		cflag |= B9600;		break;
		case 19200:		cflag |= B19200;	break;
		case 38400:		cflag |= B38400;	break;
		case 57600:		cflag |= B57600;	break;
		case 115200:		cflag |= B115200;	break;
		case 230400:		cflag |= B230400;	break;
		case 460800:		cflag |= B460800;	break;
		case 500000:		cflag |= B500000;	break;
		case 576000:		cflag |= B500000;	break;
		case 921600:		cflag |= B921600;	break;
		case 1000000:		cflag |= B1000000;	break;
		//case 1152000:		cflag |= B1152000;	break;
		//case 1500000:		cflag |= B1500000;	break;
		//case 2000000:		cflag |= B2000000;	break;
		//case 2500000:		cflag |= B2500000;	break;
		//case 3000000:		cflag |= B3000000;	break;
		//case 3500000:		cflag |= B3500000;	break;
		//case 4000000:		cflag |= B4000000;	break;
		default:
			dbg("%s - Baud rate is not supported, "
					"using 9600 baud", __FUNCTION__);
			cflag |= B9600;
			//cp210x_set_config_single(port,
					//SILABSER_SET_BAUDDIV_REQUEST_CODE,
					//(BAUD_RATE_GEN_FREQ/9600));
					
			baud = 9600;
			
			cp210x_set_config(port, SILABSER_SET_BAUDRATE, &baud, 4);
					
			break;
	}

	cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE, &bits, 2);
	switch(bits & BITS_DATA_MASK) {
		case BITS_DATA_5:
			dbg("%s - data bits = 5", __FUNCTION__);
			cflag |= CS5;
			break;
		case BITS_DATA_6:
			dbg("%s - data bits = 6", __FUNCTION__);
			cflag |= CS6;
			break;
		case BITS_DATA_7:
			dbg("%s - data bits = 7", __FUNCTION__);
			cflag |= CS7;
			break;
		case BITS_DATA_8:
			dbg("%s - data bits = 8", __FUNCTION__);
			cflag |= CS8;
			break;
		case BITS_DATA_9:
			dbg("%s - data bits = 9 (not supported, "
					"using 8 data bits)", __FUNCTION__);
			cflag |= CS8;
			bits &= ~BITS_DATA_MASK;
			bits |= BITS_DATA_8;
			cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits);
						
			break;
		default:
			dbg("%s - Unknown number of data bits, "
					"using 8", __FUNCTION__);
			cflag |= CS8;
			bits &= ~BITS_DATA_MASK;
			bits |= BITS_DATA_8;
			cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits);
						
			break;
	}

	switch(bits & BITS_PARITY_MASK) {
		case BITS_PARITY_NONE:
			dbg("%s - parity = NONE", __FUNCTION__);
			cflag &= ~PARENB;
			break;
		case BITS_PARITY_ODD:
			dbg("%s - parity = ODD", __FUNCTION__);
			cflag |= (PARENB|PARODD);
			break;
		case BITS_PARITY_EVEN:
			dbg("%s - parity = EVEN", __FUNCTION__);
			cflag &= ~PARODD;
			cflag |= PARENB;
			break;
		case BITS_PARITY_MARK:
			dbg("%s - parity = MARK (not supported, "
					"disabling parity)", __FUNCTION__);
			cflag &= ~PARENB;
			bits &= ~BITS_PARITY_MASK;
			cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits);
						
			break;
		case BITS_PARITY_SPACE:
			dbg("%s - parity = SPACE (not supported, "
					"disabling parity)", __FUNCTION__);
			cflag &= ~PARENB;
			bits &= ~BITS_PARITY_MASK;
			cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits);
						
			break;
		default:
			dbg("%s - Unknown parity mode, "
					"disabling parity", __FUNCTION__);
			cflag &= ~PARENB;
			bits &= ~BITS_PARITY_MASK;
			cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits);
						
			break;
	}

	switch(bits & BITS_STOP_MASK) {
		case BITS_STOP_1:
			dbg("%s - stop bits = 1", __FUNCTION__);
			break;
		case BITS_STOP_1_5:
			dbg("%s - stop bits = 1.5 (not supported, "
					"using 1 stop bit)", __FUNCTION__);
			bits &= ~BITS_STOP_MASK;
			cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits);
						
			break;
		case BITS_STOP_2:
			dbg("%s - stop bits = 2", __FUNCTION__);
			cflag |= CSTOPB;
			break;
		default:
			dbg("%s - Unknown number of stop bits, "
					"using 1 stop bit", __FUNCTION__);
			bits &= ~BITS_STOP_MASK;
			cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits);
						
			break;
	}

	cp210x_get_config(port, SILABSER_GET_FLOW_REQUEST_CODE, modem_ctl, 16);

	if (modem_ctl[0] & CtrlHandshake_CTS_Handshake_Mask) {
		dbg("%s - flow control = CRTSCTS", __FUNCTION__);
		cflag |= CRTSCTS;
	}
	else if ((modem_ctl[1] & FlowReplace_Auto_Transmit_Mask) ||
				modem_ctl[1] &
				FlowReplace_Auto_Receive_Mask) {
					
		dbg("%s - flow control = XONXOFF", __FUNCTION__);
		
		if (modem_ctl[1] & FlowReplace_Auto_Transmit_Mask)
			iflag |= IXOFF;
			
		if (modem_ctl[1] & FlowReplace_Auto_Receive_Mask)
			iflag |= IXON;
			
	}
	else {
		dbg("%s - flow control = NONE", __FUNCTION__);
		cflag &= ~CRTSCTS;
		iflag = ~(IXOFF | IXON);
	}

	spin_lock_irqsave(&port_priv->portLock, flags);
	if (port_priv->termios_initialized == FALSE) {
		port_priv->orig_termios.c_iflag = iflag;
		port_priv->orig_termios.c_oflag = get_tty_port(port)->termios->c_oflag;
		port_priv->orig_termios.c_cflag = cflag;
		port_priv->orig_termios.c_lflag = get_tty_port(port)->termios->c_lflag;
		port_priv->orig_termios.c_line = get_tty_port(port)->termios->c_line;
		//port_priv->orig_termios.c_cc =;
	}
	else {
		port_priv->curr_termios.c_iflag = iflag;
		port_priv->curr_termios.c_oflag = get_tty_port(port)->termios->c_oflag;
		port_priv->curr_termios.c_cflag = cflag;
		port_priv->curr_termios.c_lflag = get_tty_port(port)->termios->c_lflag;
		port_priv->curr_termios.c_line = get_tty_port(port)->termios->c_line;
		//port_priv->curr_termios.c_cc =;
	}
	spin_unlock_irqrestore(&port_priv->portLock, flags);

}




static void silabs_cp210x_set_termios (struct usb_serial_port *port,
						struct ktermios *old_termios)
{
	int baud=0;
	unsigned int cflag, old_cflag = 0, old_iflag = 0;
	unsigned int modem_ctl[4];
	unsigned int iflag;
	unsigned int bits;

	unsigned long flags;

	unsigned char vstop;
	unsigned char vstart;
	unsigned char set_chars[6];

	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d, initialized %d",
		__FUNCTION__,
		port->number,
		port_priv->termios_initialized);

	if ((!get_tty_port(port)) || (!get_tty_port(port)->termios)) {
		dbg("%s - no tty structures", __FUNCTION__);
		return;
	}

	cflag = get_tty_port(port)->termios->c_cflag;
	iflag = get_tty_port(port)->termios->c_iflag;

	/* Check that they really want us to change something */
	if (old_termios) {
		if ((cflag == old_termios->c_cflag) &&
				(SILABS_RELEVANT_IFLAG(get_tty_port(port)->termios->c_iflag)
				== SILABS_RELEVANT_IFLAG(old_termios->c_iflag))) {

			dbg("%s - nothing to change...", __FUNCTION__);
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
			case B0:		baud = 0;		break;
			case B50:		baud = 50;		break;
			case B75:		baud = 75;		break;
			case B110:		baud = 110;		break;
			case B134:		baud = 134;		break;
			case B150:		baud = 150;		break;
			case B200:		baud = 200;		break;
			case B300:		baud = 300;		break;
			case B600:		baud = 600;		break;
			case B1200:		baud = 1200;		break;
			case B1800:		baud = 1800;		break;
			case B2400:		baud = 2400;		break;
			case B4800:		baud = 4800;		break;
			case B9600:		baud = 9600;		break;
			case B19200:		baud = 19200;		break;
			case B38400:		baud = 38400;		break;
			case B57600:		baud = 57600;		break;
			case B115200:		baud = 115200;		break;
			case B230400:		baud = 230400;		break;
			case B460800:		baud = 460800;		break;
			case B921600:		baud = 921600;		break;
			case B1000000:		baud = 1000000;		break;
			//case B1152000:		baud = 1152000;		break;
			//case B1500000:		baud = 1500000;		break;
			//case B2000000:		baud = 2000000;		break;
			//case B2500000:		baud = 2500000;		break;
			//case B3000000:		baud = 3000000;		break;
			//case B4000000:		baud = 4000000;		break;
			default:
				DEV_ERR(&port->dev, "silabs driver does not "
					"support the baudrate requested "
					"using 9600 baud\n");
				baud = 9600;
				break;
		}

		dbg("%s - Setting baud rate to %d baud", __FUNCTION__, baud);
//		if (cp210x_set_config_single(port,
//						SILABSER_SET_BAUDDIV_REQUEST_CODE,
//						(BAUD_RATE_GEN_FREQ / baud)))
						
		if (cp210x_set_config(port, SILABSER_SET_BAUDRATE, &baud, 4))
			DEV_ERR(&port->dev,
				"Baud rate requested not supported by device\n");
	}

	/* If the number of data bits is to be updated */
	if ((cflag & CSIZE) != (old_cflag & CSIZE)) {
		cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE, &bits, 2);
		bits &= ~BITS_DATA_MASK;
		switch (cflag & CSIZE) {
			case CS5:
				bits |= BITS_DATA_5;
				dbg("%s - data bits = 5", __FUNCTION__);
				break;
			case CS6:
				bits |= BITS_DATA_6;
				dbg("%s - data bits = 6", __FUNCTION__);
				break;
			case CS7:
				bits |= BITS_DATA_7;
				dbg("%s - data bits = 7", __FUNCTION__);
				break;
			case CS8:
				bits |= BITS_DATA_8;
				dbg("%s - data bits = 8", __FUNCTION__);
				break;
			/*case CS9:
				bits |= BITS_DATA_9;
				dbg("%s - data bits = 9", __FUNCTION__);
				break;*/
			default:
				DEV_ERR(&port->dev, "silabs driver does not "
					"support the number of bits requested,"
					" using 8 bit mode\n");
				bits |= BITS_DATA_8;
				break;
		}

		printk("CP210X - silabs_cp210x_set_termios databits:                            %x\n", bits);
		dbg("%s - Setting data bits to %d bits", __FUNCTION__, bits);
		if (cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits))
						
			DEV_ERR(&port->dev,
				"Number of data bits requested not supported by device\n");
	}

	if ((cflag & (PARENB|PARODD)) != (old_cflag & (PARENB|PARODD))) {
		cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE, &bits, 2);
		bits &= ~BITS_PARITY_MASK;
		if (cflag & PARENB) {
			if (cflag & PARODD) {
				bits |= BITS_PARITY_ODD;
				dbg("%s - parity = ODD", __FUNCTION__);
			} else {
				bits |= BITS_PARITY_EVEN;
				dbg("%s - parity = EVEN", __FUNCTION__);
			}
		} 

		dbg("%s - Setting parity to %d parity", __FUNCTION__, bits);
		if (cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits))
						
			DEV_ERR(&port->dev,
				"Parity mode not supported by device\n");
	}

	if ((cflag & CSTOPB) != (old_cflag & CSTOPB)) {
		cp210x_get_config(port, SILABSER_GET_LINE_CTL_REQUEST_CODE, &bits, 2);
		bits &= ~BITS_STOP_MASK;
		if (cflag & CSTOPB) {
			bits |= BITS_STOP_2;
			dbg("%s - stop bits = 2", __FUNCTION__);
		} else {
			bits |= BITS_STOP_1;
			dbg("%s - stop bits = 1", __FUNCTION__);
		}

		dbg("%s - Setting stop bits to %d stop bits", __FUNCTION__, bits);
		if (cp210x_set_config_single(port,
						SILABSER_SET_LINE_CTL_REQUEST_CODE,
						bits))
						
			DEV_ERR(&port->dev,
			"Number of stop bits requested not supported by device\n");
	}


	if (((cflag & CRTSCTS) != (old_cflag & CRTSCTS)) ||
		((iflag & IXOFF) != (old_iflag & IXOFF)) ||
		((iflag & IXON) != (old_iflag & IXON))) {

		/*
		 * Flow Control has changed
		*/
		cp210x_get_config(port, SILABSER_GET_FLOW_REQUEST_CODE, modem_ctl, 16);
		dbg("%s - read modem controls = 0x%.4x 0x%.4x 0x%.4x 0x%.4x",
				__FUNCTION__, modem_ctl[0], modem_ctl[1],
				modem_ctl[2], modem_ctl[3]);

		modem_ctl[0] &= CtrlHandshake_Reserved_Mask;
		modem_ctl[1] &= (FlowReplace_Reserved_Mask |
					FlowReplace_Error_Char_Mask |
					//FlowReplace_Serial_NULL_Striping_Mask |
					FlowReplace_Break_Char_Mask);
				
		//modem_ctl[1] |= FlowReplace_Serial_NULL_Striping_Mask;
				

		if (cflag & CRTSCTS) {
			modem_ctl[0] |= (CtrlHandshake_CTS_Handshake_Mask |
						CtrlHandshake_DTR_Active);
						
			modem_ctl[1] |= FlowReplace_RTS_Receive_Flow;
			
			dbg("%s - flow control = CRTSCTS", __FUNCTION__);
			
		}
		else if ((iflag & IXOFF) || (iflag & IXON)) {
			vstart=get_tty_port(port)->termios->c_cc[VSTART];
			vstop=get_tty_port(port)->termios->c_cc[VSTOP];
			
			cp210x_get_config_bytes(port,
						SILABSER_GET_CHARS_REQUEST_CODE,
						set_chars,
						6);
		
			set_chars[4] = vstart;
			set_chars[5] = vstop;

			cp210x_set_config(port,
					SILABSER_SET_CHARS_REQUEST_CODE,
					(uint*) set_chars,
					6);
			
			if (iflag & IXOFF) {
				modem_ctl[1] |= FlowReplace_Auto_Transmit_Mask;
			}
			if (iflag & IXON) {
				modem_ctl[1] |= FlowReplace_Auto_Receive_Mask;
			}
			
			dbg("%s - flow control = XONXOFF", __FUNCTION__);
			
		}
		else {
			modem_ctl[0] |= CtrlHandshake_DTR_Active;
			modem_ctl[1] |= FlowReplace_RTS_Statically_Active;
			dbg("%s - flow control = NONE", __FUNCTION__);
		}

		dbg("%s - write modem controls = 0x%.4x 0x%.4x 0x%.4x 0x%.4x",
				__FUNCTION__, modem_ctl[0], modem_ctl[1],
				modem_ctl[2], modem_ctl[3]);
		cp210x_set_config(port,
				SILABSER_SET_FLOW_REQUEST_CODE,
				modem_ctl,
				16);
		
	}

	/* Save off the new port termios */
	cp210x_get_termios (port);
		
}





static int silabs_cp210x_tiocmset (struct usb_serial_port *port,
					struct file *file,
					unsigned int set,
					unsigned int clear)
{
	unsigned long flags;

	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	unsigned int mcr;
	unsigned int line_control;

	dbg("%s - port %d", __FUNCTION__, port->number);

	spin_lock_irqsave (&port_priv->portLock, flags);
	
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

	spin_unlock_irqrestore (&port_priv->portLock, flags);

	dbg("%s - control = 0x%.4x", __FUNCTION__, line_control);

	/* set the new MCR value in the device */
	return cp210x_set_config_single(port,
					SILABSER_SET_MHS_REQUEST_CODE,
					line_control);

	return 0;
}



static int silabs_cp210x_tiocmget (struct usb_serial_port *port, struct file *file)
{
	unsigned long flags;

	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	unsigned int msr;
	unsigned int mcr;
	unsigned int line_control;
	
	int result = 0;

	dbg("%s - port %d", __FUNCTION__, port->number);

	cp210x_get_config(port, SILABSER_GET_MDMSTS_REQUEST_CODE, &line_control, 1);

	mcr = line_control & MCR_ALL;
	msr = line_control & MSR_ALL;

	result = ((mcr & MCR_DTR) ? TIOCM_DTR : 0)
		|((mcr & MCR_RTS) ? TIOCM_RTS : 0)
		|((msr & MSR_CTS) ? TIOCM_CTS : 0)
		|((msr & MSR_DSR) ? TIOCM_DSR : 0)
		|((msr & MSR_RING)? TIOCM_RI  : 0)
		|((msr & MSR_DCD) ? TIOCM_CD  : 0);


	spin_lock_irqsave (&port_priv->portLock, flags);
	
	port_priv->mcr = mcr;
	port_priv->mcr = msr;
	port_priv->line_control = line_control;

	spin_unlock_irqrestore (&port_priv->portLock, flags);

	dbg("%s - control = 0x%.2x", __FUNCTION__, line_control);

	return result;
}





static void silabs_cp210x_break_ctl (struct usb_serial_port *port, int break_state)
{
	int state;

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (break_state == -1)
		state = BREAK_ON;
	else
		state = BREAK_OFF;
		
	dbg("%s - turning break %s", __FUNCTION__, state==BREAK_OFF ? "off" : "on");

	cp210x_set_config_single(port, SILABSER_SET_BREAK_REQUEST_CODE, state);
}




/*
 * cp2101_ctlmsg
 * A generic usb control message interface.
 * Returns the actual size of the data read or written within the message, 0
 * if no data were read or written, or a negative value to indicate an error.
 */
static int cp2101_ctlmsg(struct usb_serial_port* port, u8 request,
		u8 requestype, u16 value, u16 index, void* data, u16 size)
{
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	struct usb_device *dev = port->serial->dev;
	u8 *tbuf;
	int ret;

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	down(&port_priv->controlPipeMutex);
	//if (down_interruptible(&port_priv->controlPipeMutex))
	//	return -ERESTARTSYS;
#else
	mutex_lock(&port_priv->controlPipeMutex);
#endif
				
	if (!(tbuf = kmalloc(size, GFP_KERNEL))) {
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
		up(&port_priv->controlPipeMutex);
#else
		mutex_unlock(&port_priv->controlPipeMutex);
#endif
		return -ENOMEM;
	}

	if (requestype & 0x80) {
		ret = usb_control_msg(dev, usb_rcvctrlpipe(dev, 0), request,
				requestype, value, port_priv->bInterfaceNumber, tbuf, size, 300);
				
		if (ret > 0 && size)
			memcpy(data, tbuf, size);
	} else {
		if (size)
			memcpy(tbuf, data, size);
		
		ret = usb_control_msg(dev, usb_sndctrlpipe(dev, 0), request,
				requestype, value, port_priv->bInterfaceNumber, tbuf, size, 300);
	}
	kfree(tbuf);

#ifdef LINUX26
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
#endif
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
	up(&port_priv->controlPipeMutex);
#else
	mutex_unlock(&port_priv->controlPipeMutex);
#endif
	return ret;
}




static int cp210x_get_partnum (struct usb_serial_port *port)
{
	int ret = -1;
	//struct usb_endpoint_descriptor		endpointDescriptor;
	
	u8 addr;
	
	struct usb_serial *serial = port->serial;
	struct cp210x_serial_private *serial_priv	= usb_get_serial_data(serial);
	
	serial_priv->devType = none;

	if (2 == (serial_priv->numberOfPorts = silabs_cp210x_calc_num_ports(serial)))
	{
		serial_priv->devType = cp2105;
	}
	else
	{
		addr = port->bulk_out_endpointAddress & USB_ENDPOINT_NUMBER_MASK;

		if (addr == 0x03 || addr == 0x02) {
			serial_priv->devType = cp2101;
			ret = 0;
		}
		else if (addr == 0x01) {
			
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
				}
				else {
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

	dbg("%s - port %d", __FUNCTION__, port->number);

	/* FIXME: how about REQTYPE_DEVICE_TO_HOST instead of 0xc0? */
	ret = cp2101_ctlmsg(port, 0xff, 0xc0, 0x00c2, 0, gpio, 1);

	dbg("%s - gpio = 0x%.2x (%d)", __FUNCTION__, *gpio, ret);

	return (ret == 1) ? 0 : -1;
}




/* Set all gpio simultaneously */
static int cp210x_gpioset(struct usb_serial_port *port, uint16_t arg)
{
	dbg("%s - port %d, gpio = 0x%.2x", __FUNCTION__, port->number, arg);

    return cp2101_ctlmsg(port, 0xff, 0x40, 0x37e1, arg, 0, 0);
}



static int cp210x_get_serialstat(struct usb_serial_port *port)
{
	int results = SILABS_SUCCESS;
	unsigned char		buffer[19];
	unsigned long flags;
	
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	if ((results = cp210x_get_config_bytes(port,
					SILABSER_GET_COMM_STATUS_REQUEST_CODE,
					buffer,
					19)) == -EPROTO) return -EPROTO;

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
		if (!(port_priv->serialstat.ulErrors & 0x1F) && !(port_priv->serialstat.ulHoldReasons & 0x7F)) {
			port_priv->open = TRUE;
			port_priv->openPending = FALSE; 
		}
		else {
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
	
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

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


static int cp210x_internal_ioctl (struct usb_serial_port *port,
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

	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	struct CommFlow		cp2101_commflow;

	struct usb_serial *serial = port->serial;
	struct cp210x_serial_private *serial_priv	= usb_get_serial_data(serial);
	
	dbg("%s (%d) cmd = 0x%04x", __FUNCTION__, port->number, cmd);

	switch (cmd) {
		
		case IOCTL_EMBED_EVENTS:
			{
				if (copy_from_user(&data,
						(void __user*)arg,
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
					if (!cp210x_gpioget(port, &gpio))
					{
						if (copy_to_user((void __user*)arg,
								&gpio,
								sizeof(__u8)))
							
							return -EFAULT; 
					}
					else
						return -EFAULT;

					return 0;
				}
				else
					return -ENOIOCTLCMD;
			}
			break;

		case IOCTL_GPIOSET:
			{
				if (serial_priv->devType >= cp2103) {

					if (cp210x_gpioset(port, (uint16_t) arg))
						return -EFAULT; 

					return 0;
				}
				else
					return -ENOIOCTLCMD;
			}
			break;

		case IOCTL_PROPGET:
			{
				//cp210x_get_commprops(port);
				
				if (copy_to_user((void __user*)arg,
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

				if (copy_to_user((void __user*)arg,
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

				if (copy_to_user((void __user*)arg,
						modem_ctl,
						4 * sizeof(int)))
						
					return -EFAULT; 

				return 0;
			}
			break;

		case IOCTL_FLOW_CONTROLSET:
			{
				if (copy_from_user(&cp2101_commflow,
							(void __user*)arg,
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

				if (copy_to_user((void __user*)arg,
						set_chars,
						6 * sizeof(unsigned char)))
						
					return -EFAULT; 

				return 0;
			}
			break;

		case IOCTL_SPECIAL_CHARSET:
			{
				if (copy_from_user(set_chars,
							(void __user*)arg,
							6 * sizeof(unsigned char)))
						
						return -EFAULT;
						
				cp210x_set_config(port,
						SILABSER_SET_CHARS_REQUEST_CODE,
						(uint*) set_chars,
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
			dbg("%s not supported = 0x%04x", __FUNCTION__, cmd);
			break;
	}

	return -ENOIOCTLCMD;
}




static int silabs_cp210x_ioctl (struct usb_serial_port *port,
				struct file *file,
				unsigned int cmd,
				unsigned long arg)
{
#ifdef LINUX26
	DEFINE_WAIT(wait);
#endif

	int val = 0;
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);
	struct async_icount		cnow;
	struct async_icount		cprev;

	dbg("%s (%d) cmd = 0x%04x", __FUNCTION__, port->number, cmd);

	switch (cmd) {
		case TIOCMGET:
			{
			int result = silabs_cp210x_tiocmget(port, file);
			if (copy_to_user((void __user*)arg, &result, sizeof(int)))
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
						(void __user*)arg,
						sizeof(int)))
						
					return -EFAULT;
			}

			if(silabs_cp210x_tiocmset(port,
						file,
						cmd==TIOCMBIC?0:val,
							cmd==TIOCMBIC?val:0))
								
				return -EFAULT;
			return 0;
			}
			break;

#ifdef LINUX26		
		case TIOCMIWAIT:
			dbg("%s (%d) TIOCMIWAIT", __FUNCTION__,  port->number);
			cprev = port_priv->icount;
			while (1) {
				prepare_to_wait(&port_priv->delta_msr_wait, &wait, TASK_INTERRUPTIBLE);
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
				    ((arg & TIOCM_CTS) && (cnow.cts != cprev.cts)) ) {
					return 0;
				}
				cprev = cnow;
			}
			/* NOTREACHED */
			break;

#else
		case TIOCMIWAIT:
			dbg("%s (%d) TIOCMIWAIT", __FUNCTION__,  port->number);
			cprev = port_priv->icount;
			while (1) {
				interruptible_sleep_on(&port_priv->delta_msr_wait);
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
				    ((arg & TIOCM_CTS) && (cnow.cts != cprev.cts)) ) {
					return 0;
				}
				cprev = cnow;
			}
			/* NOTREACHED */
			break;

#endif
		case TCFLSH:
			{
			unsigned char flush_value = 0;
			
			if (arg == 0) {
				//flush read
				flush_value = 0x0a;
			}
			else if (arg == 1) {
				//flush write
				flush_value = 0x05;
				port_priv->circular_buf_txfifo.head = 0;
				port_priv->circular_buf_txfifo.tail = 0;
				port_priv->circular_buf_txfifo.count = 0;
			}
			else if (arg == 2) {
				//flush read and write
				flush_value = 0x0f;
				port_priv->circular_buf_txfifo.head = 0;
				port_priv->circular_buf_txfifo.tail = 0;
				port_priv->circular_buf_txfifo.count = 0;
			}
			else {
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



#ifdef LINUX26		
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,23))

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29))
#define PORT_COUNT (port->port.count)
#else
#define PORT_COUNT (port->open_count)
#endif


static int silabs_cp210x_resume	(struct usb_serial *serial)
{
	struct usb_serial_port *port;
	int i, c = 0, r;
    
	for (i = 0; i < serial->num_ports; i++) {
		port = serial->port[i];
		if (PORT_COUNT && port->read_urb) {
			r = usb_submit_urb(port->read_urb, GFP_NOIO);
			if (r < 0)
				c++;
		}
	}
    
	return c ? -EIO : 0;
}


static int silabs_cp210x_suspend (struct usb_serial *serial,
						pm_message_t message)
{
/*	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);
	USB_KILL_URB(port_priv->write_urb);
	return 0;*/
 struct usb_serial_port *port;
	int i ;
    
	for (i = 0; i < serial->num_ports; i++) {
		port = serial->port[i];
		if (PORT_COUNT && port->write_urb) {
			USB_KILL_URB(port->write_urb);
		}
	}
    
	return 0 ;
}

#endif
#endif

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
	struct usb_serial		*serial = port->serial;
	struct cp210x_serial_private	*serial_priv = usb_get_serial_data(serial);
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);
	struct circular_buf_txfifo			*fifo = &port_priv->circular_buf_txfifo;
	struct urb			*urb;
	unsigned char			*buffer;
	
	int		status;
	int		count;
	int		bytesleft;
	int		firsthalf;
	int		secondhalf;

	unsigned long	flags;

	dbg("%s(%d)", __FUNCTION__, port_priv->port->number);

	spin_lock_irqsave(&port_priv->portLock, flags);

	if (port_priv->write_busy ||
	    !port_priv->open      ||
	    (fifo->count == 0)) {
		dbg("%s(%d) EXIT - fifo %d, PendingWrite = %d",
			__FUNCTION__,
			port_priv->port->number,
			fifo->count,
			port_priv->write_busy);
			
		goto exit_send;
	}

	if (port_priv->txCredits < (port_priv->commprops.ulCurrentTxQueue / 4)) {
		dbg("%s(%d) Not enough credit - fifo %d TxCredit %d",
			__FUNCTION__,
			port_priv->port->number,
			fifo->count,
			port_priv->txCredits );
			
		goto exit_send;
	}

	// lock this write
	port_priv->write_busy = TRUE;

	// get a pointer to the write_urb
	urb = port_priv->write_urb;

	/* if this urb had a transfer buffer already (old transfer) free it */
	if (urb->transfer_buffer != NULL) {
		kfree(urb->transfer_buffer);
		urb->transfer_buffer = NULL;
	}

	/* build the data header for the buffer and port that we are about to send out */
	count = fifo->count;
	buffer = kmalloc (count, GFP_ATOMIC);
	if (buffer == NULL) {
		DEV_ERR(&port->dev,
			"%s - no more kernel memory on port %d\n",
			__FUNCTION__,
			port->number);
			
		port_priv->write_busy = FALSE;
		goto exit_send;
	}

	/* now copy our data */
	bytesleft =  fifo->size - fifo->tail;
	firsthalf = min (bytesleft, count);
	memcpy(buffer, &fifo->fifo[fifo->tail], firsthalf);
	fifo->tail  += firsthalf;
	fifo->count -= firsthalf;
	if (fifo->tail == fifo->size) {
		fifo->tail = 0;
	}

	secondhalf = count-firsthalf;
	if (secondhalf) {
		memcpy(&buffer[firsthalf], &fifo->fifo[fifo->tail], secondhalf);
		fifo->tail  += secondhalf;
		fifo->count -= secondhalf;
	}

	if (count) {
#ifdef LINUX26
		usb_serial_debug_data(debug, &port->dev, __FUNCTION__, count, buffer);
#else
		usb_serial_debug_data (__FILE__, __FUNCTION__, count, buffer);
#endif
	}

	/* fill up the urb with all of our data and submit it */
#ifdef LINUX26
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,18))
		usb_fill_bulk_urb (urb,
					serial_priv->serial->dev,
					usb_sndbulkpipe(serial_priv->serial->dev,
						port->bulk_out_endpointAddress),
					buffer,
					count,
					silabs_cp210x_write_bulk_callback_wrapper,
					port);
#else
		usb_fill_bulk_urb (urb,
					serial_priv->serial->dev,
					usb_sndbulkpipe(serial_priv->serial->dev,
						port->bulk_out_endpointAddress),
					buffer,
					count,
					silabs_cp210x_write_bulk_callback,
					port);
#endif

#else
	FILL_BULK_URB (urb,
			serial_priv->serial->dev, 
			usb_sndbulkpipe(serial_priv->serial->dev,
					port_priv->bulk_out_endpoint),
			buffer,
			count,
			silabs_cp210x_write_bulk_callback,
			port);

	/* set the USB_BULK_QUEUE flag so that we can shove a bunch of urbs at once down the pipe */
	urb->transfer_flags |= USB_QUEUE_BULK;

#endif

	urb->dev = serial_priv->serial->dev;
	/* decrement the number of credits we have by the number we just sent */
	port_priv->txCredits -= count;
	port_priv->icount.tx += count;

#ifdef LINUX26
	status = usb_submit_urb(urb, GFP_KERNEL);
#else
	status = usb_submit_urb(urb);
#endif

	if (status) {
		/* something went wrong */
		DEV_ERR(&port->dev,
			"%s - Send Port Data - Sending URB FAILE\n",
			__FUNCTION__);
			

		dbg("%s - usb_submit_urb(write bulk) failed", __FUNCTION__);
		port_priv->write_busy = FALSE;

		/*revert the count if something bad happened...*/
		port_priv->txCredits += count;
		port_priv->icount.tx -= count;
	}

	dbg("%s wrote %d byte(s) TxCredit %d, Fifo %d",
		__FUNCTION__,
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

	struct cp210x_serial_private	*serial_priv = usb_get_serial_data(serial);
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	struct circular_buf_txfifo *fifo;
	int copySize;
	int bytesleft;
	int firsthalf;
	int secondhalf;

	unsigned long flags;

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (port_priv == NULL)
		return -ENODEV;

	if (serial_priv == NULL)
		return -ENODEV;

	spin_lock_irqsave(&port_priv->portLock, flags);

	// get a pointer to the Tx fifo
	fifo = &port_priv->circular_buf_txfifo;

	// calculate number of bytes to put in fifo
	copySize = min ((unsigned int)count, (port_priv->txCredits - fifo->count));

	dbg("%s(%d) of %d byte(s) Fifo room  %d -- will copy %d bytes", __FUNCTION__,
	    port->number, count, port_priv->txCredits - fifo->count, copySize);

	/* catch writes of 0 bytes which the tty driver likes to give us, and when txCredits is empty */
	if (copySize == 0) {
		dbg("%s - copySize = Zero", __FUNCTION__);
		goto finish_write;
	}

	// queue the data	
	// since we can never overflow the buffer we do not have to check for full condition

	// the copy is done is two parts -- first fill to the end of the buffer
	// then copy the reset from the start of the buffer 

	bytesleft = fifo->size - fifo->head;
	firsthalf = min (bytesleft, copySize);
	dbg("%s - copy %d bytes of %d into fifo ", __FUNCTION__, firsthalf, bytesleft);

	/* now copy our data */
	if (from_user) {
		if (copy_from_user(&fifo->fifo[fifo->head], buf, firsthalf)){
			copySize = -EFAULT;
			goto finish_write;
		}
	}
	else {
		memcpy(&fifo->fifo[fifo->head], buf, firsthalf);
	}  

	// update the index and size
	fifo->head  += firsthalf;
	fifo->count += firsthalf;

	// wrap the index
	if (fifo->head == fifo->size) {
		fifo->head = 0;
	}

	secondhalf = copySize-firsthalf;

	if (secondhalf) {
		dbg("%s - copy rest of data %d", __FUNCTION__, secondhalf);
		if (from_user) {
			if (copy_from_user(&fifo->fifo[fifo->head],
						&buf[firsthalf],
						secondhalf)) {
						
				copySize = -EFAULT;
				goto finish_write;
			}
		}
		else {
			memcpy(&fifo->fifo[fifo->head],
				&buf[firsthalf],
				secondhalf);
		}
		// update the index and size
		fifo->count += secondhalf;
		fifo->head  += secondhalf;
		// No need to check for wrap since we can not get to end of fifo in this part
	}

	if (copySize) {
#ifdef LINUX26
		usb_serial_debug_data(debug, &port->dev, __FUNCTION__, copySize, buf);
#else
		usb_serial_debug_data (__FILE__, __FUNCTION__, copySize, buf);
#endif
	}

finish_write:
	spin_unlock_irqrestore(&port_priv->portLock, flags);

	cp210x_send_port_data(port);

	dbg("%s wrote %d byte(s) TxCredits %d, Fifo %d",
		__FUNCTION__,
		copySize,
		port_priv->txCredits,
		fifo->count);

	return copySize;   
}


#ifdef LINUX26
int silabs_cp210x_write_wrapper(struct usb_serial_port *port,
			const unsigned char *buf,
			int count)
{
	return silabs_cp210x_write(port, 0, buf, count);
}
#endif



int silabs_cp210x_chars_in_buffer (struct usb_serial_port *port)
{
	struct usb_serial		*serial = port->serial;
	int				chars = 0;

	unsigned long flags;

	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (port_priv == NULL)
		return -ENODEV;

	if (port_priv->closePending == TRUE)
		return -ENODEV;

	if (!port_priv->open) {
		dbg("%s - port not opened", __FUNCTION__);
		return -EINVAL;
	}

	if (serial->num_bulk_out) {
		spin_lock_irqsave(&port_priv->portLock, flags);

		chars = port_priv->maxTxCredits -
					port_priv->txCredits +
					port_priv->circular_buf_txfifo.count;
					
		spin_unlock_irqrestore(&port_priv->portLock, flags);
	}

	dbg("%s - returns %d", __FUNCTION__, chars);
	return (chars);
}



int silabs_cp210x_write_room (struct usb_serial_port *port)
{
	struct usb_serial		*serial = port->serial;
	int				room = 0;

	unsigned long flags;

	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	dbg("%s - port %d", __FUNCTION__, port->number);
	
	if (port_priv == NULL)
		return -ENODEV;
	
	if (port_priv->closePending == TRUE)
		return -ENODEV;

	if (!port_priv->open) {
		dbg("%s - port not opened", __FUNCTION__);
		return -EINVAL;
	}

	if (serial->num_bulk_out) {
	
		spin_lock_irqsave(&port_priv->portLock, flags);

		// total of both buffers is still txCredit
		room = port_priv->txCredits - port_priv->circular_buf_txfifo.count;

		spin_unlock_irqrestore(&port_priv->portLock, flags);
	}

	dbg("%s - returns %d", __FUNCTION__, room);
	return room;
}



static void cp210x_resubmit_read_urb(struct usb_serial_port *port, gfp_t mem_flags)
{
	struct urb 					*urb = port->read_urb;
	struct usb_serial			*serial = port->serial;
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);

	unsigned char 				*data = urb->transfer_buffer;

	int result;

	if (serial->dev == NULL)
		return;
		
	/* Continue reading from device */
#ifdef LINUX26
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,18))
	usb_fill_bulk_urb (urb, serial->dev,
				usb_rcvbulkpipe (serial->dev,
				port->bulk_in_endpointAddress),
				urb->transfer_buffer,
				urb->transfer_buffer_length,
				silabs_cp210x_read_bulk_callback_wrapper,
				port);
#else
	usb_fill_bulk_urb (urb, serial->dev,
			usb_rcvbulkpipe (serial->dev,
				port->bulk_in_endpointAddress),
			urb->transfer_buffer,
			urb->transfer_buffer_length,
			silabs_cp210x_read_bulk_callback,
			port);
#endif

#else

	FILL_BULK_URB(urb, serial->dev,
			usb_rcvbulkpipe(serial->dev,
				port->bulk_in_endpointAddress),
			urb->transfer_buffer,
			urb->transfer_buffer_length,
			silabs_cp210x_read_bulk_callback,
			port);
#endif

	if (PORT_COUNT) {
#ifdef LINUX26
		result = usb_submit_urb(urb, mem_flags);
#else
		result = usb_submit_urb(urb);
#endif
		
		if (result)
			DEV_ERR(&port->dev,
				"%s - failed resubmitting read urb, error %d\n",
				__FUNCTION__,
				result);
	}
}




/* Push data to tty layer and resubmit the bulk read URB */
static void cp210x_flush_and_resubmit_read_urb (struct usb_serial_port *port)
{
	struct urb 			*urb = port->read_urb;
	struct tty_struct		*tty = get_tty_port(port);
	struct usb_serial		*serial = port->serial;
	//struct usb_serial		*serial = get_usb_serial (port, __FUNCTION__);

	unsigned char *data = urb->transfer_buffer;

#ifdef LINUX26

#if (LINUX_VERSION_CODE > KERNEL_VERSION(2,6,15))
	int	room;
#else
	int	i;
	char tty_flag = 0;
#endif	

#else
	int	i;
	char tty_flag = 0;
#endif	
	
	if (!serial) {
		err ("%s - null serial pointer, exiting", __FUNCTION__);
		return;
	}
	
	if (urb->status) {
		dbg ("%s - nonzero read bulk status received:  %d", __FUNCTION__,
			urb->status);
			return;
	}
	
	dbg("%s - port %d", __FUNCTION__, port->number);
	
#ifdef LINUX26	
	usb_serial_debug_data(debug, &port->dev, __FUNCTION__, urb->actual_length, data);

#if (LINUX_VERSION_CODE > KERNEL_VERSION(2,6,15))
	/* Push data to tty */
	if (tty && urb->actual_length) {
		room = tty_buffer_request_room(tty, urb->actual_length);
		if (room) {
			tty_insert_flip_string(tty, urb->transfer_buffer, room);
			tty_flip_buffer_push(tty); /* is this allowed from an URB callback ? */
		}
	}
#else
	/* Push data to tty */
	if (tty && urb->actual_length) {
		/* overrun is special, not associated with a char */
		for (i = 0; i < urb->actual_length; ++i) {
			if (tty->flip.count >= TTY_FLIPBUF_SIZE) {
				tty_flip_buffer_push(tty);
			}
			tty_insert_flip_char (tty, data[i], tty_flag);
		}
		tty_flip_buffer_push (tty);
	}
#endif

#else
	usb_serial_debug_data (__FILE__, __FUNCTION__, urb->actual_length, data);

	/* Push data to tty */
	if (tty && urb->actual_length) {
		/* overrun is special, not associated with a char */
		for (i = 0; i < urb->actual_length; ++i) {
			if (tty->flip.count >= TTY_FLIPBUF_SIZE) {
				tty_flip_buffer_push(tty);
			}
			tty_insert_flip_char (tty, data[i], tty_flag);
		}
		tty_flip_buffer_push (tty);
	}
#endif

	/* Schedule the next read _if_ we are still open */
	if (PORT_COUNT) {
		cp210x_resubmit_read_urb(port, GFP_ATOMIC);
	}

	return;
			
}



void silabs_cp210x_read_bulk_callback (struct urb *urb)
{
	struct usb_serial_port *port = (struct usb_serial_port *)urb->context;
	int status = urb->status;

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (unlikely(status != 0)) {
		dbg("%s - nonzero read bulk status received: %d",
		    __FUNCTION__, status);
		return;
	}

	/* Handle data and continue reading from device */
	cp210x_flush_and_resubmit_read_urb(port);
}




#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,18))
void silabs_cp210x_read_bulk_callback_wrapper (struct urb *urb, struct pt_regs *regs)
{
	silabs_cp210x_read_bulk_callback (urb);
}
#endif




void silabs_cp210x_write_bulk_callback (struct urb *urb)
{
	struct usb_serial_port		*port = (struct usb_serial_port *)urb->context;
	struct cp210x_port_private	*port_priv;

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (urb == NULL)
		return;
	else
		port = (struct usb_serial_port *)urb->context;

#ifdef LINUX26
#else
	if (port_paranoia_check (port, __FUNCTION__)) {
		return;
	}
#endif


	port_priv = usb_get_serial_port_data(port);


#ifdef LINUX26
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,13))
	port->write_urb_busy = 0;
#else
	port_priv->write_busy = 0;
#endif

#else
	port_priv->write_busy = 0;
#endif	
	

	if (port_priv == NULL)
		return;
		
		
	if (urb->status) {
		dbg("%s - nonzero write bulk status received: %d",
			__FUNCTION__,
			urb->status);
		return;
	}

	if (get_tty_port(port) && port_priv->open) {
		/* let the tty driver wakeup if it has a special write_wakeup function */
#ifdef LINUX26
#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,18))
		usb_serial_port_softint(port);
#else
		usb_serial_port_softint((void *) port);
#endif		
#else
		queue_task(&port->tqueue, &tq_immediate);
		mark_bh(IMMEDIATE_BH);
#endif

	}
	
	spin_lock(&port_priv->portLock);

	port_priv->txCredits += urb->actual_length;

	// Release the Write URB
	port_priv->write_busy = FALSE;

	spin_unlock(&port_priv->portLock);

	// Check if more data needs to be sent
	cp210x_send_port_data(port);

	return;
}




#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,18))
void silabs_cp210x_write_bulk_callback_wrapper (struct urb *urb, struct pt_regs *regs)
{
	silabs_cp210x_write_bulk_callback (urb);
}
#endif



/*****************************************************************************
 * SerialThrottle
 *	this function is called by the tty driver when it wants to stop the data
 *	being read from the port.
 *****************************************************************************/
void silabs_cp210x_throttle (struct usb_serial_port *port)
{
	struct cp210x_port_private	*port_priv = usb_get_serial_port_data(port);
	struct tty_struct *tty;
	int status;

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (port_priv == NULL)
		return;

	if (!port_priv->open) {
		dbg("%s - port not opened", __FUNCTION__);
		return;
	}

	tty = get_tty_port(port);
	if (!tty) {
		dbg ("%s - no tty available", __FUNCTION__);
		return;
	}

	/* if we are implementing XON/XOFF, send the stop character */
	if (I_IXOFF(tty)) {
		unsigned char stop_char = STOP_CHAR(tty);
		status = cp210x_set_config_single(port,
					 SILABSER_IMM_CHAR_REQUEST_CODE,
					 stop_char);
		if (status <= 0) {
			return;
		}
	}

	/* if we are implementing RTS/CTS, toggle that line */
	if (tty->termios->c_cflag & CRTSCTS) {
		port_priv->mcr &= ~MCR_RTS;
		port_priv->line_control &= ~MCR_RTS;
		port_priv->line_control |= CONTROL_WRITE_RTS;

		dbg("%s - control = 0x%.4x", __FUNCTION__, port_priv->line_control);

		/* set the new MCR value in the device */
		status = cp210x_set_config_single(port,
					SILABSER_SET_MHS_REQUEST_CODE,
					port_priv->line_control);

		if (status != 0) {
			return;
		}
	}

	return;
}




/*****************************************************************************
 *	this function is called by the tty driver when it wants to resume the data
 *	being read from the port (called after SerialThrottle is called)
 *****************************************************************************/
void silabs_cp210x_unthrottle (struct usb_serial_port *port)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);
	struct tty_struct *tty;
	int status;

	dbg("%s - port %d", __FUNCTION__, port->number);

	if (port_priv == NULL)
		return;

	if (!port_priv->open) {
		dbg("%s - port not opened", __FUNCTION__);
		return;
	}

	tty = get_tty_port(port);
	if (!tty) {
		dbg ("%s - no tty available", __FUNCTION__);
		return;
	}

	/* if we are implementing XON/XOFF, send the start character */
	if (I_IXOFF(tty)) {
		unsigned char start_char = START_CHAR(tty);
		status = cp210x_set_config_single(port,
					 SILABSER_IMM_CHAR_REQUEST_CODE,
					 start_char);

		if (status <= 0) {
			return;
		}
	}

	/* if we are implementing RTS/CTS, toggle that line */
	if (tty->termios->c_cflag & CRTSCTS) {
		port_priv->mcr |= MCR_RTS;
		port_priv->line_control |= MCR_RTS;
		port_priv->line_control |= CONTROL_WRITE_RTS;

		dbg("%s - control = 0x%.4x", __FUNCTION__, port_priv->line_control);

		/* set the new MCR value in the device */
		status = cp210x_set_config_single(port,
					SILABSER_SET_MHS_REQUEST_CODE,
					port_priv->line_control);



		if (status != 0) {
			return;
		}
	}

	return;
}




static int silabs_cp210x_calc_num_ports(struct usb_serial *serial)
{
	struct usb_device *dev = serial->dev;
	
	// This is a very simple solution.  If additional Dual or Multi Port Device IDs or
	// Product IDs are added, setup a table with VID, PID, NumPorts
	
	if ( 0xEA70 == le16_to_cpu(dev->descriptor.idProduct))
	{
		return 2;
	}

	return 1;
}


#ifdef LINUX26
static int silabs_cp210x_probe(struct usb_interface *interface,
			       const struct usb_device_id *id)
{
	const struct usb_device_id *id_pattern;


	printk ("CP210X - probe\n");

	id_pattern = usb_match_id(interface, silabs_cp210x_device_ids);
	if (id_pattern != NULL)
		return usb_serial_probe(interface, id);

	return -ENODEV;
}
#endif





/*****************************************************************************
 * handle_new_msr
 *	this function handles any change to the msr register for a port.
 *****************************************************************************/
static void cp210x_handle_new_modem_status(struct usb_serial_port *port,
						unsigned int modem_status)
{
	struct cp210x_port_private *port_priv = usb_get_serial_port_data(port);
	
	struct  async_icount *icount;
	
	dbg("%s %02x", __FUNCTION__, modem_status);

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

	dbg("%s - %02x", __FUNCTION__, newLsr);

	if (newLsr & LSR_BREAK) {
		//
		// Parity and Framing errors only count if they
		// occur exclusive of a break being
		// received.
		//
		newLsr &= (__u8)(LSR_HW_OVERRUN | LSR_QUEUE_OVERRUN | LSR_BREAK);
	}

	/* update input line counters */
	icount = &port_priv->icount;
	if (newLsr & LSR_BREAK) {
		icount->brk++;
	}
	if (newLsr & LSR_QUEUE_OVERRUN) {
		icount->overrun++;
	}
	if (newLsr & LSR_PARITY_ERROR) {
		icount->parity++;
	}
	if (newLsr & LSR_FRAMING_ERROR) {
		icount->frame++;
	}

	port_priv->lsr = (__u8) port_priv->serialstat.ulErrors & LSR_ALL;

	return;
}





static int cp210x_control_thread (void *port)
{
	struct cp210x_port_private *port_priv =
		usb_get_serial_port_data((struct usb_serial_port *) port);
	
	unsigned int	ret_code = 0;
	unsigned int	line_control = 0;
	
	unsigned long timeout = (TIMEOUT_10ms * 8);
	
#ifdef LINUX26

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
	daemonize("cp210x_control_thread\n");
	allow_signal(SIGKILL);

	do {
#else
	allow_signal(SIGKILL);

	while (!kthread_should_stop()) {
#endif

#else
	daemonize();
	reparent_to_init();

	do {
#endif

		set_current_state(TASK_INTERRUPTIBLE);
	
		timeout = schedule_timeout(timeout);
		
		if (signal_pending(current)) break;
			
		if (!timeout) {
			// check status
			if (!(ret_code = cp210x_get_serialstat((struct usb_serial_port *) port))) {
				dbg("%s - Control URB Failed, Exiting Thread", __FUNCTION__);
				printk ("CP210X - exiting thread\n");
				break;
			}
					
			cp210x_handle_new_line_status((struct usb_serial_port *) port);
			
			if ((cp210x_get_config((struct usb_serial_port *) port,
					SILABSER_GET_MDMSTS_REQUEST_CODE,
					&line_control,
					1))) {
				dbg("%s - Control URB Failed, Exiting Thread", __FUNCTION__);
				printk ("CP210X - exiting thread\n");
				break;
			}
					
			cp210x_handle_new_modem_status((struct usb_serial_port *) port,
					line_control);
					
			timeout = (TIMEOUT_10ms * 8);
		} else {
			// process standard control requests

		}

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
	} while (port_priv->run_cp210x_control_thread);
#else
	}
#endif

	
	set_current_state(TASK_RUNNING);
	
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
	complete_and_exit(&port_priv->portThreadComplete, 0);
	
	return ret_code;

#else

	return 0;
		
#endif
}





static int cp210x_start_control_thread (struct usb_serial_port *port)
{
#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,22))
	int ret = kernel_thread(cp210x_control_thread,
				port,
				(CLONE_FS | CLONE_FILES | CLONE_SIGHAND | SIGCHLD));
#else
	int ret = 0;
	
	struct cp210x_port_private *port_priv =
		usb_get_serial_port_data((struct usb_serial_port *) port);
	
	
	port_priv->cp210x_task = kthread_create (	cp210x_control_thread, port, "%s", "cp210x_control_thread" );
	
	if (!IS_ERR(port_priv->cp210x_task))
		wake_up_process(port_priv->cp210x_task);
#endif

	return (ret);
}





static int silabs_cp210x_startup (struct usb_serial *serial)
{
	struct cp210x_serial_private		*serial_priv;
	struct cp210x_port_private			*port_priv;
	int					i;
	
	dbg ("%s", __FUNCTION__);
	
	printk ("CP210X - startup\n");
	
#ifdef LINUX26
	/* CP2101 buffers behave strangely unless device is reset */
	usb_reset_device(serial->dev);
#endif

	serial_priv = kmalloc (sizeof (struct cp210x_serial_private), GFP_KERNEL);
	if (!serial_priv) {
		//DEV_ERR(&port->dev,
		//	"%s - Out of memory\n",
		//	__FUNCTION__);
		return -ENOMEM;
	}

	memset (serial_priv, 0x00, sizeof (struct cp210x_serial_private));
	spin_lock_init (&serial_priv->devLock);
	serial_priv->serial = serial;
	usb_set_serial_data (serial, serial_priv);

	for (i = 0; i < serial->num_ports; ++i) {
		port_priv = kmalloc (sizeof (struct cp210x_port_private), GFP_KERNEL);
		if (!port_priv) {
			//DEV_ERR(&port->dev,
			//	"%s - Out of memory\n",
			//	__FUNCTION__);
			return -ENOMEM;
		}

		memset (port_priv, 0x00, sizeof (struct cp210x_port_private));
		spin_lock_init (&port_priv->portLock);

#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,16))
		init_MUTEX (&port_priv->controlPipeMutex);
#else
		mutex_init(&port_priv->controlPipeMutex);
#endif

#ifdef LINUX26
		port_priv->port = serial->port[i];
		usb_set_serial_port_data (serial->port[i], port_priv);
		cp210x_get_partnum(serial->port[i]);
#else
		port_priv->port = &serial->port[i];
		usb_set_serial_port_data (&serial->port[i], port_priv);
		cp210x_get_partnum(&serial->port[i]);
#endif
	}

	return 0;
}





static void cp210x_stop_control_thread (struct usb_serial_port  *port)
{
	return;
}





void silabs_cp210x_shutdown (struct usb_serial *serial)
{
	int i;

	dbg("%s", __FUNCTION__);

	printk ("CP210X - shutdown\n");

	/* stop reads and writes on all ports */
	for (i=0; i < serial->num_ports; ++i) {
#ifdef LINUX26
		cp210x_close_port (serial->port[i]);
#else
		cp210x_close_port (&serial->port[i]);
#endif
	}
		
	kfree (usb_get_serial_data(serial));
	usb_set_serial_data(serial, NULL);
}



static int __init silabs_cp210x_init(void)
{
	int retval = 0;

	printk ("CP210X - init\n");

	retval = usb_serial_register(&silabs_cp210x_device);
	if (retval)
		return retval;

#ifdef LINUX26
	retval = usb_register(&silabs_cp210x_driver);
	if (retval) {
		/* Failed to register */
		usb_serial_deregister(&silabs_cp210x_device);
		return retval;
	}
#endif

	/* Success */
	return 0;
}



static void __exit silabs_cp210x_exit(void)
{
	printk ("CP210X - exit\n");

#ifdef LINUX26
	usb_deregister (&silabs_cp210x_driver);
#endif
	
	usb_serial_deregister (&silabs_cp210x_device);
}


module_init(silabs_cp210x_init);
module_exit(silabs_cp210x_exit);


MODULE_AUTHOR( DRIVER_AUTHOR );
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_LICENSE("GPL");


#ifdef LINUX26
MODULE_VERSION(DRIVER_VERSION);
module_param(debug, bool, S_IRUGO | S_IWUSR);

#else //LINUX26

MODULE_PARM(debug, "i");

#endif //LINUX26

MODULE_PARM_DESC(debug, "Enable verbose debugging messages");
