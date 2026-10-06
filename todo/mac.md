# macOS 開發計劃

> 前置閱讀：`todo/os.md`（共用架構、`Platform` trait、`PlatformAdapter`、Windows 相容規則）。
> 本文件只描述 macOS 專屬的部分。

---

## 1. 目標與範圍

- 在 macOS 11（Big Sur）以上提供完整功能：列舉多螢幕（含 Retina 與外接螢幕）、在指定螢幕全螢幕顯示測試圖案。
- 產出 Universal Binary（Apple Silicon + Intel）的 `.app` 與 `.dmg`。
- 完成 Developer ID 簽章與 Apple 公證（Notarization），讓使用者下載後可直接開啟。

不在範圍：Mac App Store 上架（沙盒限制較多，列為後續選項）。

---

## 2. 建置環境

```bash
xcode-select --install                     # Xcode Command Line Tools
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add aarch64-apple-darwin x86_64-apple-darwin
node --version                             # 18+
```

- 建置 Universal Binary 需要同時安裝兩個 target。
- 簽章與公證需要 Apple Developer Program 帳號（年費）、「Developer ID Application」憑證。

---

## 3. 程式結構調整

依 `os.md` 第 5 節完成 Rust 重構後，macOS 新增：

```
src-tauri/
├── tauri.macos.conf.json
├── macos/
│   ├── Info.plist           # 額外的 Info.plist 鍵值（Tauri 會合併）
│   └── entitlements.plist   # Hardened Runtime 權限
└── src/platform/
    ├── desktop_common.rs    # 與 Linux 共用
    └── macos.rs             # MacPlatform
```

`Cargo.toml`：

```toml
[target.'cfg(target_os = "macos")'.dependencies]
objc2 = "0.6"
objc2-foundation = "0.3"
objc2-app-kit = { version = "0.3", features = ["NSScreen", "NSApplication", "NSWindow"] }
core-graphics = "0.24"
# 版本請對齊 tauri / tao 內部使用的 objc2 系列，避免重複編譯兩套
```

---

## 4. OS API 實作

### 4.1 螢幕列舉 `MacPlatform::monitors`

基礎資料使用 `desktop_common::monitors_via_tauri`（tao 已處理 Cocoa 左下原點 → 左上原點的座標轉換，並回報 `scale_factor`）。再以原生 API 補強：

| 欄位 | API | 說明 |
| --- | --- | --- |
| `name` | `NSScreen.localizedName`（macOS 10.15+） | 例如「Built-in Retina Display」「DELL U2720Q」 |
| `refresh_rate` | `CGDisplayCopyDisplayMode` → `CGDisplayModeGetRefreshRate` | 內建面板可能回傳 0，ProMotion 可用 `NSScreen.maximumFramesPerSecond` |
| `is_internal` | `CGDisplayIsBuiltin` | 筆電內建面板 |
| `is_primary` | `CGMainDisplayID()` | 含選單列的那台 |

對應方式：`NSScreen.deviceDescription["NSScreenNumber"]` 即 `CGDirectDisplayID`，以它把 NSScreen 與 CG 資料串起來，再依座標與 Tauri 的列表配對。

**實體像素 vs. 點**：Retina 螢幕 `scale_factor = 2`。`MonitorInfo` 的 `width/height` 保持實體像素（與 Windows 一致），選擇器縮圖用 `width / scale_factor` 計算版面位置，否則 Retina 螢幕在縮圖中會被畫成兩倍大。

> 「縮放」模式（例如 4K 螢幕設為「看起來像 2560×1440」）下，macOS 實際以 5120×2880 繪製再縮小輸出，WebView 拿到的實體像素並非面板原生像素。這會影響 1px 線條測試，必須在 UI 上提示使用者改為「預設」解析度，並在第 9 節記錄為已知限制。可用 `CGDisplayModeGetPixelWidth` 與 `CGDisplayPixelsWide` 比對偵測此情況，回傳給前端顯示警告。

### 4.2 開啟測試視窗 `MacPlatform::open_test_surface`

macOS 的 `fullscreen(true)` 是**原生全螢幕**：建立新的 Space、有轉場動畫，且在「顯示器使用不同的空間」關閉時會讓其他螢幕變黑，不適合測試工具。改用 **simple fullscreen**（無 Space、無動畫、蓋過選單列與 Dock）：

```rust
// src/platform/macos.rs（概念）
let logical_x = m.x as f64 / m.scale_factor;
let logical_y = m.y as f64 / m.scale_factor;
let logical_w = m.width as f64 / m.scale_factor;
let logical_h = m.height as f64 / m.scale_factor;

let win = tauri::WebviewWindowBuilder::new(app, label, tauri::WebviewUrl::App("index.html".into()))
    .title("ISee Monitor Test")
    .decorations(false)
    .visible(false)
    .position(logical_x, logical_y)
    .inner_size(logical_w, logical_h)
    .build()
    .map_err(|e| e.to_string())?;

win.set_simple_fullscreen(true).map_err(|e| e.to_string())?;   // macOS 專屬 API
win.show().map_err(|e| e.to_string())?;
win.set_focus().map_err(|e| e.to_string())?;
```

注意：
- `set_simple_fullscreen` 為較新的 Tauri 2.x 才提供的 macOS 專屬 API；若專案鎖定的版本沒有，可用 `win.ns_window()` 取得 `NSWindow` 指標，自行設定 `styleMask`、`frame = screen.frame`、`level` 與 presentation options 達到相同效果。
- `set_simple_fullscreen` 以視窗**目前所在**的螢幕為準，所以一定要先定位再呼叫。
- 選單列在 simple fullscreen 下會自動隱藏；若某些系統版本仍出現，可補呼叫 `NSApplication.setPresentationOptions(HideMenuBar | HideDock)`，關閉最後一個測試視窗時還原。
- 若要保留原生全螢幕作為選項，可在設定中切換，但預設使用 simple fullscreen。

### 4.3 關閉視窗、結束程式與 macOS 慣例

- 關閉測試視窗前先 `set_simple_fullscreen(false)`，避免殘留的 presentation options。
- macOS 慣例是「關閉最後一個視窗不結束程式」；本工具主視窗關閉時直接結束即可（與 Windows 一致），在 `RunEvent::WindowEvent` 中不需特別處理。
- 保留 Tauri 預設的應用程式選單，讓 `Cmd+Q`、`Cmd+W` 可用；`Esc` 仍由前端處理為關閉測試畫面。

### 4.4 防止螢幕休眠 `set_keep_awake`

使用 IOKit 電源斷言：

```rust
// IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleDisplaySleep, kIOPMAssertionLevelOn, reason, &id)
// IOPMAssertionRelease(id)
```

可直接 FFI 呼叫 IOKit，或使用跨平台 crate（如 `keepawake`）；斷言 ID 存在 `state.rs` 中。

### 4.5 開啟外部連結

統一走 adapter 的 `openExternal` → `tauri-plugin-opener`（內部使用 `NSWorkspace.openURL`）。

### 4.6 `capabilities()`

```rust
Capabilities {
    multi_display: true,
    multi_window: true,
    can_exit_app: true,
    has_physical_keyboard: true,
    fullscreen_needs_gesture: false,
    keep_awake: true,
}
```

---

## 5. 平台設定

### 5.1 `src-tauri/tauri.macos.conf.json`

```json
{
  "bundle": {
    "active": true,
    "targets": ["app", "dmg"],
    "category": "public.app-category.utilities",
    "icon": ["icons/icon.icns"],
    "macOS": {
      "minimumSystemVersion": "11.0",
      "signingIdentity": null,
      "hardenedRuntime": true,
      "entitlements": "macos/entitlements.plist",
      "infoPlist": "macos/Info.plist",
      "dmg": {
        "windowSize": { "width": 660, "height": 400 }
      }
    }
  }
}
```

- `signingIdentity` 在本機開發設為 `"-"`（ad-hoc 簽章）即可執行；正式版由 CI 以環境變數 `APPLE_SIGNING_IDENTITY` 提供。
- `infoPlist` 欄位在部分 Tauri 2 版本中是以 `src-tauri/Info.plist` 自動合併，實作時以當時版本文件為準。

### 5.2 `macos/Info.plist`（合併進產物）

```xml
<dict>
  <key>NSHighResolutionCapable</key><true/>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>NSHumanReadableCopyright</key><string>© melixyen</string>
</dict>
```

### 5.3 `macos/entitlements.plist`

本工具不需要網路、檔案、相機等權限；Hardened Runtime 下 WebView 的 JIT 需要：

```xml
<dict>
  <key>com.apple.security.cs.allow-jit</key><true/>
</dict>
```

---

## 6. 前端調整（macOS 特有）

1. **字型**：`MS Sans Serif` 不存在，後備清單加上 `-apple-system, "Helvetica Neue", "PingFang TC"`。
2. **色彩管理（重要）**：WKWebView 會把 Canvas 的 sRGB 值經 ColorSync 轉換到螢幕描述檔，所以 `rgb(255,0,0)` 在廣色域面板上**不是**面板原生紅色。對螢幕測試工具這是根本性差異：
   - 預設使用 sRGB，並在測試畫面資訊列標示「macOS：顏色經系統色彩管理」。
   - 提供選項以 `canvas.getContext('2d', { colorSpace: 'display-p3' })` 繪製，讓純色更接近 P3 面板原生色域。
   - 此選項只在 `__APP_OS__ === 'darwin'`（或支援 `colorSpace` 的瀏覽器）時顯示。
3. **requestAnimationFrame**：ProMotion（120Hz）MacBook 上 WKWebView 的 rAF 頻率需實測；動態測試的時間計算一律用 `performance.now()` 差值，而非假設 60fps。
4. **滑鼠游標**：測試畫面閒置 2 秒後設定 `cursor: none`（共用於所有桌面平台）。

---

## 7. 建置、簽章、公證

### 7.1 本機建置

```bash
npm ci
npm run tauri build -- --target universal-apple-darwin
```

產物：

| 格式 | 路徑 |
| --- | --- |
| App | `src-tauri/target/universal-apple-darwin/release/bundle/macos/ISeeMT.app` |
| DMG | `src-tauri/target/universal-apple-darwin/release/bundle/dmg/ISeeMT_1.0.0_universal.dmg` |

### 7.2 簽章與公證（CI）

Tauri 讀取下列環境變數自動完成簽章、公證與 staple：

| 變數 | 用途 |
| --- | --- |
| `APPLE_CERTIFICATE` | Developer ID 憑證 `.p12` 的 base64 |
| `APPLE_CERTIFICATE_PASSWORD` | `.p12` 密碼 |
| `APPLE_SIGNING_IDENTITY` | 例如 `Developer ID Application: XXX (TEAMID)` |
| `APPLE_API_ISSUER` / `APPLE_API_KEY` / `APPLE_API_KEY_PATH` | App Store Connect API Key（建議） |
| 或 `APPLE_ID` / `APPLE_PASSWORD` / `APPLE_TEAM_ID` | Apple ID + App 專用密碼 |

這些全部放在 GitHub Secrets，**不得提交到 repo**。

### 7.3 CI job

```yaml
- os: macos-latest
  args: '--target universal-apple-darwin'
  rust-targets: 'aarch64-apple-darwin,x86_64-apple-darwin'
  env:
    APPLE_CERTIFICATE: ${{ secrets.APPLE_CERTIFICATE }}
    APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
    APPLE_SIGNING_IDENTITY: ${{ secrets.APPLE_SIGNING_IDENTITY }}
    APPLE_API_ISSUER: ${{ secrets.APPLE_API_ISSUER }}
    APPLE_API_KEY: ${{ secrets.APPLE_API_KEY }}
    APPLE_API_KEY_PATH: ${{ runner.temp }}/AuthKey.p8
```

沒有憑證時（例如 fork 的 PR），CI 仍以 ad-hoc 簽章建置以驗證可編譯。

---

## 8. 測試清單

- [ ] Apple Silicon 與 Intel Mac 各測一次（Universal Binary 兩種架構都能啟動）。
- [ ] 內建 Retina + 1 台外接 4K（預設解析度與「縮放」解析度各一次）。
- [ ] 外接螢幕放在內建螢幕的左側、上方（負座標）時，選擇器縮圖與實際位置一致。
- [ ] 「顯示器使用不同的空間」開啟與關閉兩種設定下，測試視窗都出現在正確螢幕且不切換 Space。
- [ ] 全螢幕時選單列、Dock、瀏海區（MacBook Pro 2021+）不遮擋或已正確處理。
- [ ] 1px 線條在預設解析度下為實體 1 像素。
- [ ] 純色測試在 sRGB / Display P3 兩種模式下的表現，記錄差異。
- [ ] 動態測試在 ProMotion 螢幕上的實際幀率。
- [ ] 測試中螢幕不會變暗或休眠。
- [ ] 下載後的 `.dmg`（含 quarantine 屬性）可直接開啟，Gatekeeper 不阻擋。
- [ ] `Cmd+Q` 結束程式；`Esc` 關閉測試視窗。
- [ ] **Windows 回歸清單（`os.md` 8.2）全過。**

---

## 9. 已知限制與後續

| 項目 | 說明 |
| --- | --- |
| 色彩管理 | WKWebView 無法完全繞過 ColorSync；若需要面板原生值，須改以 Metal 原生繪製（違反「繪圖在 JS」原則，暫不做） |
| 縮放解析度 | 非預設解析度時 1px 不等於面板 1 像素，只能提示使用者 |
| 瀏海 | MacBook Pro 瀏海區域在 simple fullscreen 下的行為需實測；可能需要以 `NSScreen.safeAreaInsets` 調整 |
| Mac App Store | 需 App Sandbox 與不同憑證，列為後續 |
| HDR / EDR | 不支援 |

---

## 10. 任務分解

- [ ] 完成 `os.md` P1～P3（前置）。
- [ ] 新增 `macos.rs`：`MacPlatform`（列舉補強、simple fullscreen、keep awake）。
- [ ] `Cargo.toml` 加入 macOS 目標依賴。
- [ ] 新增 `tauri.macos.conf.json`、`macos/Info.plist`、`macos/entitlements.plist`。
- [ ] 以 `tauri icon` 產生 `icon.icns`（保留原 `icon.ico`）。
- [ ] 選擇器縮圖改以 `scale_factor` 換算的邏輯尺寸排版。
- [ ] 前端：字型後備、Display P3 選項、縮放解析度警告、游標隱藏。
- [ ] CI 加入 `macos-latest` job（含簽章、公證 Secrets）。
- [ ] 依第 8 節測試並記錄結果。
