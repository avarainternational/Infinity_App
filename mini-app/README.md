# Infinity Reward Shop

Vue 3 + Vite + Capacitor 8 prototype, built as a separate mini-app alongside the Flutter project.

Public deployment: https://flutter-mini-f42jdfr8z-tunaunglwin-devs-projects.vercel.app/

## Try it

```powershell
cd D:\Infinity_App_Main\Infinity_App-main\mini-app
npm install
npm run dev
```

Open the local URL printed by Vite. The shop includes four rewards, category filters, reward details, confirmation, insufficient-points handling, saved redemption history and a confirmed demo reset. The initial demo balance is 1,250 points.

## Embed in Flutter

```powershell
cd D:\Infinity_App_Main\Infinity_App-main\mini-app
npm run build:flutter
cd ..
flutter pub get
flutter run
```

In the mobile app, choose **Mini-Apps > Reward Shop > Open Module**. The Flutter route is `/mini-apps/reward-shop`.

`build:flutter` creates a single self-contained HTML bundle and copies it to `assets/mini_apps/reward_shop/index.html` in the Flutter repository. Re-run it after Vue changes, then rebuild/restart Flutter. No web server, external font, CDN, or network connection is required by the bundled shop.

Flutter uses `webview_flutter` to host the web build on Android/iOS (and supported macOS targets). It does not embed a second Capacitor runtime. Capacitor packages the same Vue source as a standalone Android app. Windows/Linux/Flutter web show a fallback message; use Vite for the browser preview. iOS builds require macOS/Xcode and have not been verified here.

## Standalone Capacitor Android

```powershell
npm run android:sync
npm run android:open
```

The Android project is already generated. Capacitor 8 requires Node 22+, Java 21 and Android SDK 36. Build/run with Android Studio. A debug APK is produced by running `gradlew.bat assembleDebug` inside `android`, with `JAVA_HOME` and `ANDROID_HOME` pointing to the installed tools.

## Data and host boundary

- Browser: localStorage. Capacitor native app: Preferences plugin. Flutter: a dedicated SharedPreferences key, accessed through a narrow JavaScript channel.
- The Flutter channel is `RewardShopHost.postMessage(JSON.stringify({ id, action, value }))`. Supported actions are `read` and `write`. Responses call `window.rewardShopReply({ id, value, error })`.
- The storage payload is `{ version: 1, balance, history: [{ id, rewardId, cost, date }] }`. A redemption uses a stable request ID so retries do not deduct twice. The catalog determines costs, and balances/history are validated when restored.
- These are local demo points, separate for each installation/browser. No authentication, real wallet calls, points earning, fulfillment, real vouchers, or server enforcement is implemented. The existing Flutter wallet and Home point balance are not changed by shop redemptions.
- A real integration must replace demo storage with an authenticated, atomic server redemption endpoint that owns pricing, balance checks and idempotency. Never let a web mini-app provide an authoritative wallet balance or privileged signing material.

## Checks

```powershell
npm test
npm run build:flutter
```

`tests/shop.test.js` covers deductions, persistence round-trip, repeated request IDs, exact-balance spending, insufficient funds and corrupt saved data.

## Deploy updates to Vercel

The Vercel project must use `mini-app` as its Root Directory, Vite as the framework, `npm run build` as the build command and `dist` as the output directory. After GitHub integration is enabled, each push to `main` starts a production deployment:

```powershell
cd D:\Infinity_App_Main
git add <changed-files>
git commit -m "Describe the Reward Shop update"
git push origin main
```

The browser deployment requires internet access. The installed Capacitor APK and the Flutter-bundled version use packaged web assets and continue working offline. For configuration, bridge message examples, offline rules, build commands and troubleshooting, see [`../context/reward-shop-capacitor-guide.md`](../context/reward-shop-capacitor-guide.md).

Main files: `src/App.vue` (flow), `src/RewardArt.vue` and `src/style.css` (visuals), `src/shop.js` (catalog and deductions), `src/storage.js` (platform storage adapter).

## Verification status (2026-09-06)

- Vue production build and all five deduction tests pass.
- Flutter analysis reports no issues; the existing shell/navigation widget test passed.
- Browser checks confirmed reward details, redemption from 1,250 to 750 points, history after reload, disabled redemption with insufficient points, reset, and phone-sized layout.
- Standalone Capacitor debug APK: `android/app/build/outputs/apk/debug/app-debug.apk`. Its web bundle matches the Vue build and Flutter asset.
- The main Flutter debug APK build stalled in Gradle and was stopped; the older APK in the Flutter build folder is not a verified build of this change.
- No Android device/emulator was connected. Embedded native runtime behavior and iOS remain unverified.
