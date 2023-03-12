#!/bin/bash
#
# This file is part of The BiTGApps Project

# Create BiTGApps
mkdir BiTGApps

# Clone Build Sources
git clone https://github.com/BiTGApps/BiTGApps-Variants BiTGApps

# Create Sources
mkdir BiTGApps/sources

# Clone Package Sources
git clone https://github.com/BiTGApps/arm-sources BiTGApps/sources/arm-sources
git clone https://github.com/BiTGApps/arm64-sources BiTGApps/sources/arm64-sources
git clone https://github.com/BiTGApps/common-sources BiTGApps/sources/common-sources
git clone https://github.com/BiTGApps/setup-sources BiTGApps/sources/setup-sources

# Clone Variant Sources
git clone https://github.com/BiTGApps/addon-sources BiTGApps/sources/addon-sources
git clone https://github.com/BiTGApps/Legacy-Sources BiTGApps/sources/legacy-sources

# Update OMNI Scripts
if [ "$1" == "omni" ]; then
  # BACKUP
  sed -i -e "s/DESKCLOCK/DeskClock/g" BiTGApps/scripts/70-bitgapps.sh
  sed -i -e "s/KEYBOARD/Keyboard/g" BiTGApps/scripts/70-bitgapps.sh
  # RESTORE
  sed -i -e "s/CLOCK/Clock/g" BiTGApps/scripts/70-bitgapps.sh
  sed -i -e "s/LATINIME/LatinIME/g" BiTGApps/scripts/70-bitgapps.sh
  sed -i -e "s/GALLERY/Gallery/g" BiTGApps/scripts/70-bitgapps.sh
  # INSTALL
  sed -i -e "s/CLOCK/Clock/g" BiTGApps/scripts/installer.sh
  sed -i -e "s/LATINIME/LatinIME/g" BiTGApps/scripts/installer.sh
  sed -i -e "s/GALLERY/Gallery/g" BiTGApps/scripts/installer.sh
fi
