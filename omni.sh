#!/bin/bash
#
# Copyright (C) 2018-2022 The BiTGApps Project
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#

# Check existance of required tools and notify user of missing tools
command -v grep >/dev/null 2>&1 || { echo "! GREP is required but it's not installed. Aborting..." >&2; exit 1; }
command -v install >/dev/null 2>&1 || { echo "! Coreutils is required but it's not installed. Aborting..." >&2; exit 1; }
command -v java >/dev/null 2>&1 || { echo "! JAVA is required but it's not installed. Aborting..." >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "! TAR is required but it's not installed. Aborting..." >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "! ZIP is required but it's not installed. Aborting..." >&2; exit 1; }

# replace_line <file> <line replace string> <replacement line>
replace_line() {
  if grep -q "$2" $1; then
    local line=$(grep -n "$2" $1 | head -n1 | cut -d: -f1)
    sed -i "${line}s;.*;${3};" $1
  fi
}

# Runtime Variables
ARCH="$1"
API="$2"

# Build Defaults
BUILDDIR="build"
OUTDIR="out"
TYPE="GApps"

# Common Sources
ALLSOURCES="sources/common-sources"

# GApps Sources
SOURCESv24="sources/$ARCH-sources/24"
SOURCESv25="sources/$ARCH-sources/25"
SOURCESv26="sources/$ARCH-sources/26"
SOURCESv27="sources/$ARCH-sources/27"
SOURCESv28="sources/$ARCH-sources/28"
SOURCESv29="sources/$ARCH-sources/29"
SOURCESv30="sources/$ARCH-sources/30"
SOURCESv31="sources/$ARCH-sources/31"
SOURCESv32="sources/$ARCH-sources/32"
SOURCESv33="sources/$ARCH-sources/33"

# SetupWizard Sources
SETUPSOURCESv24="sources/setup-sources/$ARCH/24"
SETUPSOURCESv25="sources/setup-sources/$ARCH/25"
SETUPSOURCESv26="sources/setup-sources/$ARCH/26"
SETUPSOURCESv27="sources/setup-sources/$ARCH/27"
SETUPSOURCESv28="sources/setup-sources/$ARCH/28"
SETUPSOURCESv29="sources/setup-sources/$ARCH/29"
SETUPSOURCESv30="sources/setup-sources/$ARCH/30"
SETUPSOURCESv31="sources/setup-sources/$ARCH/31"
SETUPSOURCESv32="sources/setup-sources/$ARCH/32"
SETUPSOURCESv33="sources/setup-sources/$ARCH/33"

# Variants Sources
VARIANTv64="sources/addon-sources"
VARIANTv32="sources/legacy-sources"

# Installation Scripts
UPDATEBINARY="scripts/update-binary.sh"
UPDATERSCRIPT="scripts/updater-script.sh"
INSTALLER="scripts/installer.sh"
OTASCRIPT="scripts/70-bitgapps.sh"
MODULEPROBE="scripts/module.sh"
MODULESCRIPT="scripts/uninstall.sh"
CUSTOMSCRIPT="scripts/customize.sh"
UTILITYSCRIPT="scripts/util_functions.sh"
SERVICE="scripts/service.sh"
MANAGER="scripts/manager.sh"

# Installation Tools
BUSYBOX="tools/busybox/busybox-arm"
ZIPSIGNER="tools/zipsigner/zipsigner.jar"

# Set ZIP Structure
METADIR="META-INF/com/google/android"
ZIP="zip"
CORE="$ZIP/core"
SYS="$ZIP/sys"
FRAMEWORK="$ZIP/framework"
OVERLAY="$ZIP/overlay"

buildprop() {
echo 'CustomGAppsPackage=BiTGApps
platform=
sdk=
version=
BuildDate=
BuildID=
Developer=TheHitMan7' >"$BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop"
}

# Stores the Metadata of the Module
moduleprop() {
echo 'id=BiTGApps-Android
name=BiTGApps for Android
author=TheHitMan7' >"$BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/module.prop"
}

makelicense() {
echo "This BiTGApps build is provided ONLY as courtesy by The BiTGApps Project and is without warranty of ANY kind.

This build is authored by TheHitMan7 and is as such protected by The BiTGApps Project's copyright.
This build is provided under the terms that it can be freely used for personal use only and is not allowed to be mirrored to the public other than author.
You are not allowed to modify this build for further (re)distribution.

The APKs found in this build are developed and owned by Google Inc.
They are included only for your convenience, neither TheHitMan7 and The BiTGApps Project have no ownership over them.
The user self is responsible for obtaining the proper licenses for the APKs, e.g. via Google's Play Store.
To use Google's applications you accept to Google's license agreement and further distribution of Google's application
are subject of Google's terms and conditions, these can be found at http://www.google.com/policies/

BusyBox is subject to the GPLv2, its license can be found at https://www.busybox.net/license.html

Any other intellectual property of this build, like e.g. the file and folder structure and the installation scripts are part of The BiTGApps Project and are subject
to the GPLv3. The applicable license can be found at https://www.gnu.org/licenses/gpl-3.0.txt" >"$BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/LICENSE"
}

# Create build directory
test -d $BUILDDIR || mkdir $BUILDDIR
test -d $BUILDDIR/$TYPE || mkdir $BUILDDIR/$TYPE
test -d $BUILDDIR/$TYPE/$ARCH || mkdir $BUILDDIR/$TYPE/$ARCH
# Create out directory
test -d $OUTDIR || mkdir $OUTDIR
test -d $OUTDIR/$TYPE || mkdir $OUTDIR/$TYPE
test -d $OUTDIR/$TYPE/$ARCH || mkdir $OUTDIR/$TYPE/$ARCH
# Platform ARM
if [ "$ARCH" == "arm" ]; then
  # Install variable; Do not modify
  TARGET_ANDROID_ARCH='"ARM"'
  # Build property variable; Do not modify
  platform="arm"
  # API 25
  if [ "$API" == "25" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"25"'
    # Installation size; Do not modify
    CAPACITY='"590000"'
    # Build property variable; Do not modify
    sdk="25"
    version="7.1.1"
    # Android Release Version; Do not modify
    releaseCode='"7.1.1"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-7.1.1-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-7.1.1-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv24/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv24/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv24/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv24/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv24/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv24/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 25
  if [ "$API" == "25" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"25"'
    # Installation size; Do not modify
    CAPACITY='"590000"'
    # Build property variable; Do not modify
    sdk="25"
    version="7.1.2"
    # Android Release Version; Do not modify
    releaseCode='"7.1.2"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-7.1.2-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-7.1.2-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv25/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 26
  if [ "$API" == "26" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"26"'
    # Installation size; Do not modify
    CAPACITY='"620000"'
    # Build property variable; Do not modify
    sdk="26"
    version="8.0.0"
    # Android Release Version; Do not modify
    releaseCode='"8.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-8.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-8.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv26/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv26/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv26/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv26/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv26/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv26/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 27
  if [ "$API" == "27" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"27"'
    # Installation size; Do not modify
    CAPACITY='"620000"'
    # Build property variable; Do not modify
    sdk="27"
    version="8.1.0"
    # Android Release Version; Do not modify
    releaseCode='"8.1.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-8.1.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-8.1.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv27/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv27/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv27/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv27/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv27/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv27/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 28
  if [ "$API" == "28" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"28"'
    # Installation size; Do not modify
    CAPACITY='"690000"'
    # Build property variable; Do not modify
    sdk="28"
    version="9.0.0"
    # Android Release Version; Do not modify
    releaseCode='"9.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-9.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-9.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv28/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv28/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv28/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv28/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv28/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv28/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv28/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 29
  if [ "$API" == "29" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"29"'
    # Installation size; Do not modify
    CAPACITY='"705000"'
    # Build property variable; Do not modify
    sdk="29"
    version="10.0.0"
    # Android Release Version; Do not modify
    releaseCode='"10.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-10.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-10.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv29/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv29/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv29/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv29/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv29/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv29/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 30
  if [ "$API" == "30" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"30"'
    # Installation size; Do not modify
    CAPACITY='"650000"'
    # Build property variable; Do not modify
    sdk="30"
    version="11.0.0"
    # Android Release Version; Do not modify
    releaseCode='"11.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-11.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-11.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv30/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv30/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv30/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv30/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv30/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv30/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 31
  if [ "$API" == "31" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"31"'
    # Installation size; Do not modify
    CAPACITY='"680000"'
    # Build property variable; Do not modify
    sdk="31"
    version="12.0.0"
    # Android Release Version; Do not modify
    releaseCode='"12.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-12.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-12.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv31/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv31/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv31/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv31/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv31/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv31/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 32
  if [ "$API" == "32" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"32"'
    # Installation size; Do not modify
    CAPACITY='"680000"'
    # Build property variable; Do not modify
    sdk="32"
    version="12.1.0"
    # Android Release Version; Do not modify
    releaseCode='"12.1.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-12.1.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-12.1.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv32/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv32/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv32/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv32/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv32/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv32/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 33
  if [ "$API" == "33" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"33"'
    # Installation size; Do not modify
    CAPACITY='"680000"'
    # Build property variable; Do not modify
    sdk="33"
    version="13.0.0"
    # Android Release Version; Do not modify
    releaseCode='"13.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-13.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-13.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv33/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv33/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv33/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv33/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv33/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv33/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv32/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv32/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
fi
# Platform ARM64
if [ "$ARCH" == "arm64" ]; then
  # Install variable; Do not modify
  TARGET_ANDROID_ARCH='"ARM64"'
  # Build property variable; Do not modify
  platform="arm64"
  # API 25
  if [ "$API" == "25" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"25"'
    # Installation size; Do not modify
    CAPACITY='"590000"'
    # Build property variable; Do not modify
    sdk="25"
    version="7.1.1"
    # Android Release Version; Do not modify
    releaseCode='"7.1.1"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-7.1.1-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-7.1.1-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv24/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv24/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv24/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv24/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv24/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv24/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv24/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 25
  if [ "$API" == "25" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"25"'
    # Installation size; Do not modify
    CAPACITY='"590000"'
    # Build property variable; Do not modify
    sdk="25"
    version="7.1.2"
    # Android Release Version; Do not modify
    releaseCode='"7.1.2"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-7.1.2-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-7.1.2-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv25/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 26
  if [ "$API" == "26" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"26"'
    # Installation size; Do not modify
    CAPACITY='"625000"'
    # Build property variable; Do not modify
    sdk="26"
    version="8.0.0"
    # Android Release Version; Do not modify
    releaseCode='"8.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-8.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-8.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv26/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv26/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv26/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv26/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv26/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv26/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv26/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 27
  if [ "$API" == "27" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"27"'
    # Installation size; Do not modify
    CAPACITY='"625000"'
    # Build property variable; Do not modify
    sdk="27"
    version="8.1.0"
    # Android Release Version; Do not modify
    releaseCode='"8.1.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-8.1.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-8.1.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv27/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv27/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv27/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv27/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv27/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv27/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv27/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 28
  if [ "$API" == "28" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"28"'
    # Installation size; Do not modify
    CAPACITY='"705000"'
    # Build property variable; Do not modify
    sdk="28"
    version="9.0.0"
    # Android Release Version; Do not modify
    releaseCode='"9.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-9.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-9.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv28/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv28/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv28/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv28/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv28/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv28/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv28/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv28/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 29
  if [ "$API" == "29" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"29"'
    # Installation size; Do not modify
    CAPACITY='"705000"'
    # Build property variable; Do not modify
    sdk="29"
    version="10.0.0"
    # Android Release Version; Do not modify
    releaseCode='"10.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-10.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-10.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install app packages
    cp -f $SOURCESv29/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv29/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv29/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv29/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv29/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv29/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv29/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 30
  if [ "$API" == "30" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"30"'
    # Installation size; Do not modify
    CAPACITY='"645000"'
    # Build property variable; Do not modify
    sdk="30"
    version="11.0.0"
    # Android Release Version; Do not modify
    releaseCode='"11.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-11.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-11.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv30/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv30/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv30/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv30/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv30/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv30/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv30/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 31
  if [ "$API" == "31" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"31"'
    # Installation size; Do not modify
    CAPACITY='"675000"'
    # Build property variable; Do not modify
    sdk="31"
    version="12.0.0"
    # Android Release Version; Do not modify
    releaseCode='"12.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-12.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-12.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv31/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv31/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv31/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv31/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv31/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv31/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv31/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 32
  if [ "$API" == "32" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"32"'
    # Installation size; Do not modify
    CAPACITY='"675000"'
    # Build property variable; Do not modify
    sdk="32"
    version="12.1.0"
    # Android Release Version; Do not modify
    releaseCode='"12.1.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-12.1.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-12.1.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv32/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv32/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv32/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv32/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv32/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv32/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv32/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
  # API 33
  if [ "$API" == "33" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_SDK='"33"'
    # Installation size; Do not modify
    CAPACITY='"685000"'
    # Build property variable; Do not modify
    sdk="33"
    version="13.0.0"
    # Android Release Version; Do not modify
    releaseCode='"13.0.0"'
    echo "Generating BiTGApps package for $ARCH with API level $API"
    # Create release directory
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-${ARCH}-13.0.0-${RELEASE}"
    RELEASEDIR="BiTGApps-${ARCH}-13.0.0-${RELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCESv33/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv33/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCESv33/app/GoogleExtShared.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    # Install etc packages
    cp -f $ALLSOURCES/etc/Default.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Permissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Preferred.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $ALLSOURCES/etc/Sysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $ALLSOURCES/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    cp -f $ALLSOURCES/framework/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$FRAMEWORK
    # Install overlay package
    cp -f $ALLSOURCES/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Integrity Signing Certificate
    cp -f $ALLSOURCES/certificate/Certificate.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCESv33/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/Phonesky.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCESv33/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install SetupWizard packages
    cp -f $SETUPSOURCESv33/priv-app/GoogleRestore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SETUPSOURCESv33/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install OMNI Packages
    cp -f $VARIANTv64/Calculator/Calculator.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Calendar/Calendar.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Contacts/Contacts.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/DeskClock/DeskClock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Keyboard/Keyboard.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Markup/Markup.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Photos/Photos.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $VARIANTv64/Dialer/Dialer.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Gearhead/Gearhead.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Messaging.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Messaging/Services.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $VARIANTv64/Wellbeing/Wellbeing.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $OTASCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULEPROBE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MODULESCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $CUSTOMSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $UTILITYSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $SERVICE $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $MANAGER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    # Create utility script
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh CAPACITY="" CAPACITY="$CAPACITY"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh version="" version="$VERSION"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh versionCode="" versionCode="$VERSIONCODE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh releaseCode="" releaseCode="$releaseCode"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH"
    # Create build property file
    buildprop
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop version= version="$version"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
    # Metadata of the Module
    moduleprop
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}-OMNI.zip
    # Remove unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
fi
