%define KVER	%(uname -r)
%define KVER1	%(uname -r | awk -F . -- '{ print $1 }')
%define KVER2	%(uname -r | awk -F . -- '{ print $2 }')
%define KVER3	%(uname -r | sed -e "s/$KVER1\\.$KVER2\\.//g")


# RPM header info
Summary: Silicon Labs CP2101/CP2102/CP2103 USB To Serial Bridge driver
Name: cp210x
Version: 3.1.0
Release: 063
Group: System Environment/Kernel
BuildRoot: /var/tmp/silabs/%{name}-root
ExclusiveOS: linux
Source: %{name}-%{version}.tar.gz
Packager: DGO
Vendor: Silicon Laboratories, Inc.
License: GPL



%description
Device driver kernel module for the Silicon Laboratories CP2101/CP2102/CP2103 USB To Serial Bridge.



%prep
kver2=%{KVER2}
case $kver2 in
	4)
		echo "2.4 Kernel"
		;;
	6)
		echo "2.6 Kernel"
		;;
esac
%setup -q



%build
sh ./configure
kver2=%{KVER2}
case $kver2 in
	4)
		echo "2.4 Kernel"
		cp ./Makefile24 ./Makefile
		make -f Makefile24 modules
		;;
	6)
		echo "2.6 Kernel"
		cp ./Makefile26 ./Makefile
		make -f Makefile26 modules
		;;
esac



%install
kver2=%{KVER2}
case $kver2 in
	4)
		echo "2.4 Kernel"
		make -f Makefile24 modules
		install -m 744 -D cp210x.o $RPM_BUILD_ROOT/lib/modules/%_kernel_release/kernel/drivers/usb/serial/cp210x.o
		;;
	6)
		echo "2.6 Kernel"
		make -f Makefile26 modules
		install -m 744 -D cp210x.ko $RPM_BUILD_ROOT/lib/modules/%_kernel_release/kernel/drivers/usb/serial/cp210x.ko
		;;
esac



%post
/sbin/modprobe -r -q -s cp2101
kver2=%{KVER2}
case $kver2 in
	4)
		echo "2.4 Kernel"
		rm -f /lib/modules/%_kernel_release/kernel/drivers/usb/serial/cp2101.0
		/sbin/depmod -ae -F /boot/System.map %_kernel_release
		;;
	6)
		echo "2.6 Kernel"
		rm -f /lib/modules/%_kernel_release/kernel/drivers/usb/serial/cp2101.ko
		/sbin/depmod -A %_kernel_release
		;;
esac
#/sbin/depmod -ae -F /boot/System.map %_kernel_release


%clean
rm -rf $RPM_BUILD_ROOT



%files
%defattr(-,root,root)
#kver2=%{KVER2}
#case $kver2 in
#	4)
#		echo "2.4 Kernel"
#		/lib/modules/%_kernel_release/kernel/drivers/usb/serial/cp210x.o
#		;;
#	6)
#		echo "2.6 Kernel"
		/lib/modules/%_kernel_release/kernel/drivers/usb/serial/cp210x*
#		;;
#esac

