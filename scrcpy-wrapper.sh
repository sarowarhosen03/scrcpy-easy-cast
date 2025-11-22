#!/bin/bash
set -e


SCRCPY="/usr/bin/adb-device-cast/scrcpy"


adb wait-for-device

ORIGINAL_TIMEOUT=$(adb shell settings get system screen_off_timeout)
adb shell settings put system screen_off_timeout 2147483647

"$SCRCPY" --stay-awake

adb shell settings put system screen_off_timeout $ORIGINAL_TIMEOUT
