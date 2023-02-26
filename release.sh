#!/bin/bash
#
# This file is part of The BiTGApps Project

github-release upload \
  --owner "BiTGApps" \
  --repo "BiTGApps-Variants" \
  --token "$TOKEN" \
  --tag "${RELEASE}" \
  --release-name "BiTGApps ${RELEASE}" \
  "out/GApps/arm/BiTGApps-arm-13.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-12.1.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-12.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-11.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-10.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-9.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-8.1.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-8.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-7.1.2-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm/BiTGApps-arm-7.1.1-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-13.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-12.1.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-12.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-11.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-10.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-9.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-8.1.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-8.0.0-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-7.1.2-${RELEASE}-${VARIANT}.zip" \
  "out/GApps/arm64/BiTGApps-arm64-7.1.1-${RELEASE}-${VARIANT}.zip"
