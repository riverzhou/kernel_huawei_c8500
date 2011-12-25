#!/bin/bash

DATE=`date +%Y%m%d`

function setenv {
	echo -n "Setting ARM environment..."
	export CFLAGS="-O2 -Os -floop-interchange -floop-strip-mine -floop-block"
	echo " done."

	echo -n "Setting other environment variables..."
	# the number of CPUs to use when compiling the kernel (auto detect all available)
	export CPUS=`grep -c processor /proc/cpuinfo`
	# grab the localversion so we can append it to the boot image
	let RELVER=`cat .version`+1
	echo " done."
}

function mkinitramfs {
	echo "Zipping ramdisk..."
	release/mkbootfs release/boot.img-ramdisk | gzip > release/boot.img-ramdisk.gz
}

function mkbootimg {
	echo "Creating boot.img..."
	release/mkbootimg --cmdline 'mem=211M console=ttyMSM2,115200n8 androidboot.hardware=c8500' --kernel arch/arm/boot/zImage --ramdisk release/boot.img-ramdisk.gz -o release/c8500_boot.img || exit 1
	echo "Smells like bacon... release/c8500_boot.img is ready!"
}

function copy2cm7 {
	echo "Copy kernel and modules to cm7 directory ... "
	cp arch/arm/boot/zImage  	  /river/cm7/device/huawei/c8500/prebuilt/kernel
	cp drivers/staging/zram/zram.ko   /river/cm7/device/huawei/c8500/prebuilt/lib/modules/zram.ko
	echo "done."
}


#copy2cm7
mkinitramfs && mkbootimg

