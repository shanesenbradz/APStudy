# Android app

A small native wrapper that shows `index.html` in a full-screen WebView. The app is stored inside the APK, so it works offline.

What the wrapper does:
- Loads the app from inside the APK and keeps progress, courses and photos on the phone.
- Opens the file picker for photos and course JSON files.
- Sends the back button to the app, so it closes dialogs and goes back a screen before leaving.
- Opens outside links, such as the YouTube channel, in the phone's browser.
- Follows the phone's light or dark mode.

The code is written in smali (in `smali/`), so it builds with Apktool alone, with no Android Studio or Android SDK.

## Build

1. Put `apktool.jar` and `uber-apk-signer.jar` in `android/tools/`.
2. Put your signing key `apstudy-release.jks` in `android/`. Never commit it.
3. Run `KS_PASS=yourpassword ./android/build-apk.sh`.

When you release an update, raise `versionCode` and `versionName` in `apktool.yml` and the `APStudyApp/` version in `MainActivity.smali`.
