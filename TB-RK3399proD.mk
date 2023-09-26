include rk3399.mk

U-BOOT_DEFCONFIG_FILES := \
	$(U-BOOT_PATH)/configs/toybrick-prod_defconfig \
	$(ROOT)/build/kconfig/TB-RK3399proD.config

u-boot-patch:
	cd $(U-BOOT_PATH) && git reset --hard
	cd $(U-BOOT_PATH) && git clean -fdx

u-boot capsule: u-boot-patch
