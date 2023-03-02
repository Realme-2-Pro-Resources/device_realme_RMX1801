#
# Copyright (C) 2019 The LineageOS Project
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

# Inherit some common AOSP stuff
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common BananaDroid stuff
$(call inherit-product, vendor/banana/config/common.mk)

# Inherit from Realme RMX1801
$(call inherit-product, device/realme/RMX1801/device.mk)

# Set Shipping API level
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_o_mr1.mk)

# Banana Flags
BANANA_MAINTAINER := irawansalt
TARGET_BOOT_ANIMATION_RES := 1080
TARGET_FACE_UNLOCK_SUPPORTED := true
WITH_GAPPS := true
BUILD_CORE_GAPPS := true
TARGET_INCLUDE_LIVE_WALLPAPERS := false
TARGET_INCLUDE_STOCK_ARCORE := false
TARGET_SUPPORTS_GOOGLE_RECORDER := true

PRODUCT_NAME := banana_RMX1801
PRODUCT_DEVICE := RMX1801
PRODUCT_MANUFACTURER := OPPO
PRODUCT_BRAND := oppo
PRODUCT_MODEL := Realme 2 Pro

PRODUCT_GMS_CLIENTID_BASE := android-oppo

TARGET_VENDOR_PRODUCT_NAME := RMX1801
TARGET_VENDOR_DEVICE_NAME := RMX1801

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="sdm660_64-user 10 QKQ1.191014.001 eng.root.20201016.161857 release-keys"

BUILD_FINGERPRINT := "OPPO/RMX1801/RMX1801:10/QKQ1.191014.001/1602573502:user/release-keys"
