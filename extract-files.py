#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import extract_utils.tools

extract_utils.tools.DEFAULT_PATCHELF_VERSION = '0_9'

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
        'vendor.qti.imsrtpservice@3.0',
    ): lib_fixup_vendor_suffix,
    (
    ): lib_fixup_remove,
}

blob_fixups: blob_fixups_user_type = {
    'system_ext/lib64/lib-imsvideocodec.so': blob_fixup()
        .replace_needed('libqdMetaData.so', 'libqdMetaData.system.so'),
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
