#!/bin/bash

# Global variablse
pwd
ls
VERSION=174.0_42188
IPA_NAME=Discord_$VERSION.ipa
DISCORD_IDS=1085420899907412028/1092882978117517373
ENMITY_DEB=$(ls Debs | grep En)
K2G_DEB=$(ls Debs | grep -i K2)
SCROLL_DEB=$(ls Debs | grep -i scroll)

PLIST=Payload/Discord.app/Info.plist

#-------------#
# Preparation #
#-------------#

# Wait for Discord IPA to download
# curl --create-dirs -O --output-dir IPA "https://cdn.discordapp.com/attachments/${DISCORD_IDS}/${IPA_NAME}"

# Clean up
mkdir -p Dist
rm -rf Dist/*
rm -rf Payload

# Wait for IPA to unzip
unzip -qq IPA/${IPA_NAME}

#--------------#
# Modification #
#--------------#

# App name
plutil -replace CFBundleName -string "Enmity" ${PLIST}
plutil -replace CFBundleDisplayName -string "Enmity" ${PLIST}

# Add Enmity URL scheme
plutil -insert CFBundleURLTypes.1 -xml "<dict><key>CFBundleURLName</key><string>Enmity</string><key>CFBundleURLSchemes</key><array><string>enmity</string></array></dict>" $PLIST

# Remove device limits
plutil -remove UISupportedDevices ${PLIST}

# Enable iTunes file sharing
plutil -replace UISupportsDocumentBrowser -bool true ${PLIST}
plutil -replace UIFileSharingEnabled -bool true ${PLIST}

# Replace Icons
cp -rf Icons/* Payload/Discord.app/assets/

# Package
zip -r dist/Enmity_v${VERSION}.ipa Payload
rm -rf Payload

#-------#
# Patch #
#-------#

# Get Azule
[[ -d "Azule" ]] && echo "[*] Azule already exists" || git clone https://github.com/Al4ise/Azule

# Inject tweaks
Azule/azule -i "Dist/Enmity_v${VERSION}.ipa" -f "${PWD}/Debs/${ENMITY_DEB}" "${PWD}/Debs/${SCROLL_DEB}" -e -o "Dist"
mv "Dist/Enmity_v${VERSION}+${ENMITY_DEB}+${SCROLL_DEB}.ipa" "Dist/Enmity_v${VERSION}.ipa"

Azule/azule -i "Dist/Enmity_v${VERSION}.ipa" -f "${PWD}/Debs/${K2G_DEB}" -e -o "Dist"
mv "Dist/Enmity_v${VERSION}+${K2G_DEB}.ipa" "Dist/Enmity_v${VERSION}_K2G.ipa"
