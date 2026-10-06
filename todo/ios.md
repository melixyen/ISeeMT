# iOS / iPadOS 開發計劃

> 前置閱讀：`todo/os.md`（共用架構、`Platform` trait、`PlatformAdapter`、Windows 相容規則）。
> iOS 與 Android 共用同一個行動外掛與「單視窗模式」設計，本文件會先定義共用部分，`android.md` 引用之。

---

## 1. 目標與範圍

**第一階段（必要）**
- 在 iPhone / iPad（iOS 15+）上以全螢幕顯示所有測試圖案，測試**裝置本身的面板**。
- 隱藏狀態列、自動隱藏 Home Indicator、畫面延伸到瀏海與圓角區域、測試中不自動鎖定。
- 以觸控操作取代鍵盤與右鍵。

**第二階段（進階）**
- 偵測透過 HDMI / USB-C / AirPlay 連接的**外接螢幕**，在外接螢幕上以原生解析度顯示測試圖案，手機當遙控器。

不在範圍：Mac Catalyst（macOS 版已由 `mac.md` 處理）。

---

## 2. 行動平台的核心差異

| 項目 | 桌面 | 行動（iOS / Android） |
| --- | --- | --- |
| 視窗 | 每台螢幕一個 `WebviewWindow` | **只有一個** WebView（label `main`），Tauri 不支援在行動平台建立第二個視窗 |
| 螢幕 | 多台、有虛擬桌面座標 | 內建面板 1 台；外接螢幕沒有「虛擬桌面」座標概念 |
| 輸入 | 鍵盤、滑鼠 | 觸控、手勢；（iPad 可能有鍵盤） |
| 結束程式 | 可以 | iOS 不允許程式自行結束（App Store 審核規範） |
| 全螢幕 | 視窗屬性 | 系統列、Home Indicator、瀏海、圓角 |

### 2.1 單視窗模式（重用既有 command）

不新增前端分支，而是讓 Rust 端在行動平台改變既有 command 的語意：

| Command | 桌面行為（不變） | 行動行為 |
| --- | --- | --- |
| `get_monitors_command` | Win32 / GDK / AppKit 列舉 | 呼叫外掛 `listDisplays`：內建面板 + 外接螢幕 |
| `open_test_window` | 開新全螢幕視窗 | 內建面板：把 display 存入狀態（key = `main`）並 `emit("iseemt://surface-changed")`；外接螢幕：呼叫外掛 `presentOnExternal` |
| `get_my_monitor_data` | 依視窗 label 取狀態 | 同一份程式碼：`main` 有資料 = 測試模式，無資料 = 選擇器 |
| `close_window` | 關閉呼叫者視窗 | 移除 `main` 的狀態並 `emit("iseemt://surface-changed")`，**不關閉 WebView** |
| `close_app` | `app.exit(0)` | iOS：不做事（UI 也會依 `canExitApp=false` 隱藏按鈕）；Android：`activity.finish()` |

前端 `src/platform/tauri.js` 因此可以統一成：

```js
async getSurfaceContext() {
  const display = await invoke('get_my_monitor_data')
  return display ? { role: 'test', display } : { role: 'selector' }
},
onSurfaceChanged(cb) {
  // 桌面不會收到此事件；行動平台在 open/close 時觸發
  return listen('iseemt://surface-changed', cb)
},
```

桌面上：主視窗不在狀態表中 → 選擇器；`test-*` 視窗在狀態表中 → 測試畫面，與現況邏輯等價，**Windows 行為不變**。`App.vue` 改為依 `getSurfaceContext()` 決定畫面，並在 `onSurfaceChanged` 時重新查詢。

---

## 3. 建置環境

- macOS + **Xcode 15 以上**（含 iOS SDK、模擬器）。
- CocoaPods：`brew install cocoapods`。
- Rust targets：

```bash
rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
```

- Apple Developer 帳號（實機測試可用免費帳號，上架需付費帳號）。
- 首次初始化：

```bash
npm run tauri ios init      # 產生 src-tauri/gen/apple（Xcode 專案）
```

### 3.1 `src-tauri/gen/` 的版本控管

目前 `.gitignore` 忽略整個 `src-tauri/gen/`。建議策略：

1. **所有客製化都放在 gen 以外**：原生程式碼放在 `src-tauri/plugins/iseemt-display/ios/`；Info.plist 追加鍵值放在 `src-tauri/Info.ios.plist`（Tauri 2 會合併；以當時版本文件為準）；簽章與版本放在 `tauri.ios.conf.json`。如此 `gen/apple` 可隨時以 `tauri ios init` 重建，CI 也每次重建。
2. 若日後必須修改 Xcode 專案本身（例如 Scene 設定），再把 `.gitignore` 改為只忽略 `src-tauri/gen/apple/build/` 等建置目錄，並提交 `gen/apple`。

---

## 4. 程式結構調整

### 4.1 Rust（依 `os.md` 第 5 節）

```
src-tauri/
├── tauri.ios.conf.json
├── Info.ios.plist
├── src/platform/mobile.rs           # MobilePlatform：iOS / Android 共用
└── plugins/iseemt-display/          # 行動平台原生外掛（iOS 與 Android 共用一個 crate）
    ├── Cargo.toml                   # name = "tauri-plugin-iseemt-display"
    ├── build.rs                     # tauri_plugin::Builder::new(COMMANDS).ios_path("ios").android_path("android")
    ├── permissions/default.toml
    ├── src/
    │   ├── lib.rs                   # init()、register_ios_plugin / register_android_plugin
    │   └── mobile.rs                # 包裝 run_mobile_plugin 呼叫
    ├── ios/
    │   ├── Package.swift
    │   └── Sources/DisplayPlugin.swift
    └── android/                     # 見 android.md
```

`plugins/iseemt-display/src/lib.rs`：

```rust
use tauri::{plugin::{Builder, TauriPlugin}, Manager, Runtime};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_iseemt_display);

pub struct DisplayHandle<R: Runtime>(pub tauri::plugin::PluginHandle<R>);

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("iseemt-display")
        .setup(|app, api| {
            #[cfg(target_os = "ios")]
            let handle = api.register_ios_plugin(init_plugin_iseemt_display)?;
            #[cfg(target_os = "android")]
            let handle = api.register_android_plugin("com.melixyen.iseemt.display", "DisplayPlugin")?;
            app.manage(DisplayHandle(handle));
            Ok(())
        })
        .build()
}
```

`src/platform/mobile.rs`（概念）：

```rust
impl Platform for MobilePlatform {
    fn monitors<R: Runtime>(app: &AppHandle<R>) -> Result<Vec<MonitorInfo>, String> {
        let h = app.state::<DisplayHandle<R>>();
        let res: DisplaysResponse = h.0.run_mobile_plugin("listDisplays", ())
            .map_err(|e| e.to_string())?;
        Ok(res.displays)
    }

    fn open_test_surface<R: Runtime>(app: &AppHandle<R>, _label: &str, m: &MonitorInfo)
        -> Result<(), String> {
        // open_test_window 的參數只有 monitorId 與座標，is_internal 等欄位不在其中，
        // 因此先以 monitorId 從外掛重新取得完整的 DisplayInfo。
        let m = &Self::monitors(app)?
            .into_iter()
            .find(|d| d.id == m.id)
            .ok_or("display not found")?;
        if m.is_internal.unwrap_or(true) {
            app.state::<WindowMonitors>().set("main", m.clone());
            app.emit("iseemt://surface-changed", ()).map_err(|e| e.to_string())
        } else {
            app.state::<DisplayHandle<R>>().0
                .run_mobile_plugin::<()>("presentOnExternal", m)
                .map_err(|e| e.to_string())
        }
    }
    // close_test_surface、set_keep_awake、capabilities ...
}
```

### 4.2 前端

- 新增 `index.html` 的 viewport 設定：`<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover, user-scalable=no">`。`viewport-fit=cover` 讓 canvas 蓋滿瀏海與圓角區域；桌面 WebView 會忽略此屬性，對 Windows 無影響。
- 控制面板使用 `padding: env(safe-area-inset-top) env(safe-area-inset-right) ...` 避開瀏海；**canvas 本身不避開**，測試必須涵蓋整片面板。
- `MonitorSelector.vue`：加入 `@media (max-width: 783px)` 的響應式版面，改為「螢幕卡片清單」（內建 / 外接各一張卡，顯示解析度、更新率、縮放）。桌面主視窗為 1200×800，媒體查詢不會觸發，Windows 外觀不變。
- `TestPatternDisplay.vue` 的控制面板在窄螢幕改為可捲動的底部抽屜，分頁顯示（純色 / 線條 / 色階 / 動態 / 文字）。
- 依 `capabilities.canExitApp` 隱藏「關閉程式」按鈕；依 `capabilities.hasPhysicalKeyboard` 把提示文字從「按 Esc」換成「雙指點擊返回」。

### 4.3 觸控操作（`src/core/input.js`）

| 手勢 | 動作 |
| --- | --- |
| 單指點擊 | 顯示 / 隱藏控制面板（取代右鍵 / 左鍵） |
| 雙指點擊 | 關閉測試畫面，回到選擇器（取代 `Esc`） |
| 上滑 / 下滑 | 灰階 +/-（取代 `+`/`-`） |
| 左滑 / 右滑 | 上一個 / 下一個圖案 |
| 長按 2 秒 | 顯示目前設定（取代 `showSetting`） |

手勢實作用 Pointer Events，不引入第三方函式庫；canvas 設定 `touch-action: none` 避免捲動與縮放。iPad 接上鍵盤時鍵盤操作照常可用。

---

## 5. OS API 實作（Swift 外掛）

### 5.1 `DisplayPlugin.swift`

```swift
import Tauri
import UIKit
import WebKit

struct KeepAwakeArgs: Decodable { let on: Bool }

class DisplayPlugin: Plugin {
  @objc public func listDisplays(_ invoke: Invoke) {
    DispatchQueue.main.async {
      var list: [[String: Any]] = []
      for (i, screen) in UIScreen.screens.enumerated() {
        let px = screen.nativeBounds.size            // 實體像素（直向）
        list.append([
          "id": i,
          "x": 0, "y": 0,
          "width": Int(px.width), "height": Int(px.height),
          "is_primary": screen == UIScreen.main,
          "is_internal": screen == UIScreen.main,
          "name": screen == UIScreen.main ? UIDevice.current.model : "External \(i)",
          "scale_factor": screen.nativeScale,
          "refresh_rate": screen.maximumFramesPerSecond,
        ])
      }
      invoke.resolve(["displays": list])
    }
  }

  @objc public func setKeepAwake(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(KeepAwakeArgs.self)
    DispatchQueue.main.async {
      UIApplication.shared.isIdleTimerDisabled = args.on
      invoke.resolve()
    }
  }

  // presentOnExternal / dismissExternal：見 5.3
}

@_cdecl("init_plugin_iseemt_display")
func initPlugin() -> Plugin { return DisplayPlugin() }
```

注意：
- `nativeBounds` 永遠以直向回報，前端畫面旋轉時以 `window.innerWidth/innerHeight * devicePixelRatio` 為準；`listDisplays` 的寬高只用於選擇器顯示。
- 外接螢幕連接 / 拔除：監聽 `UIScreen.didConnectNotification` / `didDisconnectNotification`，透過 `trigger("displaysChanged", data:)` 通知前端，對應 adapter 的 `onDisplaysChanged`。

### 5.2 全螢幕與系統 UI

| 需求 | 做法 |
| --- | --- |
| 隱藏狀態列 | `Info.ios.plist`：`UIStatusBarHidden = true`、`UIViewControllerBasedStatusBarAppearance = false` |
| iPad 禁止分割畫面（確保整片面板） | `UIRequiresFullScreen = true` |
| Home Indicator 自動隱藏 | 需覆寫根 view controller 的 `prefersHomeIndicatorAutoHidden`；Tauri/tao 的 view controller 不易覆寫，先評估在外掛 `load()` 中以 method swizzling 實作，否則列為已知限制 |
| 延遲系統邊緣手勢 | 同上，`preferredScreenEdgesDeferringSystemGestures` |
| 瀏海與圓角 | `viewport-fit=cover` + canvas 滿版 |
| 防止自動鎖定 | `isIdleTimerDisabled`，進入測試畫面時開啟、回到選擇器時關閉 |
| 120Hz（ProMotion） | `Info.ios.plist`：`CADisableMinimumFrameDurationOnPhone = true`；WKWebView 的 rAF 是否跟上需實測 |
| 旋轉 | 允許所有方向；`core/canvas.js` 在 `resize` / `orientationchange` 時重建 canvas 並重繪目前圖案 |

### 5.3 外接螢幕（第二階段）

iOS 預設會把畫面**鏡像**到外接螢幕，但會縮放與加黑邊，不適合像素測試。要以外接螢幕原生解析度顯示，需在外接螢幕上建立獨立的 `UIWindow`：

1. 監聽 `UIScreen.didConnectNotification`；取得 `UIScreen`，選擇其 `availableModes` 中最大的 mode 作為 `currentMode`。
2. 建立 `UIWindow(frame: screen.bounds)`、設定 `window.screen = screen`（App 未採用 Scene 生命週期時可用；tao 目前不採用 Scene，若日後改用需遷移到 `UIWindowSceneSessionRoleExternalDisplayNonInteractive`）。
3. 在該視窗放入一個**獨立的 `WKWebView`**，以 `loadFileURL` 載入 App bundle 內的 **Web 單檔版**（`web.md` 產出的 `dist-web/index.html`，作為 Tauri resource 一起打包）。此頁面不需要任何 Tauri IPC。
4. 手機端 UI 變成遙控器：使用者在手機上選圖案 → 前端呼叫外掛 `sendToExternal({ pattern, options })` → Swift 以 `evaluateJavaScript("window.ISeeMT.apply(...)")` 傳給外接頁面。

因此 `src/core/` 需提供一個與 UI 無關的控制 API（Web 版也會用到）：

```js
// src/core/remote.js
window.ISeeMT = {
  apply(patternName, options) { /* 呼叫 core/patterns 繪圖 */ },
  stop() { /* 停止動畫 */ },
  getState() { /* 回傳目前圖案與設定 */ },
}
```

`tauri.ios.conf.json` 的 `bundle.resources` 加入 `../dist-web/index.html`，並在 `beforeBuildCommand` 中同時執行 `npm run build && npm run build:web`（僅行動平台設定檔覆寫，Windows 的 `beforeBuildCommand` 不變）。

### 5.4 `capabilities()`

```rust
Capabilities {
    multi_display: true,            // 有外接螢幕時
    multi_window: false,
    can_exit_app: false,            // iOS 不可自行結束
    has_physical_keyboard: false,   // iPad 接鍵盤時前端仍可接收鍵盤事件
    fullscreen_needs_gesture: false,
    keep_awake: true,
}
```

---

## 6. 平台設定

### 6.1 `src-tauri/tauri.ios.conf.json`

```json
{
  "build": {
    "beforeBuildCommand": "npm run build && npm run build:web"
  },
  "bundle": {
    "active": true,
    "resources": { "../dist-web/index.html": "external/index.html" },
    "iOS": {
      "minimumSystemVersion": "15.0",
      "developmentTeam": "XXXXXXXXXX"
    }
  }
}
```

`developmentTeam` 也可以用環境變數 `APPLE_DEVELOPMENT_TEAM` 提供，避免寫入 repo。

### 6.2 `src-tauri/Info.ios.plist`

```xml
<dict>
  <key>UIStatusBarHidden</key><true/>
  <key>UIViewControllerBasedStatusBarAppearance</key><false/>
  <key>UIRequiresFullScreen</key><true/>
  <key>CADisableMinimumFrameDurationOnPhone</key><true/>
  <key>UISupportedInterfaceOrientations</key>
  <array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
  </array>
</dict>
```

### 6.3 Capabilities

依 `os.md` 6.3 的 `capabilities/mobile.json`，加入 `iseemt-display:default` 權限。

### 6.4 隱私清單

App Store 要求 `PrivacyInfo.xcprivacy`。本工具不收集資料；若使用 `UserDefaults`（例如儲存語言設定）需宣告對應的 Required Reason API。放在外掛的 `ios/Sources/` 資源中或 Xcode 專案內。

---

## 7. 建置與發佈

### 7.1 開發

```bash
npm run tauri ios dev                    # 模擬器
npm run tauri ios dev -- --host          # 實機：dev server 綁定區網 IP（vite.config.js 需讀取 TAURI_DEV_HOST，見 os.md 4.5）
npm run tauri ios dev -- --open          # 以 Xcode 開啟並偵錯
```

### 7.2 正式建置

```bash
npm run tauri ios build -- --export-method app-store-connect   # TestFlight / App Store
npm run tauri ios build -- --export-method ad-hoc              # 指定裝置發佈
```

產物：`src-tauri/gen/apple/build/arm64/ISeeMT.ipa`（路徑依 Tauri 版本可能略有不同）。

### 7.3 CI（macOS runner）

```yaml
ios:
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with: { node-version: 20 }
    - uses: dtolnay/rust-toolchain@stable
      with: { targets: aarch64-apple-ios,aarch64-apple-ios-sim,x86_64-apple-ios }
    - run: npm ci
    - run: npm run tauri ios init
    - run: npm run tauri ios build -- --export-method app-store-connect
      env:
        APPLE_API_ISSUER: ${{ secrets.APPLE_API_ISSUER }}
        APPLE_API_KEY: ${{ secrets.APPLE_API_KEY }}
        APPLE_API_KEY_PATH: ${{ runner.temp }}/AuthKey.p8
        APPLE_DEVELOPMENT_TEAM: ${{ secrets.APPLE_DEVELOPMENT_TEAM }}
```

手動簽章時改用 `IOS_CERTIFICATE`、`IOS_CERTIFICATE_PASSWORD`、`IOS_MOBILE_PROVISION`。全部放在 GitHub Secrets。

---

## 8. 測試清單

- [ ] iPhone（有瀏海 / 動態島）、iPhone SE（無瀏海）、iPad 各測一次；模擬器與實機都要。
- [ ] 狀態列隱藏；canvas 覆蓋瀏海與圓角區域（以純白畫面目視確認四角）。
- [ ] 直向 / 橫向旋轉後圖案正確重繪，1px 線條仍為實體 1 像素（`devicePixelRatio` 為 2 或 3）。
- [ ] 所有手勢操作正確；iPad 接鍵盤時 `Esc`、`+`、`-` 可用。
- [ ] 測試中不會自動鎖定；回到選擇器後恢復系統設定。
- [ ] 「關閉程式」按鈕在 iOS 不顯示。
- [ ] 動態測試在 60Hz / 120Hz 機型的實際幀率。
- [ ] （第二階段）HDMI 轉接器與 AirPlay 外接：列舉、以原生解析度顯示、拔除後回到正常狀態。
- [ ] **Windows 回歸清單（`os.md` 8.2）全過**（特別是 `App.vue` 改用 `getSurfaceContext()` 之後）。

---

## 9. 已知限制

| 項目 | 說明 |
| --- | --- |
| 色彩管理 | WKWebView 經系統色彩管理，與 macOS 相同（見 `mac.md` 6.2），可提供 Display P3 選項 |
| True Tone / Night Shift / 自動亮度 | 會改變面板輸出，App 無法關閉，只能在 UI 提示使用者手動關閉 |
| Home Indicator | 若無法覆寫 view controller，底部指示條會在觸控後短暫出現 |
| 外接螢幕 | AirPlay 有壓縮與延遲，像素級測試建議用有線連接 |
| 結束程式 | 依 Apple 規範不提供 |

---

## 10. 任務分解

- [ ] 完成 `os.md` P1～P3（前置，特別是 `lib.rs` 與 `mobile_entry_point`）。
- [ ] `App.vue` 改用 `getSurfaceContext()` / `onSurfaceChanged()`；Windows 回歸。
- [ ] 建立 `plugins/iseemt-display` crate 骨架（iOS 部分）。
- [ ] Swift：`listDisplays`、`setKeepAwake`、螢幕連接通知。
- [ ] `mobile.rs`：單視窗模式的 `open_test_surface` / `close_test_surface`。
- [ ] `tauri.ios.conf.json`、`Info.ios.plist`、`capabilities/mobile.json`。
- [ ] 前端：viewport-fit、safe-area、響應式選擇器、底部抽屜控制面板、觸控手勢、依 capabilities 調整 UI。
- [ ] `vite.config.js` 支援 `TAURI_DEV_HOST`。
- [ ] `tauri icon` 產生 iOS 圖示。
- [ ] （第二階段）外接螢幕：`presentOnExternal`、`src/core/remote.js`、打包 Web 單檔版為 resource。
- [ ] CI 加入 iOS job；TestFlight 發佈流程。
