# Android 開發計劃

> 前置閱讀：`todo/os.md`（共用架構）與 `todo/ios.md` 第 2、4 節（行動平台「單視窗模式」、共用外掛 `plugins/iseemt-display`、觸控操作）。
> 本文件只描述 Android 專屬的部分。

---

## 1. 目標與範圍

**第一階段（必要）**
- 在 Android 7.0（API 24）以上的手機與平板全螢幕顯示所有測試圖案，測試裝置本身的面板。
- 沉浸模式（隱藏狀態列與導覽列）、畫面延伸到挖孔 / 瀏海區域、測試中螢幕常亮、選擇最高更新率。
- 返回鍵 / 返回手勢對應「關閉測試畫面」。
- 產出 APK（側載）與 AAB（Google Play）。

**第二階段（進階）**
- 透過 USB-C / HDMI / 無線投影連接的**外接螢幕**以原生解析度顯示測試圖案（`Presentation` API），手機當遙控器。
- Android TV / 電視盒：遙控器方向鍵操作（可選）。

---

## 2. 建置環境

| 項目 | 版本 / 說明 |
| --- | --- |
| Android Studio | 最新穩定版（含 SDK Manager） |
| Android SDK | Platform（compileSdk 34+）、Build-Tools、Platform-Tools、Command-line Tools |
| NDK | 透過 SDK Manager 安裝（Side by side） |
| JDK | 17（可使用 Android Studio 內附的 JBR） |
| Rust targets | 見下方 |

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# 環境變數（範例：Linux / macOS）
export JAVA_HOME=/opt/android-studio/jbr
export ANDROID_HOME=$HOME/Android/Sdk
export NDK_HOME=$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk | tail -n1)
```

Windows 上以「系統內容 → 環境變數」設定同名變數。Android 建置可以在 Windows / Linux / macOS 任一平台進行。

首次初始化：

```bash
npm run tauri android init      # 產生 src-tauri/gen/android（Gradle 專案）
```

`src-tauri/gen/` 的版本控管策略同 `ios.md` 3.1；但 Android 的**簽章設定需要修改 `gen/android/app/build.gradle.kts`**，因此建議：
- 方案 A（推薦）：把 `.gitignore` 中的 `src-tauri/gen/` 改為只忽略建置產物（`src-tauri/gen/android/app/build/`、`.gradle/`、`local.properties`、`*.jks`、`keystore.properties`），提交 `gen/android`。
- 方案 B：不提交 gen，CI 在 `tauri android init` 後以腳本修補 `build.gradle.kts`。

---

## 3. 程式結構調整

### 3.1 Rust

與 iOS 共用：`src/platform/mobile.rs`（`MobilePlatform`）與 `plugins/iseemt-display` crate（`register_android_plugin("com.melixyen.iseemt.display", "DisplayPlugin")`），差異只在外掛的 Kotlin 實作。

新增：

```
src-tauri/
├── tauri.android.conf.json
└── plugins/iseemt-display/android/
    ├── build.gradle.kts
    └── src/main/java/com/melixyen/iseemt/display/
        ├── DisplayPlugin.kt         # 螢幕列舉、沉浸模式、常亮、返回鍵、更新率
        └── ExternalPresentation.kt  # 第二階段：外接螢幕
```

### 3.2 前端

與 iOS 相同（`ios.md` 4.2、4.3）：viewport-fit、響應式選擇器、底部抽屜控制面板、觸控手勢、依 capabilities 調整 UI。Android 額外：

- 返回鍵：外掛觸發 `backPressed` 事件 → adapter 轉成 `close` 動作；在選擇器畫面時則交還系統（結束 Activity）。
- 音量鍵（可選）：在測試畫面中攔截音量 +/- 作為灰階 +/-，提供無需觸碰螢幕的調整方式（避免手指遮擋與指紋）。
- 鍵盤、藍牙遙控器、Android TV 方向鍵：`keydown` 事件照常進入 WebView，`core/input.js` 加入 `ArrowLeft/Right` 對應上一個 / 下一個圖案、`Enter` 對應顯示面板。

---

## 4. OS API 實作（Kotlin 外掛）

### 4.1 外掛骨架與螢幕列舉

```kotlin
package com.melixyen.iseemt.display

import android.app.Activity
import android.content.Context
import android.hardware.display.DisplayManager
import android.view.Display
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import app.tauri.annotation.Command
import app.tauri.annotation.InvokeArg
import app.tauri.annotation.TauriPlugin
import app.tauri.plugin.Invoke
import app.tauri.plugin.JSArray
import app.tauri.plugin.JSObject
import app.tauri.plugin.Plugin

@InvokeArg
class KeepAwakeArgs { var on: Boolean = false }

@TauriPlugin
class DisplayPlugin(private val activity: Activity) : Plugin(activity) {

    private val dm by lazy { activity.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager }

    @Command
    fun listDisplays(invoke: Invoke) {
        val arr = JSArray()
        dm.displays.forEachIndexed { i, d ->
            val mode = d.mode                          // 實體解析度
            arr.put(JSObject().apply {
                put("id", i)
                put("x", 0); put("y", 0)
                put("width", mode.physicalWidth)
                put("height", mode.physicalHeight)
                put("is_primary", d.displayId == Display.DEFAULT_DISPLAY)
                put("is_internal", d.displayId == Display.DEFAULT_DISPLAY)
                put("name", d.name)
                put("refresh_rate", d.refreshRate.toDouble())
                put("scale_factor", activity.resources.displayMetrics.density.toDouble())
            })
        }
        val ret = JSObject()
        ret.put("displays", arr)
        invoke.resolve(ret)
    }

    @Command
    fun setKeepAwake(invoke: Invoke) {
        val args = invoke.parseArgs(KeepAwakeArgs::class.java)
        activity.runOnUiThread {
            if (args.on) activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            else activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            invoke.resolve()
        }
    }
}
```

- 外接螢幕連接 / 拔除：`dm.registerDisplayListener(...)`，以 `trigger("displaysChanged", data)` 通知前端。
- 在多數 Android 版本中，`Display.getMode().physicalWidth/Height` 為面板原生解析度；部分機型提供「解析度切換」（FHD+/QHD+），此時 WebView 的實體像素會跟著系統設定，選擇器應同時顯示 `getSupportedModes()` 中的最大值，提示使用者切換到原生解析度再測試。

### 4.2 沉浸模式與挖孔區域

進入測試畫面時（`open_test_surface` → 外掛 `enterImmersive`），回到選擇器時還原：

```kotlin
@Command
fun enterImmersive(invoke: Invoke) {
    activity.runOnUiThread {
        val window = activity.window
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.systemBars())
            systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
        if (android.os.Build.VERSION.SDK_INT >= 28) {
            window.attributes = window.attributes.apply {
                layoutInDisplayCutoutMode =
                    if (android.os.Build.VERSION.SDK_INT >= 30)
                        WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
                    else
                        WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }
        invoke.resolve()
    }
}
```

前端控制面板以 CSS `env(safe-area-inset-*)` 避開挖孔；canvas 滿版。Android WebView 對 `safe-area-inset` 的支援依版本而異，若取不到值，由外掛透過 `WindowInsetsCompat.getInsets(displayCutout())` 取得後以事件傳給前端，設定為 CSS 變數。

### 4.3 更新率

動態測試（閃爍、移動方塊）需要以面板最高更新率執行：

```kotlin
// 從 display.supportedModes 中，選出與目前解析度相同、refreshRate 最高的 mode
window.attributes = window.attributes.apply { preferredDisplayModeId = best.modeId }
```

選擇器上顯示目前與最高更新率；回到選擇器時還原為 0（交給系統決定）。

### 4.4 返回鍵

```kotlin
// 節錄：需 import android.webkit.WebView、androidx.activity.ComponentActivity、androidx.activity.OnBackPressedCallback
override fun load(webView: WebView) {
    (activity as? ComponentActivity)?.onBackPressedDispatcher?.addCallback(
        activity, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() { trigger("backPressed", JSObject()) }
        })
}
```

前端收到 `backPressed`：測試畫面 → 呼叫 `closeTestSurface()`；選擇器畫面 → 呼叫 `exitApp()`（Android 允許，`close_app` 在 Android 端實作為 `activity.finish()`）。

### 4.5 外接螢幕（第二階段）

使用 `android.app.Presentation` 在次要 `Display` 上顯示獨立視窗：

1. `dm.getDisplays(DisplayManager.DISPLAY_CATEGORY_PRESENTATION)` 取得可用外接螢幕。
2. 建立 `ExternalPresentation(context, display)`，內容為一個獨立 `WebView`，載入 App 內打包的 **Web 單檔版**（`web.md` 產出的 `dist-web/index.html`，作為 Tauri resource / Android asset）。
3. 手機端選圖案 → 外掛 `sendToExternal` → `webView.evaluateJavascript("window.ISeeMT.apply(...)", null)`（API 與 `ios.md` 5.3 的 `src/core/remote.js` 相同）。
4. 外接螢幕拔除時自動 `dismiss()` 並通知前端。

### 4.6 `capabilities()`

```rust
Capabilities {
    multi_display: true,            // 有外接螢幕時
    multi_window: false,
    can_exit_app: true,             // activity.finish()
    has_physical_keyboard: false,
    fullscreen_needs_gesture: false,
    keep_awake: true,
}
```

---

## 5. 平台設定

### 5.1 `src-tauri/tauri.android.conf.json`

```json
{
  "build": {
    "beforeBuildCommand": "npm run build && npm run build:web"
  },
  "bundle": {
    "active": true,
    "resources": { "../dist-web/index.html": "external/index.html" },
    "android": {
      "minSdkVersion": 24,
      "versionCode": 10000
    }
  }
}
```

- `versionCode` 每次上架必須遞增；可由 `version`（1.0.0 → 10000）推導，於 CI 自動填入。
- `identifier` 沿用 `com.melixyen.iseemt`（Android 套件名稱不可含 `-`，目前值合法）。

### 5.2 AndroidManifest 調整

Tauri 產生的 `MainActivity` 需確認／調整（方案 A 直接改 `gen/android`；方案 B 以外掛的 `AndroidManifest.xml` 合併）：

| 屬性 | 值 | 原因 |
| --- | --- | --- |
| `android:screenOrientation` | `fullUser` | 允許任意方向 |
| `android:configChanges` | 包含 `orientation|screenSize|screenLayout|smallestScreenSize|density` | 旋轉時不重建 Activity，避免 WebView 重新載入 |
| `android:resizeableActivity` | `false`（手機） | 避免分割畫面導致非整片面板 |
| `android:theme` | 無 ActionBar、黑色背景 | 啟動時不閃白 |

本工具不需要任何 `uses-permission`（不需網路；Tauri 正式版從 asset 載入前端）。

### 5.3 Capabilities

依 `os.md` 6.3 的 `capabilities/mobile.json`。

---

## 6. 建置與發佈

### 6.1 開發

```bash
npm run tauri android dev               # 模擬器或已連接的實機（adb）
npm run tauri android dev -- --open     # 以 Android Studio 開啟偵錯
```

實機若連不到 dev server，確認 `vite.config.js` 已讀取 `TAURI_DEV_HOST`（見 `os.md` 4.5），或使用 `adb reverse tcp:1420 tcp:1420`。WebView 偵錯可在桌面 Chrome 開 `chrome://inspect`。

### 6.2 正式建置

```bash
npm run tauri android build -- --apk                      # 全部 ABI 的 APK
npm run tauri android build -- --aab                      # Google Play
npm run tauri android build -- --apk --target aarch64     # 只建 arm64（體積較小）
npm run tauri android build -- --apk --split-per-abi      # 每個 ABI 一個 APK
```

產物位於 `src-tauri/gen/android/app/build/outputs/{apk,bundle}/`。

### 6.3 簽章

1. 產生金鑰（只做一次，**妥善備份，遺失將無法更新 Play 上的 App**）：

```bash
keytool -genkey -v -keystore iseemt-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias iseemt
```

2. `src-tauri/gen/android/keystore.properties`（加入 `.gitignore`）：

```properties
storeFile=/path/to/iseemt-release.jks
storePassword=****
keyAlias=iseemt
keyPassword=****
```

3. 在 `gen/android/app/build.gradle.kts` 加入 `signingConfigs.release` 讀取上述檔案，並在 `buildTypes.release` 使用。
4. Google Play 建議啟用 Play App Signing，上傳金鑰與發佈金鑰分離。

### 6.4 CI

```yaml
android:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with: { node-version: 20 }
    - uses: actions/setup-java@v4
      with: { distribution: temurin, java-version: 17 }
    - uses: android-actions/setup-android@v3
    - run: sdkmanager "ndk;27.0.12077973"
    - uses: dtolnay/rust-toolchain@stable
      with: { targets: aarch64-linux-android,armv7-linux-androideabi,i686-linux-android,x86_64-linux-android }
    - run: npm ci
    - run: npm run tauri android build -- --apk --aab
      env:
        NDK_HOME: ${{ env.ANDROID_HOME }}/ndk/27.0.12077973
        # 簽章：由 Secrets 還原 keystore 與 keystore.properties
```

NDK 版本以當時 Tauri 文件建議為準。

---

## 7. 測試清單

- [ ] 手機（挖孔 / 水滴瀏海 / 無瀏海）、平板、Android 7.0 模擬器各測一次。
- [ ] 沉浸模式：狀態列與導覽列（三鍵與手勢導覽兩種設定）隱藏；從邊緣滑動暫時出現後會自動再隱藏。
- [ ] canvas 覆蓋挖孔與圓角區域；控制面板不被挖孔遮住。
- [ ] 旋轉後正確重繪；1px 線條為實體 1 像素（`devicePixelRatio` 常見為 2.625、3、3.5 等非整數，需特別確認 `Math.round` 處理）。
- [ ] 高更新率機型（90 / 120 / 144Hz）在動態測試時切到最高更新率，回到選擇器後還原。
- [ ] 返回鍵：測試畫面 → 選擇器；選擇器 → 結束程式。
- [ ] 測試中螢幕常亮；回到選擇器後恢復系統休眠設定。
- [ ] （可選）音量鍵調整灰階；藍牙鍵盤 / 電視遙控器操作。
- [ ] （第二階段）USB-C 轉 HDMI、無線投影：列舉、原生解析度顯示、拔除處理。
- [ ] APK 側載安裝、AAB 上傳 Play Console 內部測試軌。
- [ ] **Windows 回歸清單（`os.md` 8.2）全過。**

---

## 8. 已知限制

| 項目 | 說明 |
| --- | --- |
| WebView 版本 | Android System WebView 由使用者更新，舊裝置 Canvas 效能與功能可能落後；最低以 Chromium 90+ 為支援目標 |
| 色彩模式 | 各廠牌「螢幕色彩模式」（鮮豔 / 自然）、護眼模式、自動亮度會改變輸出，只能提示使用者手動關閉 |
| 非整數 DPR | 部分機型 `devicePixelRatio` 非整數，CSS 與實體像素對齊需由 `core/canvas.js` 謹慎處理 |
| 外接螢幕 | 並非所有手機的 USB-C 支援影像輸出（DP Alt Mode）；部分廠牌（如 Samsung DeX）會進入桌面模式，行為需另外驗證 |

---

## 9. 任務分解

- [ ] 完成 `os.md` P1～P3 與 `ios.md` 中共用的單視窗模式（`App.vue` 改用 `getSurfaceContext()`）。
- [ ] 決定 `src-tauri/gen/android` 的版本控管方案並更新 `.gitignore`。
- [ ] `plugins/iseemt-display` 加入 Android 部分：`listDisplays`、`setKeepAwake`、`enterImmersive` / `exitImmersive`、更新率、返回鍵、螢幕變更事件。
- [ ] `mobile.rs` 中 Android 的 `close_app` → `activity.finish()`。
- [ ] `tauri.android.conf.json`、Manifest 調整、`capabilities/mobile.json`。
- [ ] 前端：返回鍵、音量鍵（可選）、方向鍵操作；safe-area 後備方案。
- [ ] `tauri icon` 產生 Android 圖示（adaptive icon）。
- [ ] 簽章設定與 `keystore.properties`；CI 加入 Android job。
- [ ] （第二階段）`ExternalPresentation`、打包 Web 單檔版為資源。
