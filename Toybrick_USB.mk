################################################################################
# Following variables defines how the NS_USER (Non Secure User - Client
# Application), NS_KERNEL (Non Secure Kernel), S_KERNEL (Secure Kernel) and
# S_USER (Secure User - TA) are compiled
################################################################################
override COMPILE_NS_USER   := 32
override COMPILE_NS_KERNEL := 32
override COMPILE_S_USER    := 32
override COMPILE_S_KERNEL  := 32


include common.mk

################################################################################
# Paths to git projects and various binaries
################################################################################

KERNEL_PATH		?= $(ROOT)/kernel
DTB ?= 
DEBUG = 0

################################################################################
# Targets
################################################################################
all: kernel
clean: kernel-clean

include toolchain.mk

################################################################################
# Kernel
################################################################################
KERNEL_EXPORTS	?= CROSS_COMPILE="$(CCACHE)$(AARCH64_CROSS_COMPILE)"
KERNEL_FLAGS	?= ARCH=arm64
VERSION	?= "2.0"
DTB		?= rk3399pro-toybrick-prod-linux


kernel:
	cd  $(KERNEL_PATH)
	rm -rf $(KERNEL_PATH)/boot_linux
	mkdir -p $(KERNEL_PATH)/boot_linux/extlinux
	
	$(KERNEL_EXPORTS) $(MAKE) -C $(KERNEL_PATH) $(KERNEL_FLAGS) rockchip_linux_defconfig
	$(KERNEL_EXPORTS) $(MAKE) -C $(KERNEL_PATH) $(KERNEL_FLAGS) $(DTB)-edp.img
	$(KERNEL_EXPORTS) $(MAKE) -C $(KERNEL_PATH) $(KERNEL_FLAGS) $(DTB)-mipi.img
	$(KERNEL_EXPORTS) $(MAKE) -C $(KERNEL_PATH) $(KERNEL_FLAGS) $(DTB)-u2.img
	
	cp -f $(KERNEL_PATH)/arch/arm64/boot/dts/rockchip/$(DTB)-u2.dtb $(KERNEL_PATH)/boot_linux/extlinux/toybrick-u2.dtb
	cp -f $(KERNEL_PATH)/arch/arm64/boot/dts/rockchip/$(DTB)-edp.dtb $(KERNEL_PATH)/boot_linux/extlinux/toybrick-edp.dtb
	cp -f $(KERNEL_PATH)/arch/arm64/boot/dts/rockchip/$(DTB)-mipi.dtb $(KERNEL_PATH)/boot_linux/extlinux/toybrick-mipi.dtb
	cp -f $(KERNEL_PATH)/arch/arm64/boot/dts/rockchip/$(DTB)-imx258.dtb $(KERNEL_PATH)/boot_linux/extlinux/toybrick-imx258.dtb
	
	$(KERNEL_EXPORTS) $(MAKE) -C $(KERNEL_PATH) $(KERNEL_FLAGS) $(DTB)-imx258.img
	$(KERNEL_EXPORTS) $(MAKE) -C $(KERNEL_PATH) $(KERNEL_FLAGS) $(DTB).img
	
	cp -f $(KERNEL_PATH)/arch/arm64/boot/dts/rockchip/$(DTB).dtb $(KERNEL_PATH)/boot_linux/extlinux/toybrick.dtb
	cp -f $(KERNEL_PATH)/arch/arm64/boot/dts/rockchip/$(DTB).dtb $(KERNEL_PATH)/boot_linux/extlinux/toybrick-default.dtb
	cp -f $(KERNEL_PATH)/arch/arm64/boot/Image $(KERNEL_PATH)/boot_linux/extlinux/
	
	echo "label rockchip-kernel-4.4" > $(KERNEL_PATH)/boot_linux/extlinux/extlinux.conf
	echo "	kernel /extlinux/Image" >> $(KERNEL_PATH)/boot_linux/extlinux/extlinux.conf
	echo "	fdt /extlinux/toybrick.dtb" >> $(KERNEL_PATH)/boot_linux/extlinux/extlinux.conf
	echo "	append  earlycon=uart8250,mmio32,0xff1a0000 initrd=/initramfs-toybrick-${VERSION}.img root=PARTUUID=614e0000-0000-4b53-8000-1d28000054a9 rw rootwait rootfstype=ext4" >> $(KERNEL_PATH)/boot_linux/extlinux/extlinux.conf
	
	cp -f $(KERNEL_PATH)/initramfs-toybrick-${VERSION}.img $(KERNEL_PATH)/boot_linux/
	cp -f $(KERNEL_PATH)/rescue.sh $(KERNEL_PATH)/boot_linux/
	if [ "`uname -i`" == "aarch64" ]; then
		echo y | mke2fs -b 4096 -d $(KERNEL_PATH)/boot_linux -i 8192 -t ext2 $(KERNEL_PATH)/boot_linux.img $((64 * 1024 * 1024 / 4096))
	else
		genext2fs -b 32768 -B $((64 * 1024 * 1024 / 32768)) -d $(KERNEL_PATH)/boot_linux -i 8192 -U $(KERNEL_PATH)/boot_linux.img
	fi

	
kernel-clean:
	cd  $(KERNEL_PATH)
	$(KERNEL_EXPORTS) $(MAKE) -C $(KERNEL_PATH) $(KERNEL_FLAGS) distclean

