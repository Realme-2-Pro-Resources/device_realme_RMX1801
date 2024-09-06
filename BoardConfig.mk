#
# Copyright (C) 2018 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_INCORRECT_PARTITION_IMAGES := true

DEVICE_PATH := device/realme/RMX1801

# Arch
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a73

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a73

# Platform
BOARD_USES_QCOM_HARDWARE := true
TARGET_BOARD_PLATFORM := sdm660

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := sdm660
TARGET_NO_BOOTLOADER := true

# Kernel
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 service_locator.enable=1 swiotlb=1 loop.max_part=7
BOARD_KERNEL_CMDLINE += usbcore.autosuspend=7
BOARD_KERNEL_CMDLINE += androidboot.boot_devices=soc/c0c4000.sdhci
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
BOARD_KERNEL_BASE := 0x00000000
BOARD_PAGE_SIZE := 4096
BOARD_RAMDISK_OFFSET     := 0x01000000
BOARD_SECOND_OFFSET := 0x00f00000
BOARD_TAGS_OFFSET := 0x00000100
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --second_offset $(BOARD_SECOND_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_PAGE_SIZE)
TARGET_KERNEL_ARCH := arm64
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_ADDITIONAL_FLAGS := \
    HOSTCFLAGS="-fuse-ld=lld -Wno-unused-command-line-argument"
TARGET_KERNEL_ADDITIONAL_FLAGS += LLVM=1
TARGET_KERNEL_SOURCE := kernel/realme/sdm660
TARGET_KERNEL_CONFIG := RMX1801_defconfig

# ANT+
BOARD_ANT_WIRELESS_DEVICE := "qualcomm-hidl"

# Assert
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt
TARGET_OTA_ASSERT_DEVICE := RMX1801,RMX1803,RMX1807

# Audio
AUDIO_FEATURE_ENABLED_AAC_ADTS_OFFLOAD := true
AUDIO_FEATURE_ENABLED_AUDIOSPHERE := true
AUDIO_FEATURE_ENABLED_EXTN_FORMATS := true
AUDIO_FEATURE_ENABLED_FM_POWER_OPT := true
AUDIO_FEATURE_ENABLED_HDMI_SPK := true
AUDIO_FEATURE_ENABLED_PROXY_DEVICE := true
BOARD_SUPPORTS_OPENSOURCE_STHAL := true

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
QCOM_BT_USE_BTNV := true

# Camera
USE_DEVICE_SPECIFIC_CAMERA := true

# Display
TARGET_SCREEN_DENSITY := 480
TARGET_HAS_WIDE_COLOR_DISPLAY := true

# Filesystem
TARGET_FS_CONFIG_GEN := $(DEVICE_PATH)/config.fs

# GPS
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := $(TARGET_BOARD_PLATFORM)
LOC_HIDL_VERSION := 4.0

# Graphics
TARGET_USES_GRALLOC1 := true
TARGET_USES_HWC2 := true
TARGET_USES_ION := true
USE_OPENGL_RENDERER := true

# HIDL
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml

# Init
TARGET_INIT_VENDOR_LIB := //$(DEVICE_PATH):libinit_realme
TARGET_RECOVERY_DEVICE_MODULES := libinit_realme

# Lineage Health
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH := /sys/class/power_supply/battery/mmi_charging_enable
TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS := false

# Partitions
SSI_PARTITIONS := product system system_ext
TREBLE_PARTITIONS := odm vendor
ALL_PARTITIONS := $(SSI_PARTITIONS) $(TREBLE_PARTITIONS)

$(foreach p, $(call to-upper, $(ALL_PARTITIONS)), \
	$(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := ext4) \
	$(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))

BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_PARTITION_SIZE := 260014080
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor
BOARD_SUPER_PARTITION_METADATA_DEVICE := system
BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 5460574208
BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 1610612736
BOARD_SUPER_PARTITION_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE) + $(BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE) )
BOARD_SUPER_PARTITION_GROUPS := realme_dynpart
BOARD_REALME_DYNPART_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304 )
BOARD_REALME_DYNPART_PARTITION_LIST := $(ALL_PARTITIONS)
BOARD_USES_METADATA_PARTITION := true
BOARD_USERDATAIMAGE_PARTITION_SIZE := 52941119488
BOARD_FLASH_BLOCK_SIZE := 262144

# Partition's Filesystem
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := false
TARGET_USERIMAGES_USE_F2FS := true

# Partitions - reserved size
$(foreach p, $(call to-upper, $(SSI_PARTITIONS)), \
	$(eval BOARD_$(p)IMAGE_EXTFS_INODE_COUNT := -1))
$(foreach p, $(call to-upper, $(TREBLE_PARTITIONS)), \
	$(eval BOARD_$(p)IMAGE_EXTFS_INODE_COUNT := 5120))

$(foreach p, $(call to-upper, $(SSI_PARTITIONS)), \
	$(eval BOARD_$(p)IMAGE_PARTITION_RESERVED_SIZE := 83886080)) # 80 MB
$(foreach p, $(call to-upper, $(TREBLE_PARTITIONS)), \
	$(eval BOARD_$(p)IMAGE_PARTITION_RESERVED_SIZE := 41943040)) # 40 MB

ifneq ($(WITH_GMS),true)
BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 1287651328 # 1228 MB
endif

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/odm.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/product.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/system_ext.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom

# Releasetools
TARGET_RECOVERY_UPDATER_LIBS := librecovery_updater_RMX1801
TARGET_RELEASETOOLS_EXTENSIONS := $(DEVICE_PATH)

# RIL
ENABLE_VENDOR_RIL_SERVICE := true
PROTOBUF_SUPPORTED := true

# Root Directories
BOARD_ROOT_EXTRA_SYMLINKS := \
    /mnt/vendor/persist:/persist \
    /vendor/bt_firmware:/bt_firmware \
    /vendor/dsp:/dsp \
    /vendor/firmware_mnt:/firmware

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(DEVICE_PATH)

# Security patch level
VENDOR_SECURITY_PATCH := 2020-10-05

# Treble
BOARD_VNDK_VERSION := current

# Sepolicy
include device/qcom/sepolicy-legacy-um/SEPolicy.mk
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Verity
# Only needed for signing
BOARD_AVB_ENABLE := false

# WiFi
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_DRIVER_DEFAULT := qca_cld3
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wlan"
WIFI_DRIVER_STATE_OFF := "OFF"
WIFI_DRIVER_STATE_ON := "ON"
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

# Inherit from the proprietary version
-include vendor/realme/RMX1801/BoardConfigVendor.mk
