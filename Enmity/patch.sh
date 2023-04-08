#!/bin/zsh

chdir Enmity

# Global variablse
VERSION=174.0_42188
BASE_IPA_NAME=Discord_$VERSION.ipa
DISCORD_IDS=1085420899907412028/1092882978117517373
IPA_LINK=https://cdn.discordapp.com/attachments/${DISCORD_IDS}/${BASE_IPA_NAME}

ENMITY_IPA_NAME=Enmity_v${VERSION}
K2GENMITY_IPA_NAME=K2GEnmity_v${VERSION}

ENMITY_DEB=$(ls Debs | grep En)
K2G_DEB=$(ls Debs | grep K2)
SCROLL_DEB=$(ls Debs | grep scroll)

PLIST=Payload/Discord.app/Info.plist

function print() {
	echo "\x1b[38;2;136;192;208m[*] $1\x1b[0m"
}

#-------------#
# Preparation #
#-------------#

# Wait for Discord IPA to download
if [[ -e "IPA/${BASE_IPA_NAME}" ]] then print "IPA already exists"
else
	print "Fetching IPA"
	curl -O --output-dir IPA --create-dirs ${IPA_LINK}
fi

# Clean up
print "Cleaning up"
rm -rf Dist
mkdir -p Dist
rm -rf Payload

# Wait for IPA to unzip
print "Unzipping..."
unzip -qq IPA/${BASE_IPA_NAME} & wait $!

#--------------#
# Modification #
#--------------#

print "Modifying IPA"

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
print "Packaging Enmity..."
zip -qr Dist/${ENMITY_IPA_NAME}.ipa Payload

print "Packaging K2GEnmity..."
plutil -replace NSFaceIDUsageDescription -string "K2genmity" ${PLIST}
zip -qr Dist/${K2GENMITY_IPA_NAME}.ipa Payload

rm -rf Payload

#-------#
# Patch #
#-------#

# Get Azule
if [[ -d "Azule" ]] then print "Azule already exists"
else
	print "Fetching Azule"
	git clone "https://github.com/Al4ise/Azule.git"
fi

# Inject tweaks
for IPA in Dist/*.ipa
do
	print "Injecting tweaks into ${IPA}"
	Azule/azule -i ${IPA} -f ${PWD}/Debs/${ENMITY_DEB} ${PWD}/Debs/${SCROLL_DEB} -o Dist
	mv $(echo ${IPA} | sed s/\.ipa//)+${ENMITY_DEB}+${SCROLL_DEB}.ipa ${IPA}
done

# Inject K2G
print "Injecting K2G"
Azule/azule -i Dist/${K2GENMITY_IPA_NAME}.ipa -f ${PWD}/Debs/${K2G_DEB} -o Dist
mv Dist/${K2GENMITY_IPA_NAME}+${K2G_DEB}.ipa Dist/${K2GENMITY_IPA_NAME}.ipa
