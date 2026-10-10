#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=./AppDir/bin/resources/app.asar.unpacked/assets/icon.png
export DESKTOP=./AppDir/share/applications/gemini.desktop

mkdir -p ./AppDir/share/applications/
cat << 'EOF' > ./AppDir/share/applications/gemini.desktop
[Desktop Entry]
Name=Gemini
Exec=gemini %U
Terminal=false
Type=Application
Icon=gemini
StartupWMClass=Gemini
Comment=Standalone Native Desktop Client for Gemini
Categories=Utility;
EOF

quick-sharun ./AppDir/bin/* /usr/lib/libnss_nis.so* /usr/lib/libnsl.so* /usr/lib/libnss_mdns*_minimal.so*

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
