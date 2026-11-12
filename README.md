# A+ Study Lab

A free study app for the CompTIA A+ Core 1 (220-1201) and Core 2 (220-1202) exams, with Linux+ (XK0-006) and Project+ (PK0-005) built in as extra courses.

## Download

| | |
|---|---|
| **Android app** | [![Download the Android app](https://img.shields.io/github/v/release/shanesenbradz/APStudy?label=Download%20APK&logo=android&style=for-the-badge&color=3DDC84)](https://github.com/shanesenbradz/APStudy/releases/latest/download/APStudy.apk) |
| **Use it in your browser** | [![Open the web app](https://img.shields.io/badge/Open-web%20app-0A62CC?style=for-the-badge&logo=googlechrome&logoColor=white)](https://shanesenbradz.github.io/APStudy/) |

The **Download APK** button always gets the newest Android version. Open it on your phone, tap the file when it finishes, then tap **Install**. The first time, Android asks you to allow installs from your browser or file manager. Needs Android 7.0 or newer.

Older versions and release notes: [all releases](https://github.com/shanesenbradz/APStudy/releases).

## What's inside

- A+: 9 modules, 46 concepts, 322 practice questions, 215 flashcards
- Linux+: 5 modules, 26 concepts, 322 practice questions, 156 flashcards
- Project+: 4 modules, 25 concepts, 322 practice questions, 120 flashcards
- Switch courses in Settings, Course Library. Each course keeps its own progress
- Learn, Flashcards and Quiz modes for every concept
- Multiple choice, true/false, matching, ordering and calculation questions
- Wrong answers come back once in the same round
- Weak spots quiz and progress per concept, module and overall
- Make your own courses from any PDF with an AI chat, and switch between them in a course library
- Background photo (JPG, PNG, HEIC, WebP and more) and colour themes
- Light and dark mode, glass or classic style
- Works offline once opened
- Android app (APK) included

## Use it

**Online:** open [shanesenbradz.github.io/APStudy](https://shanesenbradz.github.io/APStudy/) and start studying.

**Install it as an app:**
- Android (Chrome): open the link, tap the menu, then **Install app** (or **Add to Home screen**).
- iPhone or iPad (Safari): tap **Share**, then **Add to Home Screen**.
- Windows or Mac (Chrome or Edge): click the install icon in the address bar, or go to Settings in the app and choose **Install as an app**.

**Android app:** use the **Download APK** button at the top of this page, or open the [latest release](https://github.com/shanesenbradz/APStudy/releases/latest) and tap **APStudy.apk** under Assets. Installing a new version over the old one keeps your progress.

**Download a single file:** save `index.html` and open it in any browser. It works with no internet.

## Your progress

Progress is saved in your browser on your device. Nothing is sent anywhere. Clearing your browser data clears your progress.

## Change the content

The A+ content sits in one block in `index.html`, between `COURSE DATA` and `END OF COURSE DATA`. Linux+ and Project+ follow it in `window.BUILTIN_COURSES`, each as `{ id, color, data }` in the same course format. You can also add your own course inside the app:

1. Go to **Settings**, then **Add your own course**, and tap **Copy AI prompt**.
2. Paste the prompt into any AI chat and attach your PDF or notes.
3. Paste the JSON it gives back into the box (or open it as a `.json` file) and tap **Load course**.

Every course you load goes into the **Course library** in Settings. Tap one to switch to it. Each course keeps its own progress, and the built-in A+, Linux+ and Project+ courses are always there.

## Privacy

No accounts, ads or tracking. Read the [privacy policy](https://shanesenbradz.github.io/APStudy/privacy.html).

## Disclaimer

This is original practice content written for beginners. It is not affiliated with or endorsed by CompTIA. CompTIA, A+, Linux+ and Project+ are trademarks of CompTIA, Inc. Check the official exam objectives before you book your exam.
