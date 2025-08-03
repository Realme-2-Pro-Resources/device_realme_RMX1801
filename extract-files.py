#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import extract_utils.tools

extract_utils.tools.DEFAULT_PATCHELF_VERSION = '0_17_2'

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixup_remove,
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/realme/RMX1801',
    'hardware/qcom-caf/msm8998',
    'hardware/qcom-caf/wlan',
    'hardware/oppo',
    'vendor/qcom/opensource/dataservices',
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'com.qualcomm.qti.dpm.api@1.0',
        'com.qualcomm.qti.uceservice@2.0',
        'com.qualcomm.qti.uceservice@2.1',
        'com.qualcomm.qti.uceservice@2.2',
        'com.qualcomm.qti.uceservice@2.3',
        'vendor.qti.hardware.fm@1.0',
        'vendor.qti.hardware.qccsyshal@1.0',
        'vendor.qti.hardware.qccvndhal@1.0',
        'vendor.qti.imsrtpservice@3.0',
    ): lib_fixup_vendor_suffix,
    (
    ): lib_fixup_remove,
}

blob_fixups: blob_fixups_user_type = {
    'vendor/lib64/libwvhidl.so': blob_fixup()
        .add_needed('libcrypto_shim.so'),
    (
        'system_ext/lib64/lib-imscamera.so',
        'system_ext/lib64/lib-imsvideocodec.so',
    ): blob_fixup()
        .add_needed('libgui_shim.so')
        .replace_needed('libqdMetaData.so', 'libqdMetaData.system.so'),
    'vendor/lib/sensors.ssc.so': blob_fixup()
        .sig_replace('73 08 68 28 21', '73 08 68 f0 21')
        .sig_replace('6e 28 74', 'f0 28 74')
        .sig_replace('74 d1 9a f8 09 00', '74 d1 00 f0 46 b8')
        .sig_replace('08 28 00 f2 a3 80', '08 28 00 f2 6b 80'),
    'vendor/lib64/sensors.ssc.so': blob_fixup()
        .sig_replace('39 28 00 40 f9 09 05 80 52', '39 28 00 40 f9 09 1e 80 52')
        .sig_replace('1f b9 01 71 a1', '1f c1 03 71 a1' )
        .sig_replace('54 a8 02 16 8b 08 25 40 39 a8', '54 4a 00 00 14 08 25 40 39 a8')
        .sig_replace('7f b8 01 71 01 0b 00 54', '7f b8 01 71 a1 07 00 54'),
    (
        'vendor/lib/hw/camera.sdm660.so',
        'vendor/lib/libarcvs.dep.so',
        'vendor/lib/libmmcamera2_sensor_modules.so',
        'vendor/lib/libmmcamera_interface.so',
    ): blob_fixup()
        .binary_regex_replace(b'/system/etc/camera/', b'/vendor/etc/camera/'),
    (
        'vendor/lib/libPerfectlyClearCrux.so',
        'vendor/lib/libSonyIMX376RmscLibrary.so',
        'vendor/lib/libSonyIMX519PdafLibrary.so',
        'vendor/lib/libarcsoft_dualcam_bokeh_api.so',
        'vendor/lib/libarcsoft_dualcam_refocus.so',
        'vendor/lib/libarcsoft_dualcam_refocus_left.so',
        'vendor/lib/libarcsoft_dualcam_refocus_preview.so',
        'vendor/lib/libarcsoft_dualcam_refocus_right.so',
        'vendor/lib/libarcsoft_smart_denoise.so',
        'vendor/lib/libdepthmap.so',
        'vendor/lib/libfilter.so',
        'vendor/lib/libmmcamera_hdr_gb_lib.so',
    ): blob_fixup()
        .replace_needed('libstdc++.so', 'libstdc++_vendor.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'RMX1801',
    'realme',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
