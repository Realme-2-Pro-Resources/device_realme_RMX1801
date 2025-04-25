/*
 * SPDX-FileCopyrightText: 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <map>

#include "TouchscreenGesture.h"

namespace aidl {
namespace vendor {
namespace lineage {
namespace touch {

const std::map<int32_t, TouchscreenGesture::GestureInfo> kGestureInfoMap = {
    {0, {250, "Two fingers down swipe", "/proc/touchpanel/double_swipe_enable"}},
    {1, {251, "Up arrow", "/proc/touchpanel/up_arrow_enable"}},
    {2, {252, "Down arrow", "/proc/touchpanel/down_arrow_enable"}},
    {3, {253, "Left arrow", "/proc/touchpanel/left_arrow_enable"}},
    {4, {254, "Right arrow", "/proc/touchpanel/right_arrow_enable"}},
    {5, {63, "One finger up swipe", "/proc/touchpanel/up_swipe_enable"}},
    {6, {64, "One finger down swipe", "/proc/touchpanel/down_swipe_enable"}},
    {7, {65, "One finger left swipe", "/proc/touchpanel/left_swipe_enable"}},
    {8, {66, "One finger right swipe", "/proc/touchpanel/right_swipe_enable"}},
    {9, {247, "Letter M", "/proc/touchpanel/letter_m_enable"}},
    {10, {249, "Letter O", "/proc/touchpanel/letter_o_enable"}},
    {11, {246, "Letter W", "/proc/touchpanel/letter_w_enable"}},
};

}  // namespace touch
}  // namespace lineage
}  // namespace vendor
}  // namespace aidl
