.PHONY: all clean help
.PHONY: u-boot kernel kernel-config
.PHONY: linux pack

include chosen_board.mk

U_CROSS_COMPILE=$(U_COMPILE_TOOL)/arm-linux-gnueabi-
#U_CROSS_COMPILE=$(U_COMPILE_TOOL)/aarch64-none-linux-gnu-
K_CROSS_COMPILE=$(K_COMPILE_TOOL)/aarch64-none-linux-gnu-

ROOTFS=$(CURDIR)/rootfs/linux/default_linux_rootfs.tar.gz

Q=
J=$(shell expr `grep ^processor /proc/cpuinfo  | wc -l` \* 2)

all: bsp

clean: u-boot-clean kernel-clean
	rm -f chosen_board.mk env.sh

distclean: clean
	rm -rf SD/

pack: sunxi-pack
	$(Q)scripts/mk_pack.sh

install:
	$(Q)scripts/mk_install_sd.sh

u-boot: 
	$(Q)$(MAKE) -C u-boot-sunxi CROSS_COMPILE=${U_CROSS_COMPILE} $(UBOOT_CONFIG)
	$(Q)$(MAKE) -C u-boot-sunxi CROSS_COMPILE=${U_CROSS_COMPILE}

u-boot-clean:
	$(Q)$(MAKE) -C u-boot-sunxi distclean


kernel:
	$(Q)$(MAKE) -C linux-sunxi ARCH=$(ARCH) CROSS_COMPILE=${K_CROSS_COMPILE} $(KERNEL_CONFIG)
	$(Q)$(MAKE) -C linux-sunxi ARCH=$(ARCH) CROSS_COMPILE=${K_CROSS_COMPILE} -j$J
	$(Q)$(MAKE) -C linux-sunxi ARCH=$(ARCH) CROSS_COMPILE=${K_CROSS_COMPILE} -j$J INSTALL_MOD_PATH=output modules_install
	$(Q)scripts/mk_kernel_headers.sh ${K_CROSS_COMPILE} 

kernel-clean:
	$(Q)$(MAKE) -C linux-sunxi ARCH=$(ARCH) -j$J distclean
	rm -rf linux-sunxi/output/

kernel-config: $(K_DOT_CONFIG)
	$(Q)$(MAKE) -C linux-sunxi ARCH=$(ARCH) $(KERNEL_CONFIG)
	$(Q)$(MAKE) -C linux-sunxi ARCH=$(ARCH) -j$J menuconfig
	cp linux-sunxi/.config linux-sunxi/arch/$(ARCH)/configs/$(KERNEL_CONFIG)

bsp: u-boot kernel

help:
	@echo ""
	@echo "Usage:"
	@echo "  make bsp             - Default 'make'"
	@echo "  make pack            - pack the images and rootfs to a PhenixCard download image."
	@echo "  make clean"
	@echo ""
	@echo "Optional targets:"
	@echo "  make kernel           - Builds linux kernel"
	@echo "  make kernel-config    - Menuconfig"
	@echo "  make u-boot          - Builds u-boot"
	@echo ""

