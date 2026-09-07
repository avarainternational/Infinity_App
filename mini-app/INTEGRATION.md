# How Reward Shop connects to Infinity Wellness

One Vue application has two native launch paths:

```text
Vue source (mini-app/src)
          |
      Vite build
          |
 dist/index.html (HTML + CSS + JavaScript + visuals bundled together)
          |
          +-- build:flutter --> Flutter asset --> Flutter WebView
          |
          +-- cap sync android --> Capacitor Android project --> standalone APK
```

## Is the main app registration a JSON file?

No. The Flutter Store registration is currently Dart code:

- `../lib/app/features/mini_app_store/controller/mini_app_store_controller.dart`: Reward Shop ID, title, description, category, icon, features and version. `launchModule` opens the Reward Shop route.
- `../lib/app/constant/routing/app_route.dart`: `/mini-apps/reward-shop` route name.
- `../lib/app/constant/routing/app_pages.dart`: route registration and GetX binding.
- `../lib/app/features/mini_apps/reward_shop/`: host binding, controller and screen.
- `../pubspec.yaml`: declares `webview_flutter` and the bundled asset directory.

The product catalog and point costs are JavaScript objects in `src/shop.js`. They are not downloaded from a server.

## Where is Capacitor configured and installed?

`capacitor.config.json` configures only the standalone Capacitor app:

```json
{
  "appId": "com.infinitywellness.rewardshop",
  "appName": "Infinity Reward Shop",
  "webDir": "dist",
  "backgroundColor": "#eef5f5"
}
```

`appId` is the standalone Android package identity, `appName` is its label, and `webDir` is the web build Capacitor copies into the native project. No remote `server.url` is configured.

`package.json` declares the npm packages and `package-lock.json` records resolved versions. `npm install` installs them locally under `mini-app/node_modules/@capacitor/`:

- `core`: runtime/platform detection.
- `preferences`: native local key/value storage.
- `cli`: development commands such as `cap sync android`.
- `android`: native Android runtime.

The actual web imports are in `src/storage.js`:

```js
import { Capacitor } from '@capacitor/core';
import { Preferences } from '@capacitor/preferences';
```

The native entry point is `android/app/src/main/java/com/infinitywellness/rewardshop/MainActivity.java`, which extends `com.getcapacitor.BridgeActivity`. Generated `android/capacitor.settings.gradle` connects the native runtime and Preferences plugin from node_modules.

Flutter does not import Capacitor. Flutter hosts the shared web build through `webview_flutter`; the standalone APK hosts it through Capacitor.

## How data is saved

The adapter selects the host automatically, in this order:

| Running inside | Local storage |
| --- | --- |
| Flutter WebView | `RewardShopHost` JavaScript channel → Dart → SharedPreferences |
| Standalone Capacitor app | Capacitor Preferences |
| Browser preview | localStorage |

Flutter requests and responses are JSON messages, not a configuration file. Example request:

```json
{"id":"1","action":"read"}
```

A write passes a JSON-encoded state containing `version`, `balance` and `history`. Only demo state reads and writes are exposed. No wallet credentials, wallet SDK methods or real transfers are exposed through the bridge. Browser, standalone and Flutter balances are separate local stores.

## Offline behavior and limits

After installing the native APK, the current shop is designed to work offline, including its first launch. Its catalog, visual assets and code are inside the APK. Browsing, simulated redemption, confirmation, history and reset use only local data.

The development browser preview is different: its URL requires the development server to be reachable. It is not an installed offline PWA and has no service worker. Internet access is not the same as access to the development PC.

Things that can prevent operation:

- An old Flutter APK may not contain Reward Shop; rebuild the main app after syncing web assets.
- Missing/broken web assets or an unavailable Android System WebView can prevent rendering.
- A failed host reply or unavailable local storage prevents saving. The UI reports an error rather than confirming a successful deduction.
- Invalid saved data blocks redemptions until the demo is reset.
- Windows/Linux/Flutter web are not implemented embedded targets; use the browser preview there.
- Clearing app data or uninstalling removes local demo history. There is no account/cloud recovery.
- Insufficient points intentionally disables redemption; this is not a connection error.

Future real-wallet redemption will need an authenticated backend and network access, or a separately designed offline synchronization system. The current local demo must not be treated as an authoritative real balance.

## Updating and testing

After editing Vue source:

```powershell
cd D:\Infinity_App_Main\Infinity_App-main\mini-app
npm run build:flutter
npm run android:sync
```

Rebuild Flutter for the embedded version, or build the Capacitor Android project for the standalone version. Installing a standalone Capacitor APK does not update the shop embedded inside an existing Flutter APK.

Offline device test:

1. Install the debug APK and enable airplane mode.
2. For the main app, open Mini-Apps → Reward Shop → Open Module.
3. Start from a fresh demo balance of 1,250 points.
4. Redeem the 500-point water bottle; expect 750 points and one history entry.
5. Close/reopen the app; expect the same balance and history.
6. Try the 1,500-point kit; redemption should be disabled.
7. Reset the demo; expect 1,250 points and empty history.

Native device behavior still needs this test on a phone or emulator; successful compilation alone does not verify it.
