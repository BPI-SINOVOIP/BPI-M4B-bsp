#!/bin/bash

die() {
        echo "$*" >&2
        exit 1
}

[ -s "./env.sh" ] || die "please run ./configure first."

. ./env.sh

O=$1
if [ ! -z $O ] ; then
	BOARD=$O
fi

UBOOT=${TOPDIR}/u-boot-sunxi
BIN=${TOPDIR}/sunxi-pack/common/bin
TOOLS=${TOPDIR}/sunxi-pack/common/tools
CONFIG=${TOPDIR}/sunxi-pack/${MACH}/${BOARD}
PACK=$TOPDIR/out/${BOARD}/image
IMG=${PACK}/${BOARD}-8k.img
TMP=/tmp/${BOARD}-8k.tmp

uboot_custom()
{
        export PATH=${TOOLS}:$PATH
        cp ${BIN}/* ${PACK}/
        cp ${CONFIG}/sys_config.fex ${PACK}/
        cp ${CONFIG}/u-boot.dts ${PACK}/
        cp ${UBOOT}/u-boot.bin ${PACK}/u-boot.fex

	cd ${PACK}
        # make u-boot dtb
        ${TOOLS}/dtc -p 2048 -W no-unit_address_vs_reg -@ -O dtb -o u-boot.dtb -b 0 u-boot.dts >/dev/null 2>&1
        [[ ! -f u-boot.dtb ]] && exit_with_error "dts compilation failed"

        busybox unix2dos sys_config.fex
        ${TOOLS}/script sys_config.fex >/dev/null 2>&1
        cp u-boot.dtb sunxi.fex
        ${TOOLS}/update_dtb sunxi.fex 4096 >/dev/null 2>&1
        ${TOOLS}/update_uboot -no_merge u-boot.fex sys_config.bin >/dev/null 2>&1
        ${TOOLS}/update_uboot -no_merge u-boot.bin sys_config.bin >/dev/null 2>&1

        # pack boot package
        busybox unix2dos boot_package.cfg
        ${TOOLS}/dragonsecboot -pack boot_package.cfg >/dev/null 2>&1
	cd -

        # merge uboot
        sudo dd if=/dev/zero of=$TMP bs=1M count=20 conv=fsync > /dev/null 2>&1
        sudo dd if=${PACK}/boot0_sdcard.fex of=$TMP bs=1024 seek=8 conv=fsync > /dev/null 2>&1;
        sudo dd if=${PACK}/boot_package.fex of=$TMP bs=1024 seek=16400 conv=fsync > /dev/null 2>&1 || true;
	sudo dd if=$TMP of=$IMG bs=1024 skip=8 conv=fsync > /dev/null 2>&1;
}

# create pack folder
if [ -d $PACK ]; then
	rm -r $PACK
fi
mkdir -p $PACK

# build uboot before pack
if [ ! -e "$UBOOT" ]; then
	echo -e "\033[31m u-boot.bin not exit, please build u-boot before pack\033[0m"
	exit 1
fi

uboot_custom

echo "gzip ${IMG}"
gzip ${IMG}
