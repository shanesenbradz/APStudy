#!/usr/bin/env bash
# Builds the A+ Study Lab app from index.html:
#   APStudy.apk  for direct installs (GitHub release)
#   APStudy.aab  for the Google Play Store
#
# Needs Java 17 or newer, plus these files in android/tools/:
#   apktool.jar          https://github.com/iBotPeaches/Apktool/releases
#   uber-apk-signer.jar  https://github.com/patrickfav/uber-apk-signer/releases
#   bundletool.jar       https://github.com/google/bundletool/releases
#   aapt2                Linux aapt2 binary (Android SDK build-tools, or the npm package aaptjs3)
#   android-36.jar       Android 16 platform jar (Android SDK platforms/android-36/android.jar)
#
# Signing key: put apstudy-release.jks in android/ (never commit it) and run
#   KS_PASS=yourpassword ./android/build-apk.sh
#
# Version: versionCode and versionName in apktool.yml, and the APStudyApp/ version in smali/.../MainActivity.smali
set -euo pipefail
cd "$(dirname "$0")"
T=tools
VCODE=$(grep -E "^\s*versionCode:" apktool.yml | sed -E "s/[^0-9]//g")
VNAME=$(grep -E "^\s*versionName:" apktool.yml | sed -E "s/.*versionName:\s*'?([^']*)'?.*/\1/")
MINSDK=$(grep -E "^\s*minSdkVersion:" apktool.yml | sed -E "s/[^0-9]//g")
TARGET=$(grep -E "^\s*targetSdkVersion:" apktool.yml | sed -E "s/[^0-9]//g")
echo "Building $VNAME ($VCODE), target API $TARGET"

rm -rf build && mkdir -p build/app/assets/icons
cp -r AndroidManifest.xml apktool.yml res smali build/app/
cp ../index.html ../manifest.webmanifest build/app/assets/
cp ../icons/*.png build/app/assets/icons/

# APK
java -jar $T/apktool.jar b build/app -o build/unsigned.apk
java -jar $T/uber-apk-signer.jar -a build/unsigned.apk \
  --ks apstudy-release.jks --ksAlias apstudy --ksPass "$KS_PASS" --ksKeyPass "$KS_PASS" -o build/signed
mv build/signed/*-signed.apk ../APStudy.apk
# Android 11+ refuses APKs whose resources.arsc is compressed ("App not installed")
if unzip -v ../APStudy.apk resources.arsc | grep -q "Defl"; then
  echo "ERROR: resources.arsc is compressed in APStudy.apk"; exit 1
fi

# AAB (Play Store)
mkdir -p build/aab/mod/manifest build/aab/mod/dex
$T/aapt2 compile --dir res -o build/aab/res.zip
$T/aapt2 link --proto-format -o build/aab/base.apk -I $T/android-36.jar --manifest AndroidManifest.xml \
  --min-sdk-version "$MINSDK" --target-sdk-version "$TARGET" --version-code "$VCODE" --version-name "$VNAME" \
  -A build/app/assets --auto-add-overlay build/aab/res.zip
( cd build/aab && unzip -q base.apk -d tmp && mv tmp/AndroidManifest.xml mod/manifest/ && mv tmp/resources.pb tmp/res tmp/assets mod/ )
unzip -q -j build/unsigned.apk classes.dex -d build/aab/mod/dex/
( cd build/aab/mod && zip -q -r ../base.zip . )
java -jar $T/bundletool.jar build-bundle --modules=build/aab/base.zip --output=../APStudy.aab --overwrite
jarsigner -keystore apstudy-release.jks -storepass "$KS_PASS" -keypass "$KS_PASS" \
  -sigalg SHA256withRSA -digestalg SHA-256 ../APStudy.aab apstudy
java -jar $T/bundletool.jar validate --bundle=../APStudy.aab >/dev/null
echo "Built APStudy.apk and APStudy.aab"
