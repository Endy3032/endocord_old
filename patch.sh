#!/bin/bash
# enmity patch remake by rosie <3333

# global variables used >>>
VERSION=157
IPA_NAME=Discord_${VERSION}
IPA_DIR=Ipas/$IPA_NAME.ipa

### enmity patching :)
## output directory of patched ipa
mkdir -p Dist/
rm -rf Dist/*


# remove payload incase it exists
rm -rf Payload

echo "[*] Directory of IPA: $IPA_DIR"


## unzip the ipa and wait for it to finish unzipping
unzip $IPA_DIR &
wait $!

# set the main path to the payload plist in a variable for ease of use
MAIN_PLIST=Payload/Discord.app/Info.plist

# patch discord's name
plutil -replace CFBundleName -string "Enmity" $MAIN_PLIST
plutil -replace CFBundleDisplayName -string "Enmity" $MAIN_PLIST

# patch discord's url scheme to add enmity's url handler
plutil -insert CFBundleURLTypes.1 -xml "<dict><key>CFBundleURLName</key><string>Enmity</string><key>CFBundleURLSchemes</key><array><string>enmity</string></array></dict>" $MAIN_PLIST

# remove discord's device limits
plutil -remove UISupportedDevices $MAIN_PLIST

# patch itunes and files
plutil -replace UISupportsDocumentBrowser -bool true $MAIN_PLIST
plutil -replace UIFileSharingEnabled -bool true $MAIN_PLIST

zip -r dist/Enmity_v${VERSION}.ipa Payload

# change the font and remove the payload and ipa
rm -rf Payload

# go back to main dir
cd ..
[[ -e "Enmity_Patches/$PATCH_NAME.deb" ]] && echo "[*] '$PATCH_NAME.deb' has been built successfully." || echo "[*] Error when building '$PATCH_NAME.deb'. Continuing anyway."

# patch the ipa with the dylib tweak (using azule)
[[ -d "Azule" ]] && echo "[*] Azule already exists" || git clone https://github.com/Al4ise/Azule &
wait $!

# inject all of the patches into the enmity ipa
for Patch in $(ls Enmity_Patches/Required)
do
    Azule/azule -i Dist/Enmity_v${VERSION}.ipa -o Dist -f Enmity_Patches/Required/${Patch} &
    wait $!
    mv Dist/Enmity_v${VERSION}+${Patch}.ipa Dist/Enmity_v${VERSION}.ipa
done

# create a new ipa with each pack injected from the base ipa
for Pack in $(ls Packs)
do
    unzip Dist/Enmity_v${VERSION}.ipa
    cp -rf Packs/${Pack}/* Payload/Discord.app/assets/
    zip -r Dist/Enmity_v${VERSION}+${Pack}_Icons.ipa Payload
    rm -rf Payload
done
