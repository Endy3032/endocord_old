#!/bin/bash

# Global variablse
VERSION=164
IPA_NAME=Discord_$VERSION.ipa

IPA_DIR=IPA/$IPA_NAME
DISCORD_IDS=1011346757214543875/1069326339238273174

PLIST=Payload/Discord.app/Info.plist

#-------------#
# Preparation #
#-------------#

# Wait for Discord IPA to download
curl --create-dirs -O --output-dir IPA "https://cdn.discordapp.com/attachments/$DISCORD_IDS/$IPA_NAME" &
wait $!

# Clean up
mkdir -p Dist/
rm -rf Dist/*
rm -rf Payload

# Wait for IPA to unzip
unzip -qq $IPA_DIR > /dev/null &
wait $!

#--------------#
# Modification #
#--------------#

# App name
plutil -replace CFBundleName -string "Enmity" $PLIST
plutil -replace CFBundleDisplayName -string "Enmity" $PLIST

# Add Enmity URL scheme
plutil -insert CFBundleURLTypes.1 -xml "<dict><key>CFBundleURLName</key><string>Enmity</string><key>CFBundleURLSchemes</key><array><string>enmity</string></array></dict>" $PLIST

# Remove device limits
plutil -remove UISupportedDevices $PLIST

# Enable iTunes file sharing
plutil -replace UISupportsDocumentBrowser -bool true $PLIST
plutil -replace UIFileSharingEnabled -bool true $PLIST

# Replace Icons
cp -rf Icons/* Payload/Discord.app/assets/

# Package
zip -r dist/Enmity_v${VERSION}.ipa Payload
rm -rf Payload

#-------#
# Patch #
#-------#

# Get Azule
[[ -d "Azule" ]] && echo "[*] Azule already exists" || git clone https://github.com/Al4ise/Azule &
wait $!

# Inject tweaks
for Patch in $(ls Debs)
do
    Azule/azule -i Dist/Enmity_v${VERSION}.ipa -f Debs/${Patch} -o Dist &
    wait $!
    mv Dist/Enmity_v${VERSION}+${Patch}.ipa Dist/Enmity_v${VERSION}.ipa
done
