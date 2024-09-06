#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=RMX1801
VENDOR=realme

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        product/etc/permissions/vendor.qti.hardware.data.connection-V1.0-java.xml)
            sed -i 's|xml version="2.0"|xml version="1.0"|g' "${2}"
            ;;
        product/etc/permissions/vendor.qti.hardware.data.connection-V1.1-java.xml)
            sed -i 's|xml version="2.0"|xml version="1.0"|g' "${2}"
            ;;
        vendor/lib/hw/camera.sdm660.so|vendor/lib/libarcvs.dep.so|vendor/lib/libmmcamera2_sensor_modules.so|vendor/lib/libmmcamera_interface.so)
            sed -i 's|/system/etc/camera/|/vendor/etc/camera/|g' "${2}"
            ;;
        vendor/lib/libSonyIMX519PdafLibrary.so|vendor/lib/libPerfectlyClearCrux.so|vendor/lib/libarcsoft_dualcam_bokeh_api.so|vendor/lib/libarcsoft_dualcam_refocus_left.so|vendor/lib/libmmcamera_hdr_gb_lib.so|vendor/lib/libdepthmap.so|vendor/lib/libarcsoft_dualcam_refocus_right.so|vendor/lib/libarcsoft_dualcam_refocus_preview.so|vendor/lib/libfilter.so|vendor/lib/libSonyIMX376RmscLibrary.so|vendor/lib/libarcsoft_smart_denoise.so|vendor/lib/libarcsoft_dualcam_refocus.so)
            "${PATCHELF}" --replace-needed "libstdc++.so" "libstdc++_vendor.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" ${KANG} --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
