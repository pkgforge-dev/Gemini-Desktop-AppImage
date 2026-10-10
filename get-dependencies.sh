#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm patchelf libnss_nis nss-mdns nss

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Getting binary..."
echo "---------------------------------------------------------------"

OMAHA_RESP=$(curl -s -d '<?xml version="1.0" encoding="UTF-8"?><request protocol="3.0"><os platform="win" version="10.0" arch="x64"/><app appid="{533DD80C-942A-4464-B6A9-2E59428D784E}" version="0.0.0.0" ap="prod"><updatecheck/></app></request>' "https://tools.google.com/service/update2")
link="$(echo "$OMAHA_RESP" | grep -oP '<url[^>]+codebase="\Khttps[^"]+' | head -n1)$(echo "$OMAHA_RESP" | grep -oP '<package[^>]+name="\K[^"]+')"

curl -sSfL --retry 30 --retry-connrefused "$link" -o /tmp/temp.exe
echo "$OMAHA_RESP" | grep -oP '<manifest[^>]+version="\K[^"]+' > ~/version

echo "Preparing AppDir..."
mkdir -p ./AppDir/bin
7z x /tmp/temp.exe "app-*/resources/*" -y "-xr!*.node" "-xr!*.exe" "-xr!*.dll" -o./AppDir/bin/
mv ./AppDir/bin/app-*/resources ./AppDir/bin/resources
rm -rf ./AppDir/bin/app-*

E_VERSION=v$(grep -a -oP '"electron":\s*"\^?\K[0-9.]+' ./AppDir/bin/resources/app.asar.unpacked/package.json | head -n 1)
if [ "$ARCH" = "x86_64" ]; then
    E_ARCH="x64"
elif [ "$ARCH" = "aarch64" ]; then
    E_ARCH="arm64"
fi

curl -sSfL "https://github.com/electron/electron/releases/download/${E_VERSION}/electron-${E_VERSION}-linux-${E_ARCH}.zip" | bsdtar -xf - -C ./AppDir/bin/
mv ./AppDir/bin/electron ./AppDir/bin/gemini

mkdir -p ./AppDir/share/icons/hicolor/256x256/apps/
mv ./AppDir/bin/resources/app.asar.unpacked/assets/icon.png ./AppDir/share/icons/hicolor/256x256/apps/gemini.png
