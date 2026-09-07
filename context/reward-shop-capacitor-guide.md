# Reward Shop Mini-App: Capacitor, Flutter and Vercel Guide

Last updated: 2026-09-06

## 1. Purpose and current status

Reward Shop is a Vue 3 prototype where a user can browse rewards, spend local demo Wellness Points, see redemption history and reset the demo. The same Vue source supports three environments:

1. Public website on Vercel.
2. Standalone Android app packaged by Capacitor.
3. Embedded mini-app inside the Flutter Infinity Wellness shell.

The prototype does not deduct real Wallet funds. Each environment maintains a separate local demo balance.

Public deployment:

```text
https://flutter-mini-f42jdfr8z-tunaunglwin-devs-projects.vercel.app/
```

Repository:

```text
https://github.com/tunaunglwin-dev/Flutter_Mini_App.git
```

## 2. Architecture

```text
                         mini-app/src/
                    Vue components and logic
                               |
                          npm run build
                               |
                         mini-app/dist/
                  Single self-contained index.html
                    /            |             \
                   /             |              \
          Vercel publish   cap sync android    build:flutter
                |                 |                 |
          Public website    Capacitor APK     Flutter asset
                                                    |
                                               Flutter WebView
```

Capacitor and Flutter are separate native hosts. Flutter does not import Capacitor. They reuse the same compiled Vue application.

## 3. Important folders

```text
D:\Infinity_App_Main\Infinity_App-main\
├── assets\mini_apps\reward_shop\      Vue output bundled into Flutter
├── context\                            Engineering documentation
├── lib\app\features\mini_apps\reward_shop\
│   ├── binding\                        GetX registration
│   ├── controller\                     WebView and JSON storage bridge
│   └── screen\                         Flutter host screen
└── mini-app\
    ├── android\                        Capacitor Android project
    ├── scripts\sync-flutter.mjs        Copies web build into Flutter
    ├── src\                            Vue UI, catalog and storage adapter
    ├── capacitor.config.json           Capacitor configuration
    ├── package.json                    Packages and commands
    ├── vercel.json                     Vercel configuration
    └── vite.config.js                  Web build configuration
```

## 4. Vue and npm configuration

`mini-app/package.json` declares the dependencies and commands.

| Package | Responsibility |
| --- | --- |
| `vue` | Components and reactive UI |
| `lucide-vue-next` | UI icons |
| `@capacitor/core` | Capacitor runtime detection |
| `@capacitor/preferences` | Standalone native local storage |
| `vite` and Vue plugin | Development and production compilation |
| `vite-plugin-singlefile` | Embeds JS and CSS inside one HTML file |
| `@capacitor/cli` | `cap` development commands |
| `@capacitor/android` | Android runtime |

Important scripts:

```json
{
  "dev": "vite --host 127.0.0.1",
  "build": "vite build",
  "test": "node --test tests/*.test.js",
  "build:flutter": "npm run build && node scripts/sync-flutter.mjs",
  "android:sync": "npm run build && cap sync android",
  "android:open": "cap open android"
}
```

`vite.config.js` uses a relative base path and the single-file plugin. The result is `mini-app/dist/index.html`, containing the compiled Vue code, CSS and interface visuals. A single local file avoids broken script paths when loaded from a native package.

## 5. Capacitor configuration and installation

Capacitor is installed locally by running `npm install` in `mini-app`. Packages are placed under `mini-app/node_modules/@capacitor/` and resolved versions are recorded in `package-lock.json`.

`mini-app/capacitor.config.json`:

```json
{
  "appId": "com.infinitywellness.rewardshop",
  "appName": "Infinity Reward Shop",
  "webDir": "dist",
  "backgroundColor": "#eef5f5"
}
```

| Setting | Meaning |
| --- | --- |
| `appId` | Android package ID for the standalone app |
| `appName` | Android display name |
| `webDir` | Web output copied into the native app by `cap sync` |
| `backgroundColor` | Native background while the WebView loads |

There is intentionally no `server.url`. The standalone APK loads bundled files from `webDir`; it does not depend on Vercel or a development server.

The Android entry point is `mini-app/android/app/src/main/java/com/infinitywellness/rewardshop/MainActivity.java`. It extends Capacitor's `BridgeActivity`. Generated `android/capacitor.settings.gradle` links `@capacitor/android` and `@capacitor/preferences` from `node_modules`. Generated `android/app/capacitor.build.gradle` adds the Preferences plugin.

## 6. Where Capacitor is imported

`mini-app/src/storage.js` imports the APIs used by Vue:

```js
import { Capacitor } from '@capacitor/core';
import { Preferences } from '@capacitor/preferences';
```

The storage adapter chooses its host in this order:

1. `window.RewardShopHost` exists: use the Flutter JSON bridge.
2. `Capacitor.isNativePlatform()` is true: use Capacitor Preferences.
3. Otherwise: use browser `localStorage`, including Vercel.

Vue components therefore do not need different code for each host.

## 7. Flutter Mini-App Store configuration

The Flutter catalog is configured in Dart, not a JSON configuration file.

`lib/app/features/mini_app_store/controller/mini_app_store_controller.dart` contains the Reward Shop metadata: ID, title, category, icon, accent, description, features and version. Its launcher recognizes `reward-shop` and calls:

```dart
Get.toNamed<void>(Routes.rewardShop);
```

`lib/app/constant/routing/app_route.dart` defines:

```dart
static const rewardShop = '/mini-apps/reward-shop';
```

`lib/app/constant/routing/app_pages.dart` connects that route to `RewardShopScreen` and `RewardShopBinding`.

`pubspec.yaml` declares the Flutter WebView package and asset directory:

```yaml
dependencies:
  webview_flutter: ^4.13.0

flutter:
  assets:
    - assets/mini_apps/reward_shop/
```

The controller loads `assets/mini_apps/reward_shop/index.html`. Do not edit that generated HTML directly. Edit the Vue source, then run `npm run build:flutter`.

## 8. Flutter and Vue JSON bridge

The bridge only reads and writes prototype state. It is not a Wallet interface.

Vue sends JSON as a string:

```js
window.RewardShopHost.postMessage(JSON.stringify({
  id: '1',
  action: 'read'
}));
```

Example write request:

```json
{
  "id": "2",
  "action": "write",
  "value": "{\"version\":1,\"balance\":750,\"history\":[...]}"
}
```

Flutter replies by running JavaScript:

```js
window.rewardShopReply({
  id: '1',
  value: 'saved JSON or null',
  error: null
});
```

The request `id` links an asynchronous response to its request. The supported actions are `read` and `write`. Flutter stores data in SharedPreferences under `reward_shop_demo_v1` and validates message size, state version, balance range and history type.

Prototype state:

```json
{
  "version": 1,
  "balance": 750,
  "history": [
    {
      "id": "unique-request-id",
      "rewardId": "bottle",
      "cost": 500,
      "date": "2026-09-06T12:00:00.000Z"
    }
  ]
}
```

Stable request IDs prevent one user action from being deducted twice if the same request is retried.

## 9. Storage ownership

| Environment | Storage | Shared with other environments? |
| --- | --- | --- |
| Vercel/browser | Browser `localStorage` | No |
| Standalone Capacitor APK | Capacitor Preferences | No |
| Flutter embedded mini-app | Flutter SharedPreferences | No |

Every new browser profile or app installation starts with its own 1,250 demo points. Redeeming on Vercel does not update the standalone APK, Flutter Home or Flutter Wallet.

## 10. Offline behavior

The standalone Capacitor app works offline after installation, including first launch. Vue code, styles, icons, catalog, point prices, Capacitor runtime and Preferences plugin are packaged inside the APK.

The Flutter mini-app also works offline because its HTML is packaged as a Flutter asset and its demo state uses SharedPreferences.

The Vercel website requires internet to load. It is not currently an offline PWA and has no service worker. After it loads, the prototype interactions use browser-local data.

Real redemptions will require an authenticated backend and network access. The server must own prices, inventory, balance checks, atomic deduction, receipts and idempotency. Client storage must never be authoritative for real value.

## 11. Development and build workflows

First setup:

```powershell
cd D:\Infinity_App_Main\Infinity_App-main\mini-app
npm install
```

Local browser development:

```powershell
npm run dev
```

Update the Flutter embedded copy:

```powershell
cd D:\Infinity_App_Main\Infinity_App-main\mini-app
npm run build:flutter

cd ..\Infinity_App-main
flutter pub get
flutter analyze
flutter test test\widget_test.dart --reporter expanded
flutter build apk --debug
```

`build:flutter` runs Vite and then `scripts/sync-flutter.mjs`, which copies `dist/index.html` into `assets/mini_apps/reward_shop/index.html`. Rebuild/reinstall Flutter afterward; hot reload may retain an old asset bundle.

Update the standalone Capacitor Android app:

```powershell
cd D:\Infinity_App_Main\Infinity_App-main\mini-app
npm run android:sync
npm run android:open
```

`android:sync` rebuilds Vue and copies the output into the Android project. Build in Android Studio or run `gradlew.bat assembleDebug` from `mini-app/android` with Java 21 and Android SDK 36 configured.

Installing the standalone APK does not update Flutter. Run both workflows when both native packages need the same changes.

Run Reward Shop checks:

```powershell
cd D:\Infinity_App_Main\Infinity_App-main\mini-app
npm test
npm run build
```

## 12. Vercel deployment guide

Vercel settings:

| Setting | Value |
| --- | --- |
| Repository | `tunaunglwin-dev/Flutter_Mini_App` |
| Production branch | `main` |
| Root Directory | `mini-app` |
| Framework preset | Vite |
| Install command | Vercel default or `npm install` |
| Build command | `npm run build` |
| Output directory | `dist` |

`mini-app/vercel.json` records the framework, build command, output directory and response headers.

Normal update flow:

```powershell
cd D:\Infinity_App_Main
git status
git add <changed-files>
git commit -m "Describe the Reward Shop update"
git push origin main
```

When the GitHub repository is connected in Vercel, pushing `main` creates a production deployment automatically. In Vercel, open the project, select Deployments, confirm the newest commit is Ready, and open its production URL.

If Vercel builds the wrong project or displays a repository-level error, confirm Root Directory is exactly `mini-app`. Do not choose the workspace root or `Infinity_App-main`.

The generated Vercel address may change between preview deployments. In Vercel Project Settings > Domains, assign a stable production domain before sharing the final link broadly.

## 13. Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Reward Shop missing from Flutter | Old Flutter APK | Run `npm run build:flutter`, rebuild and reinstall Flutter |
| Blank embedded screen | Missing/stale asset or Android System WebView problem | Confirm generated HTML exists, rebuild, then update Android System WebView |
| Shop loading timeout | WebView did not finish loading | Reopen; inspect device logs if repeated |
| Save fails | Local storage/bridge failure or invalid saved state | Retry; reset demo if state is corrupt |
| 1,500-point kit is disabled | Balance is below its cost | Expected behavior |
| History disappeared | Browser/app data was cleared or app was uninstalled | Expected for local prototype storage |
| Vercel shows an old version | Deployment is building, wrong branch, or Git link is disconnected | Check latest `main` commit and deployment status |
| `cap` command missing | Dependencies are not installed | Run `npm install` inside `mini-app` |
| Capacitor APK shows old UI | Native assets were not synced | Run `npm run android:sync`, then rebuild |
| Flutter shows old UI | Vue output was not copied before Flutter build | Run `npm run build:flutter`, then rebuild |

## 14. Verification checklist

Browser/Vercel:

- [ ] Public URL opens without a local server.
- [ ] Fresh browser starts at 1,250 points.
- [ ] Redeeming the 500-point bottle leaves 750 points.
- [ ] History survives a refresh in the same browser profile.
- [ ] The 1,500-point kit is disabled at 750 points.
- [ ] Reset restores 1,250 points and empty history.

Standalone Capacitor Android:

- [ ] Install the latest debug APK.
- [ ] Enable airplane mode before first launch.
- [ ] Complete deduction, history and reset flows.
- [ ] Close/reopen and verify persistence.

Flutter embedded mini-app:

- [ ] Build Flutter after `npm run build:flutter`.
- [ ] Open Mini-Apps > Reward Shop > Open Module.
- [ ] Complete the flow in airplane mode.
- [ ] Verify Android Back returns to the Mini-App Store.

## 15. Production migration checklist

Before deductions become real:

- [ ] Add authenticated user/session handoff.
- [ ] Define typed server redemption requests and responses.
- [ ] Store catalog prices and inventory on the server.
- [ ] Validate balance and deduct atomically on the server.
- [ ] Enforce idempotency using the client request ID.
- [ ] Return a server-issued redemption ID and receipt.
- [ ] Add authenticated history and fulfillment state.
- [ ] Handle loading, offline, retry and reconciliation states.
- [ ] Add authorization/RLS policies and audit logging.
- [ ] Never expose service-role keys, signing secrets or privileged Wallet operations to Vue or the Flutter JavaScript channel.

Until these tasks are complete, all Reward Shop points and redemptions remain local prototype data.
