#!/bin/bash

TAG=ACDS14.1_REL_GSRD_PR_UPDATE2

glo()
{
    git log --pretty=format:'%h %an : %s' $@
}

gshow()
{
    basename $PWD
    mode=$1
    shift
    while [ -n "$1" ]; do
	echo $1
	case $mode in
	    -l ) 
		glo -1 $1
		;;
	    -d ) 
		git describe $1
		;;
	    * ) echo 'what?'; exit;;
	esac
	shift
	echo
    done
}

cd ~/repos/internal/meta-altera
gshow -l $TAG portal/angstrom-v2013.12-yocto1.5_gsrd14.1

cd ~/repos/internal/linux-socfpga
gshow -d $TAG portal/socfpga-3.10-ltsi

cd ~/repos/internal/uboot-socfpga
gshow -d $TAG portal/socfpga_v2013.01.01

cd ~/repos/internal/linux-refdesigns
gshow -l $TAG portal/socfpga-14.1

cd ~/repos/internal/angstrom-socfpga
gshow -l $TAG portal/angstrom-v2013.12-socfpga_gsrd14.1

exit



ACDS14.1_REL_GSRD_PR_UPDATE2

Repository	       Branch			  		   Tags to be pused to external GIT   Tags in internal GIT

meta-altera	       angstrom-v2013.12-yocto1.5_gsrd14.1	   ACDS14.1_REL_GSRD_PR_UPDATE2	      ACDS14.1_REL_GSRD_PR_UPDATE2

linux-socfpga	       socfpga-3.10-ltsi			   ACDS14.1_REL_GSRD_PR_UPDATE2	      ACDS14.1_REL_GSRD_PR_UPDATE2

uboot-socfpga	       socfpga_v2013.01.01			   ACDS14.1_REL_GSRD_PR_UPDATE2	      ACDS14.1_REL_GSRD_PR_UPDATE2

linux-refdesigns       socfpga-14.1				   ACDS14.1_REL_GSRD_PR_UPDATE2	      ACDS14.1_REL_GSRD_PR_UPDATE2

angstrom-socfpga       angstrom-v2013.12-socfpga_gsrd14.1	   ACDS14.1_REL_GSRD_PR_UPDATE2	      ACDS14.1_REL_GSRD_PR_UPDATE2

