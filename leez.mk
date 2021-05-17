################################################################################
# Following variables defines how the NS_USER (Non Secure User - Client
# Application), NS_KERNEL (Non Secure Kernel), S_KERNEL (Secure Kernel) and
# S_USER (Secure User - TA) are compiled
################################################################################
override COMPILE_NS_USER   := 32
override COMPILE_NS_KERNEL := 32
override COMPILE_S_USER    := 32
override COMPILE_S_KERNEL  := 32


OPTEE_OS_PLATFORM = rockchip

include common.mk

################################################################################
# Paths to git projects and various binaries
################################################################################
TF_A_PATH		?= $(ROOT)/atf
BINARIES_PATH		?= $(ROOT)/out/bin
U-BOOT_PATH		?= $(ROOT)/u-boot

DEBUG = 1

################################################################################
# Targets
################################################################################
all: arm-tf u-boot
clean: arm-tf-clean u-boot-clean

include toolchain.mk

################################################################################
# ARM Trusted Firmware
################################################################################
TF_A_EXPORTS ?= CROSS_COMPILE="$(CCACHE)$(AARCH64_CROSS_COMPILE)"

TF_A_DEBUG ?= $(DEBUG)
ifeq ($(TF_A_DEBUG),0)
TF_A_LOGLVL ?= 30
TF_A_OUT = $(TF_A_PATH)/build/rk3399/release
else
TF_A_LOGLVL ?= 50
TF_A_OUT = $(TF_A_PATH)/build/rk3399/debug
endif

TF_A_FLAGS ?= \
	ARCH=aarch64 \
	PLAT=rk3399 \
	DEBUG=$(TF_A_DEBUG) \
	LOG_LEVEL=$(TF_A_LOGLVL)

	#BL32=$(OPTEE_OS_HEADER_V2_BIN) \
	#BL32_EXTRA1=$(OPTEE_OS_PAGER_V2_BIN) \
	#BL32_EXTRA2=$(OPTEE_OS_PAGEABLE_V2_BIN) \
	#ARM_ARCH_MAJOR=8 \
	#ARM_TSP_RAM_LOCATION=tdram \
	#BL32_RAM_LOCATION=tdram \
	#AARCH64_SP=optee \
	#BL31=${TF_A_OUT}/bl31/bl31.elf \
	#BL33=$(ROOT)/u-boot/u-boot.bin \

arm-tf:
	$(TF_A_EXPORTS) $(MAKE) -C $(TF_A_PATH) $(TF_A_FLAGS) all
	mkdir -p $(BINARIES_PATH)
	ln -sf $(TF_A_OUT)/bl1.bin $(BINARIES_PATH)
	ln -sf $(TF_A_OUT)/bl2.bin $(BINARIES_PATH)
	ln -sf $(OPTEE_OS_HEADER_V2_BIN) $(BINARIES_PATH)/bl32.bin
	ln -sf $(OPTEE_OS_PAGER_V2_BIN) $(BINARIES_PATH)/bl32_extra1.bin
	ln -sf $(OPTEE_OS_PAGEABLE_V2_BIN) $(BINARIES_PATH)/bl32_extra2.bin
	ln -sf $(ROOT)/u-boot/u-boot.bin $(BINARIES_PATH)/bl33.bin

arm-tf-clean:
	$(TF_A_EXPORTS) $(MAKE) -C $(TF_A_PATH) $(TF_A_FLAGS) clean

################################################################################
# U-boot
################################################################################
U-BOOT_EXPORTS ?= \
	CROSS_COMPILE="$(CCACHE)$(AARCH64_CROSS_COMPILE)"\
	BL31=${TF_A_OUT}/bl31/bl31.elf

U-BOOT_DEFCONFIG_FILES := \
	$(U-BOOT_PATH)/configs/leez-rk3399_defconfig

.PHONY: u-boot
u-boot: arm-tf
	cd $(U-BOOT_PATH) && \
		scripts/kconfig/merge_config.sh $(U-BOOT_DEFCONFIG_FILES)
	$(U-BOOT_EXPORTS) $(MAKE) -C $(U-BOOT_PATH) all

.PHONY: u-boot-clean
u-boot-clean:
	$(U-BOOT_EXPORTS) $(MAKE) -C $(U-BOOT_PATH) clean


