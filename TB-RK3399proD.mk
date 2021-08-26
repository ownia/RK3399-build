include rk3399.mk

U-BOOT_DEFCONFIG_FILES := \
	$(U-BOOT_PATH)/configs/toybrick-prod_defconfig \
	$(ROOT)/build/kconfig/TB-RK3399proD.config

U-BOOT_PATCHES := \
	$(ROOT)/build/0001-CapsuleCommon.patch \
	$(ROOT)/build/0002-Toybrick-uboot-bringup-code.patch \
	$(ROOT)/build/0003-TBRK3399proD-DFU.patch

u-boot-patch:
	cd $(U-BOOT_PATH) && git reset --hard
	cd $(U-BOOT_PATH) && git clean -fdx
	cd $(U-BOOT_PATH) && git apply $(U-BOOT_PATCHES)

u-boot capsule: u-boot-patch
