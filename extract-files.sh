#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=RMX1801
VENDOR=realme

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
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
        system_ext/lib64/lib-imsvideocodec.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libqdMetaData.so" "libqdMetaData.system.so" "${2}"
            ;;
        vendor/lib/hw/camera.sdm660.so|vendor/lib/libarcvs.dep.so|vendor/lib/libmmcamera2_sensor_modules.so|vendor/lib/libmmcamera_interface.so)
            [ "$2" = "" ] && return 0
            sed -i 's|/system/etc/camera/|/vendor/etc/camera/|g' "${2}"
            ;;
        vendor/lib/libPerfectlyClearCrux.so|vendor/lib/libSonyIMX376RmscLibrary.so|vendor/lib/libSonyIMX519PdafLibrary.so|vendor/lib/libarcsoft_dualcam_bokeh_api.so|vendor/lib/libarcsoft_dualcam_refocus.so|vendor/lib/libarcsoft_dualcam_refocus_left.so|vendor/lib/libarcsoft_dualcam_refocus_preview.so|vendor/lib/libarcsoft_dualcam_refocus_right.so|vendor/lib/libarcsoft_smart_denoise.so|vendor/lib/libdepthmap.so|vendor/lib/libfilter.so|vendor/lib/libmmcamera_hdr_gb_lib.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF_0_17_2}" --replace-needed "libstdc++.so" "libstdc++_vendor.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
