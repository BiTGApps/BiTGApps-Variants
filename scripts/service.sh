#!/system/bin/sh
#
# This file is part of The BiTGApps Project

# Set default module
MODULE="/data/adb/modules/BiTGApps"
# Magisk Current Base Folder
MIRROR="$(magisk --path)/.magisk/mirror"
# Mount actual partition
mount -o remount,rw,errors=continue / > /dev/null 2>&1
mount -o remount,rw,errors=continue /dev/root > /dev/null 2>&1
mount -o remount,rw,errors=continue /dev/block/dm-0 > /dev/null 2>&1
mount -o remount,rw,errors=continue /system > /dev/null 2>&1
# Mount mirror partition
mount -o remount,rw,errors=continue $MIRROR/system_root 2>/dev/null
mount -o remount,rw,errors=continue $MIRROR/system 2>/dev/null
# Set installation layout
SYSTEM="$MIRROR/system"
# Disable GooglePlayServices APK
rm -rf $SYSTEM/priv-app/PrebuiltGmsCore
# Enable GooglePlayServices APK
GMS="$MODULE/system/priv-app/PrebuiltGmsCore"
cp -fR $GMS $SYSTEM/priv-app/PrebuiltGmsCore
# Check module status
test -f "$MODULE/disable" || exit 1
# Purge runtime permissions
rm -rf $(find /data -type f -iname "runtime-permissions.xml")
