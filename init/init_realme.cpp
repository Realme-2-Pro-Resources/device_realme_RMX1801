/*
   Copyright (c) 2016, The CyanogenMod Project
   Copyright (c) 2019, The LineageOS Project

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <cstdlib>
#include <fstream>
#include <string.h>
#include <sys/sysinfo.h>
#include <unistd.h>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/strings.h>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include "vendor_init.h"
#include "property_service.h"

using android::base::Trim;
using android::base::ReadFileToString;

char const *heapstartsize;
char const *heapgrowthlimit;
char const *heapmaxfree;
char const *heaptargetutilization;

struct RMX180X_props
{
    std::string build_description;
    std::string build_fingerprint;
    std::string device_build;
    std::string product_device;
};

std::vector<std::string> ro_props_default_source_order = {
    "",
    "odm.",
    "system.",
    "system_ext.",
    "vendor.",
    "vendor_dlkm.",
};

void property_override(char const prop[], char const value[], bool add = true)
{
    auto pi = (prop_info *) __system_property_find(prop);

    if (pi != nullptr) {
        __system_property_update(pi, value, strlen(value));
    } else if (add) {
        __system_property_add(prop, strlen(prop), value, strlen(value));
    }
}

void setRMX(unsigned int variant)
{
    RMX180X_props prop[3] = {};

    std::string build_desc = "redfin-user 13 TQ2A.230405.003.B2 9760227 release-keys";
    std::string build_fingerprint = "google/redfin/redfin:13/TQ2A.230405.003.B2/9760227:user/release-keys";

    // RMX1801
    prop[0] = {
        build_desc,
        build_fingerprint,
        "RMX1801",
        "RMX1801",
    };

    // RMX1803
    prop[1] = {
        build_desc,
        build_fingerprint,
        "RMX1803",
        "RMX1803",
    };

    prop[2] = {
        build_desc,
        build_fingerprint,
        "RMX1807",
        "RMX1807",
    };

    const auto set_ro_build_prop = [](const std::string &source,
                                      const std::string &prop, const std::string &value) {
        auto prop_name = "ro." + source + "build." + prop;
        property_override(prop_name.c_str(), value.c_str(), false);
    };

    const auto set_ro_product_prop = [](const std::string &source,
                                        const std::string &prop, const std::string &value) {
        auto prop_name = "ro.product." + source + prop;
        property_override(prop_name.c_str(), value.c_str(), false);
    };

    property_override("ro.build.description", prop[variant].build_description.c_str());
    property_override("ro.build.fingerprint", prop[variant].build_fingerprint.c_str());
    property_override("ro.build.product", prop[variant].product_device.c_str());
    for (const auto &source : ro_props_default_source_order)
    {
        set_ro_build_prop(source, "fingerprint", prop[variant].build_fingerprint.c_str());
        set_ro_product_prop(source, "device", prop[variant].product_device.c_str());
        set_ro_product_prop(source, "model", prop[variant].device_build.c_str());
    }
}

void check_device()
{
    struct sysinfo sys;

    sysinfo(&sys);

    if (sys.totalram > 6144ull * 1024 * 1024) {
        // from - phone-xhdpi-8192-dalvik-heap.mk
        heapstartsize = "24m";
        heapgrowthlimit = "256m";
        heaptargetutilization = "0.46";
        heapmaxfree = "48m";
        setRMX(2);
    } else if (sys.totalram > 4096ull * 1024 * 1024) {
        // from - phone-xhdpi-6144-dalvik-heap.mk
        heapstartsize = "16m";
        heapgrowthlimit = "256m";
        heaptargetutilization = "0.5";
        heapmaxfree = "32m";
        setRMX(1);
    } else {
        // from - phone-xhdpi-4096-dalvik-heap.mk
        heapstartsize = "8m";
        heapgrowthlimit = "192m";
        heaptargetutilization = "0.6";
        heapmaxfree = "16m";
        setRMX(0);
    }
}

void init_alarm_boot_properties()
{
    char const *boot_reason_file = "/proc/sys/kernel/boot_reason";
    std::string boot_reason;

    if (ReadFileToString(boot_reason_file, &boot_reason)) {
        /*
         * Setup ro.alarm_boot value to true when it is RTC triggered boot up
         * For existing PMIC chips, the following mapping applies
         * for the value of boot_reason:
         *
         * 0 -> unknown
         * 1 -> hard reset
         * 2 -> sudden momentary power loss (SMPL)
         * 3 -> real time clock (RTC)
         * 4 -> DC charger inserted
         * 5 -> USB charger inserted
         * 6 -> PON1 pin toggled (for secondary PMICs)
         * 7 -> CBLPWR_N pin toggled (for external power supply)
         * 8 -> KPDPWR_N pin toggled (power key pressed)
         */
        if (Trim(boot_reason) == "0") {
            property_override("ro.boot.bootreason", "invalid");
            property_override("ro.alarm_boot", "false");
        }
        else if (Trim(boot_reason) == "1") {
            property_override("ro.boot.bootreason", "hard_reset");
            property_override("ro.alarm_boot", "false");
        }
        else if (Trim(boot_reason) == "2") {
            property_override("ro.boot.bootreason", "smpl");
            property_override("ro.alarm_boot", "false");
        }
        else if (Trim(boot_reason) == "3") {
            property_override("ro.alarm_boot", "true");
            // disable boot animation for RTC wakeup
            property_override("debug.sf.nobootanimation", "1");
        }
        else if (Trim(boot_reason) == "4") {
            property_override("ro.boot.bootreason", "dc_chg");
            property_override("ro.alarm_boot", "false");
        }
        else if (Trim(boot_reason) == "5") {
            property_override("ro.boot.bootreason", "usb_chg");
            property_override("ro.alarm_boot", "false");
        }
        else if (Trim(boot_reason) == "6") {
            property_override("ro.boot.bootreason", "pon1");
            property_override("ro.alarm_boot", "false");
        }
        else if (Trim(boot_reason) == "7") {
            property_override("ro.boot.bootreason", "cblpwr");
            property_override("ro.alarm_boot", "false");
        }
        else if (Trim(boot_reason) == "8") {
            property_override("ro.boot.bootreason", "kpdpwr");
            property_override("ro.alarm_boot", "false");
        }
    }
    else {
        LOG(ERROR) << "Unable to read bootreason from " << boot_reason_file;
    }
}

void vendor_load_properties()
{
    check_device();

    property_override("dalvik.vm.heapstartsize", heapstartsize);
    property_override("dalvik.vm.heapgrowthlimit", heapgrowthlimit);
    property_override("dalvik.vm.heapsize", "512m");
    property_override("dalvik.vm.heaptargetutilization", heaptargetutilization);
    property_override("dalvik.vm.heapminfree", "8m");
    property_override("dalvik.vm.heapmaxfree", heapmaxfree);

    // Safetyet Workaround
    property_override("ro.boot.verifiedbootstate", "green");
    property_override("ro.oem_unlock_supported", "0");

    property_override("ro.control_privapp_permissions", "log");

    init_alarm_boot_properties();
}
