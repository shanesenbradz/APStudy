#!/usr/bin/env bash
# Builds the A+ Study Lab APK from index.html.
# Needs Java 17 or newer, plus these two files in android/tools/:
#   apktool.jar          https://github.com/iBotPeaches/Apktool/releases
#   uber-apk-signer.jar  https://github.com/patrickfav/uber-apk-signer/releases
# Signing key: put apstudy-release.jks in android/ (never commit it) and run
#   KS_PASS=yourpassword ./android/build-apk.sh
set -euo pipefail
cd "$(dirname "$0")"
rm -rf build && mkdir -p build/app/assets/icons
cp -r AndroidManifest.xml apktool.yml res smali build/app/
cp ../index.html ../manifest.webmanifest build/app/assets/
cp ../icons/*.png build/app/assets/icons/
java -jar tools/apktool.jar b build/app -o build/unsigned.apk
java -jar tools/uber-apk-signer.jar -a build/unsigned.apk \
  --ks apstudy-release.jks --ksAlias apstudy --ksPass "$KS_PASS" --ksKeyPass "$KS_PASS" -o build/signed
mv build/signed/*-signed.apk ../APStudy.apk
echo "Built APStudy.apk"
