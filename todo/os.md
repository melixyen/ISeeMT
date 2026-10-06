# 跨平台編譯總綱（os.md）

> 目標：把 ISeeMT 從「只在 Windows 完整運作」改造成可以編譯到 **Windows / Linux / macOS / iOS / Android**，另外提供一個純網頁版（Web）；同時**保證現有 Windows 編譯流程與行為完全不受影響**。
>
> 本文件是總綱，定義共用架構、介面與切換機制。各平台細節請見同目錄的 `linux.md`、`mac.md`、`ios.md`、`android.md`、`web.md`。

---

## 1. 設計原則

1. **Windows 零回歸**：`npm install && npm run tauri:build` 在 Windows 上產出的 `ISeeMT.exe`，行為（螢幕列舉順序、名稱、視窗定位、快捷鍵）必須與改造前一致。所有改動都要能用「Windows 回歸清單」（第 8 節）驗證。
2. **核心邏輯只有一份**：測試圖案的繪製、動畫、設定狀態、多語系屬於「核心」，所有平台共用，不得出現平台分支。
3. **平台差異集中在介面層**：前端只透過 `PlatformAdapter` 與外界溝通；Rust 只透過 `Platform` trait 呼叫 OS API。業務程式碼裡不得出現 `window.__TAURI_INTERNALS__`、`#[cfg(target_os)]` 這類判斷。
4. **編譯期切換優先於執行期判斷**：Rust 以 `cfg` + `[target.*.dependencies]` 切換；前端以 Vite alias 切換 adapter，讓 Web 版的 bundle 中完全沒有 `@tauri-apps/*`。
5. **既有公開介面只增不改**：Tauri command 名稱、參數、`MonitorInfo` 欄位只能新增（並加 `#[serde(default)]`），不能改名或刪除。
6. **能力（capability）驅動 UI**：各平台回報自己支援什麼（多視窗、多螢幕、可否結束程式、有無實體鍵盤⋯），UI 依能力顯示或隱藏功能，而不是依平台名稱寫死。

---

## 2. 現況盤點：哪些地方綁死 Windows / Tauri

| 位置 | 問題 | 影響平台 |
| --- | --- | --- |
| `src-tauri/src/monitor.rs` | 只有 Win32 實作，其他平台回傳寫死 1920×1080 | Linux/macOS/行動 |
| `src-tauri/src/main.rs` | 只有 `fn main()`，沒有 `lib.rs` 與 `#[tauri::mobile_entry_point]` | iOS/Android 無法編譯 |
| `open_test_window` | 依賴「開新視窗 + 指定座標 + fullscreen」；行動平台只有單一視窗 | iOS/Android |
| `open_test_window` | Win32 回傳實體像素，但 `WebviewWindowBuilder::position/inner_size` 吃邏輯像素 | Windows（縮放≠100%）、macOS Retina |
| `MonitorSelector.vue`、`TestPatternDisplay.vue` | 各自複製一份 `invoke` 包裝，直接呼叫 command 名稱 | 全部（難以替換成 Web/行動實作） |
| `TestPatternDisplay.vue` | 約 1000 行，UI、狀態、繪圖混在一起；canvas 未乘 `devicePixelRatio` | 高 DPI（macOS/行動）1px 線不準 |
| 鍵盤操作 | `Esc`、`+`、`-`、右鍵 | 行動裝置沒有鍵盤／右鍵 |
| `MonitorSelector.vue` | 固定寬度 784px、字型 `MS Sans Serif` | 手機版面、Linux/macOS 字型 |
| `vite.config.js` | 用 Tauri v1 的 `TAURI_DEBUG`；未設定 `TAURI_DEV_HOST` | 行動裝置 dev 模式連不到 dev server |
| `tauri.conf.json` | `bundle.active=false`、只有 `icon.ico` | 其他平台無法打包 |
| `.gitignore` | 忽略 `Cargo.lock`、`package-lock.json`、`src-tauri/gen/` | CI 不可重現；行動專案無法保存客製化 |
| `standalone/` | 手寫、與 Vue 版重複且功能較少 | Web 版維護成本 |

---

## 3. 目標架構

```
┌─────────────────────────────────────────────────────────────┐
│                     UI 層（Vue 元件）                        │
│   MonitorSelector.vue   TestPatternDisplay.vue   ControlPanel │
└───────────────┬──────────────────────────────┬──────────────┘
                │ 只依賴                        │ 只依賴
┌───────────────▼──────────────┐  ┌────────────▼──────────────┐
│ 核心層 src/core/（純 JS）     │  │ 平台介面層 src/platform/   │
│ patterns/ 圖案繪製函式        │  │ PlatformAdapter 介面       │
│ animation.js 動畫排程         │  │ ├─ tauri.js（桌面＋行動）  │
│ canvas.js DPR／尺寸處理       │  │ └─ web.js（瀏覽器）        │
│ input.js 鍵盤/觸控→動作       │  └────────────┬──────────────┘
│ state.js 測試設定             │               │ invoke / 瀏覽器 API
└──────────────────────────────┘  ┌────────────▼──────────────┐
                                  │ Rust：src-tauri/src/       │
                                  │ commands.rs（固定介面）    │
                                  │ platform/ Platform trait   │
                                  │ ├─ windows.rs  （Win32）   │
                                  │ ├─ desktop_common.rs       │
                                  │ ├─ linux.rs  （GTK/X11）   │
                                  │ ├─ macos.rs  （AppKit）    │
                                  │ └─ mobile.rs （呼叫外掛）  │
                                  │ plugins/iseemt-display/    │
                                  │ ├─ ios/ （Swift）          │
                                  │ └─ android/（Kotlin）      │
                                  └───────────────────────────┘
```

---

## 4. 前端調整

### 4.1 目錄結構（目標）

```
src/
├── main.js
├── App.vue                    # 只負責「選擇器 / 測試畫面」路由，不再碰 Tauri
├── platform/
│   ├── index.js               # 匯出目前平台的 adapter（由 Vite alias 決定）
│   ├── types.js               # JSDoc 型別：DisplayInfo、Capabilities、PlatformAdapter
│   ├── tauri.js               # Tauri 實作（桌面與行動共用，差異由 Rust 端吸收）
│   └── web.js                 # 瀏覽器實作（見 web.md）
├── core/
│   ├── canvas.js              # 建立 canvas、處理 devicePixelRatio、resize
│   ├── animation.js           # setInterval / requestAnimationFrame 統一排程與清理
│   ├── input.js               # 鍵盤、滑鼠、觸控 → 統一動作（toggle-panel、close、gray+、gray-…）
│   ├── state.js               # 測試設定（rgb、gray、line 寬度…），可序列化
│   └── patterns/
│       ├── solid.js           # 純色、quickBack、fullBack
│       ├── colorTable.js      # 色階表、色彩牆、色輪
│       ├── lines.js           # 橫線、縱線、十字線、九宮格
│       ├── stacks.js          # Light/Med/Low/Dark Stack
│       ├── uniformity.js
│       ├── text.js            # Text1/2/3 文字樣板
│       └── animated.js        # 灰階波動、方塊、圓、閃爍、漸變
├── components/
│   ├── MonitorSelector.vue
│   ├── TestPatternDisplay.vue # 只剩 canvas + 控制面板 + 呼叫 core
│   └── ControlPanel.vue       # 從 TestPatternDisplay 拆出
├── composables/useI18n.js
└── locales/
```

**繪圖函式的統一簽章**（純函式，不依賴 Vue、不依賴平台）：

```js
// src/core/patterns/lines.js
/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {{ width:number, height:number, dpr:number }} surface  實體像素尺寸
 * @param {object} opts  例如 { color1:[r,g,b], color2:[r,g,b], w1:1, w2:1 }
 */
export function drawHorizontalLines(ctx, surface, opts) { /* ... */ }
```

拆分方式：把 `TestPatternDisplay.vue` 內 `drawLine9a`、`drawGTable`、`drawLevelStack`、`drawUniformity`、`doHorizontalLine`… 逐一搬到 `core/patterns/`，Vue 元件只保留「讀取設定 → 呼叫繪圖函式 → hidePanel()」。**每搬一個圖案就在 Windows 上目視比對一次**，確保像素輸出不變。

### 4.2 PlatformAdapter 介面

```js
// src/platform/types.js
/**
 * @typedef {Object} DisplayInfo
 * @property {number}  id
 * @property {number}  x            虛擬桌面座標（實體像素）
 * @property {number}  y
 * @property {number}  width        實體像素
 * @property {number}  height
 * @property {boolean} is_primary
 * @property {string}  name
 * @property {number} [scale_factor]  新增欄位，預設 1
 * @property {number} [refresh_rate]  新增欄位，Hz，未知為 undefined
 * @property {boolean} [is_internal]  新增欄位，內建面板（筆電 / 手機）
 */

/**
 * @typedef {Object} Capabilities
 * @property {boolean} multiDisplay        能列舉多台螢幕
 * @property {boolean} multiWindow         每台螢幕可開獨立視窗
 * @property {boolean} canExitApp          可由程式結束（iOS 為 false）
 * @property {boolean} hasPhysicalKeyboard 預期有實體鍵盤（決定提示文字）
 * @property {boolean} fullscreenNeedsGesture 進全螢幕需要使用者手勢（Web）
 * @property {boolean} keepAwake           支援防止螢幕休眠
 */

/**
 * @typedef {Object} PlatformAdapter
 * @property {string} name                       'tauri-windows' | 'tauri-linux' | ... | 'web'
 * @property {() => Promise<Capabilities>} getCapabilities
 * @property {() => Promise<DisplayInfo[]>} listDisplays
 * @property {(d: DisplayInfo) => Promise<void>} openTestSurface
 * @property {() => Promise<{role:'selector'|'test', display?:DisplayInfo}>} getSurfaceContext
 * @property {(cb: () => void) => () => void} onSurfaceChanged   同一視窗內切換選擇器／測試畫面時通知（行動、Web）
 * @property {() => Promise<void>} closeTestSurface
 * @property {() => Promise<void>} exitApp
 * @property {(url: string) => Promise<void>} openExternal
 * @property {(on: boolean) => Promise<void>} setKeepAwake
 * @property {(cb: (displays: DisplayInfo[]) => void) => () => void} onDisplaysChanged
 */
```

`tauri.js` 的實作就是把現有 command 包起來，**名稱與參數完全不變**：

```js
// src/platform/tauri.js（節錄）
import { invoke } from '@tauri-apps/api/core'
import { getCurrentWindow } from '@tauri-apps/api/window'

export default {
  name: `tauri-${import.meta.env.TAURI_ENV_PLATFORM ?? 'unknown'}`,
  getCapabilities: () => invoke('get_capabilities'),   // 新增 command（避免 top-level await，目前 build target 為 es2021）
  listDisplays: () => invoke('get_monitors_command'),
  openTestSurface: (d) => invoke('open_test_window', {
    monitorId: d.id, x: d.x, y: d.y, width: d.width, height: d.height,
  }),
  async getSurfaceContext() {
    const label = getCurrentWindow().label
    if (!label.startsWith('test-')) return { role: 'selector' }
    return { role: 'test', display: await invoke('get_my_monitor_data') }
  },
  closeTestSurface: () => invoke('close_window'),
  exitApp: () => invoke('close_app'),
  // ...
}
```

上面的 `getSurfaceContext` 是與現況等價的寫法；為了同時支援行動平台，最終會改為「以 `get_my_monitor_data` 是否有值判斷」的統一版本（見 `ios.md` 2.1），桌面行為不變。

行動平台只有單一 WebView，`openTestSurface` 在 Rust 端改為「發出事件讓同一個畫面切到測試模式」，`getSurfaceContext` 則依前端路由判斷，前端 UI 程式碼不需要知道差異（細節見 `ios.md`、`android.md`）。

### 4.3 輸入抽象（核心層）

`core/input.js` 把各種輸入轉成統一動作，桌面與行動共用：

| 動作 | 鍵盤（現行） | 滑鼠（現行） | 觸控（新增） |
| --- | --- | --- | --- |
| `close` | `Esc` | — | 雙指點擊 / Android 返回鍵 |
| `togglePanel` | — | 右鍵顯示、左鍵隱藏 | 單指點擊 |
| `grayUp` / `grayDown` | `+` / `-` | — | 上滑 / 下滑 |
| `nextPattern` / `prevPattern` | （Web 版 ←/→） | — | 左滑 / 右滑 |

Windows 上鍵盤與滑鼠的對應保持原樣，觸控只是額外加上去。

### 4.4 Canvas 與 DPI

- `core/canvas.js` 以 `Math.round(innerWidth * devicePixelRatio)` 設定 `canvas.width`，CSS 尺寸維持 `100vw/100vh`，繪圖函式一律以**實體像素**為單位，確保 1px 線就是面板上 1 個像素。
- **Windows 相容策略**：Windows 縮放 100% 時 `dpr = 1`，結果與現況完全相同；縮放非 100% 時屬於行為修正。先以設定旗標 `pixelExact`（預設：Windows 關、其他平台開）導入，在 Windows 回歸測試通過後再改為全平台預設開啟。

### 4.5 依 OS 切換前端實作（Vite）

Tauri 2 CLI 執行 `beforeDevCommand` / `beforeBuildCommand` 時會注入 `TAURI_ENV_PLATFORM`（`windows`/`linux`/`darwin`/`ios`/`android`）、`TAURI_ENV_ARCH`、`TAURI_ENV_DEBUG` 等環境變數，用來在打包時選擇 adapter：

```js
// vite.config.js（目標）
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath } from 'node:url'

const tauriPlatform = process.env.TAURI_ENV_PLATFORM          // Tauri 建置時才有
const host = process.env.TAURI_DEV_HOST                       // 行動裝置 dev 用

export default defineConfig(({ mode }) => {
  const target = mode === 'web' ? 'web' : (tauriPlatform ? 'tauri' : 'web')
  return {
    plugins: [vue()],
    clearScreen: false,
    resolve: {
      alias: {
        '@platform-impl': fileURLToPath(new URL(`./src/platform/${target}.js`, import.meta.url)),
      },
    },
    define: {
      __APP_TARGET__: JSON.stringify(target),
      __APP_OS__: JSON.stringify(tauriPlatform ?? 'browser'),
    },
    server: {
      port: 1420,
      strictPort: true,
      host: host || false,
      hmr: host ? { protocol: 'ws', host, port: 1421 } : undefined,
    },
    envPrefix: ['VITE_', 'TAURI_ENV_'],
    build: {
      target: tauriPlatform === 'windows' ? 'chrome105' : ['es2021', 'chrome100', 'safari13'],
      minify: !process.env.TAURI_ENV_DEBUG ? 'esbuild' : false,
      sourcemap: !!process.env.TAURI_ENV_DEBUG,
      outDir: mode === 'web' ? 'dist-web' : 'dist',
    },
  }
})
```

- `npm run dev`（無 Tauri）在過渡期仍走 `web` adapter，行為等同現在的 fallback。
- Windows 的 `build.target` 可維持現值；上例只是示意可依平台調整，**第一階段請保持原值不動**。
- 舊的 `TAURI_DEBUG` 在 v2 已不會被設定，改成 `TAURI_ENV_DEBUG` 才能真正控制 debug 建置的 sourcemap。

---

## 5. Rust 端調整

### 5.1 Crate 結構（目標）

Tauri 2 的行動平台要求程式以 library 形式提供進入點，因此拆成 `lib.rs` + `main.rs`：

```
src-tauri/
├── Cargo.toml
├── tauri.conf.json              # 共用（維持現狀，Windows 依此建置）
├── tauri.windows.conf.json      # （可選）Windows 專屬覆寫
├── tauri.linux.conf.json        # Linux 專屬覆寫
├── tauri.macos.conf.json        # macOS 專屬覆寫
├── tauri.ios.conf.json          # iOS 專屬覆寫
├── tauri.android.conf.json      # Android 專屬覆寫
├── capabilities/
│   ├── desktop.json             # "platforms": ["windows","linux","macOS"]
│   └── mobile.json              # "platforms": ["iOS","android"]
├── plugins/
│   └── iseemt-display/          # 行動平台原生外掛（Swift / Kotlin）
└── src/
    ├── main.rs                  # 桌面進入點：只呼叫 iseemt_lib::run()
    ├── lib.rs                   # run()：Builder、plugin、invoke_handler
    ├── commands.rs              # 所有 #[tauri::command]，名稱與參數不變
    ├── state.rs                 # WindowMonitors 等共享狀態
    ├── model.rs                 # MonitorInfo、Capabilities
    └── platform/
        ├── mod.rs               # Platform trait + 依 cfg 選出 Current
        ├── windows.rs           # 現有 Win32 程式碼搬入，邏輯不改
        ├── desktop_common.rs    # Linux/macOS 共用：Tauri available_monitors()、建窗
        ├── linux.rs
        ├── macos.rs
        └── mobile.rs            # iOS/Android：轉呼叫 plugins/iseemt-display
```

`Cargo.toml` 新增 library 段落（lib 名稱刻意與執行檔不同，避免 Windows 上 `.pdb` 檔名衝突，這也是 Tauri 官方範本的做法）：

```toml
[lib]
name = "iseemt_lib"
crate-type = ["staticlib", "cdylib", "rlib"]
```

`main.rs` 保留 `windows_subsystem` 屬性，Windows 的執行檔行為不變：

```rust
// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    iseemt_lib::run()
}
```

`lib.rs`：

```rust
mod commands;
mod model;
mod platform;
mod state;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let builder = tauri::Builder::default()
        .manage(state::WindowMonitors::default())
        .plugin(tauri_plugin_shell::init());

    #[cfg(mobile)]
    let builder = builder.plugin(tauri_plugin_iseemt_display::init());

    builder
        .invoke_handler(tauri::generate_handler![
            commands::get_monitors_command,
            commands::open_test_window,
            commands::get_my_monitor_data,
            commands::close_window,
            commands::close_app,
            commands::get_capabilities,   // 新增
            commands::set_keep_awake,     // 新增
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 5.2 Platform trait（OS API 介面）

以**靜態分派**實作：每個平台一個零大小型別，編譯期由 `cfg` 決定 `Current` 是誰，沒有執行期成本，也不會把其他平台的程式碼編進去。

```rust
// src/platform/mod.rs
use crate::model::{Capabilities, MonitorInfo};
use tauri::{AppHandle, Runtime, WebviewWindow};

pub trait Platform {
    /// 列舉所有螢幕；座標與尺寸一律為實體像素、以虛擬桌面左上為原點。
    fn monitors<R: Runtime>(app: &AppHandle<R>) -> Result<Vec<MonitorInfo>, String>;

    /// 在指定螢幕上呈現測試畫面（桌面：開新全螢幕視窗；行動：切換畫面或投放到外接螢幕）。
    fn open_test_surface<R: Runtime>(app: &AppHandle<R>, label: &str, m: &MonitorInfo)
        -> Result<(), String>;

    /// 關閉測試畫面。
    fn close_test_surface<R: Runtime>(window: &WebviewWindow<R>) -> Result<(), String>;

    /// 防止螢幕休眠／變暗。
    fn set_keep_awake<R: Runtime>(app: &AppHandle<R>, on: bool) -> Result<(), String> {
        let _ = (app, on);
        Ok(())
    }

    /// 回報平台能力，供前端決定 UI。
    fn capabilities() -> Capabilities;
}

#[cfg(target_os = "windows")]
mod windows;
#[cfg(target_os = "windows")]
pub use self::windows::WindowsPlatform as Current;

#[cfg(any(target_os = "linux", target_os = "macos"))]
mod desktop_common;

#[cfg(target_os = "linux")]
mod linux;
#[cfg(target_os = "linux")]
pub use self::linux::LinuxPlatform as Current;

#[cfg(target_os = "macos")]
mod macos;
#[cfg(target_os = "macos")]
pub use self::macos::MacPlatform as Current;

#[cfg(mobile)]
mod mobile;
#[cfg(mobile)]
pub use self::mobile::MobilePlatform as Current;
```

`commands.rs` 只認 `platform::Current`：

```rust
use crate::platform::{Current, Platform};

#[tauri::command]
pub fn get_monitors_command(app: tauri::AppHandle) -> Result<Vec<MonitorInfo>, String> {
    Current::monitors(&app)
}
```

> 注意：現有 `get_monitors_command` 沒有參數；加上 `app: AppHandle` 這種由 Tauri 注入的參數不會改變前端呼叫方式，對前端是相容的。

### 5.3 Windows 實作搬遷規則

1. 把 `monitor.rs` 中 `#[cfg(target_os = "windows")] get_monitors()` **原封不動**搬到 `platform/windows.rs` 的 `WindowsPlatform::monitors`。
2. `open_test_window` 內「記錄狀態 → 關閉同名視窗 → `WebviewWindowBuilder` 建窗」的程式碼搬到 `WindowsPlatform::open_test_surface`，第一階段**不改任何參數**。
3. 未使用的 `position_window_on_monitor()` 刪除或移入 `desktop_common.rs`。
4. 實體／邏輯像素的修正（以 `scale_factor` 換算，或先隱藏建窗再 `set_position(PhysicalPosition)`）列為獨立的後續任務，並單獨做 Windows 多螢幕、混合縮放的回歸測試。

### 5.4 MonitorInfo 擴充（向後相容）

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonitorInfo {
    pub id: usize,
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
    pub is_primary: bool,
    pub name: String,
    #[serde(default = "default_scale")]
    pub scale_factor: f64,
    #[serde(default)]
    pub refresh_rate: Option<f64>,
    #[serde(default)]
    pub is_internal: Option<bool>,
}

fn default_scale() -> f64 {
    1.0
}
```

`open_test_window` 內建立 `MonitorInfo` 的地方要補上新欄位（`scale_factor: 1.0, refresh_rate: None, is_internal: None`）。前端不認得的欄位會被忽略，舊 UI 不受影響。

---

## 6. 打包時依 OS 切換函式庫與設定

### 6.1 Cargo：依目標平台引入依賴

```toml
[dependencies]
tauri = { version = "2", features = ["devtools"] }
tauri-plugin-shell = "2"
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# —— Windows（維持現狀，不動）——
[target.'cfg(windows)'.dependencies]
windows = { version = "0.52", features = [
    "Win32_Foundation",
    "Win32_Graphics_Gdi",
    "Win32_UI_WindowsAndMessaging",
    "Win32_System_LibraryLoader",
] }

# —— Linux ——
[target.'cfg(target_os = "linux")'.dependencies]
gtk = "0.18"                 # 版本需與 tauri 內部使用的 gtk 一致
# x11rb = { version = "0.13", features = ["randr"], optional = true }

# —— macOS ——
[target.'cfg(target_os = "macos")'.dependencies]
objc2-app-kit = { version = "0.3", features = ["NSScreen"] }   # 版本需與 tauri 內部使用的 objc2 系列一致
core-graphics = "0.24"

# —— iOS / Android ——
[target.'cfg(any(target_os = "ios", target_os = "android"))'.dependencies]
tauri-plugin-iseemt-display = { path = "plugins/iseemt-display" }
```

Windows 建置只會解析 `cfg(windows)` 那一段，新增的 Linux/macOS/行動依賴**不會**被下載或編譯，`Cargo.lock` 中會出現它們的條目但不影響 Windows 產物。

### 6.2 Tauri 平台設定檔

Tauri 2 會自動把 `tauri.<platform>.conf.json`（`windows`、`linux`、`macos`、`android`、`ios`）以 JSON Merge Patch 方式疊加到 `tauri.conf.json` 上。規則：

- `tauri.conf.json` **保持現狀**（含 `bundle.active: false`），所以 Windows 產物不變。
- 其他平台在各自的設定檔中打開 `bundle.active`、指定 `bundle.targets`、圖示、簽章等。
- 若日後 Windows 也要產出安裝包，在 `tauri.windows.conf.json` 打開，不改共用檔。

```jsonc
// tauri.linux.conf.json（範例）
{
  "bundle": {
    "active": true,
    "targets": ["deb", "rpm", "appimage"],
    "icon": ["icons/32x32.png", "icons/128x128.png", "icons/128x128@2x.png", "icons/icon.png"]
  }
}
```

### 6.3 Capabilities（權限）依平台切分

```jsonc
// src-tauri/capabilities/desktop.json
{
  "identifier": "desktop",
  "platforms": ["windows", "linux", "macOS"],
  "windows": ["main", "test-*"],
  "permissions": ["core:default", "shell:default"]
}
```

```jsonc
// src-tauri/capabilities/mobile.json
{
  "identifier": "mobile",
  "platforms": ["iOS", "android"],
  "windows": ["main"],
  "permissions": ["core:default", "iseemt-display:default"]
}
```

導入 capabilities 檔之後要在 Windows 上確認既有 command 與 `getCurrentWindow()` 仍可正常呼叫。

### 6.4 圖示

目前只有 `icons/icon.ico`。以一張 1024×1024 PNG 執行：

```bash
npm run tauri icon path/to/app-icon.png
```

會產生 Windows（`.ico`）、macOS（`.icns`）、Linux（PNG）與 iOS/Android 所需的所有尺寸。**注意：會覆寫 `icon.ico`**，若要保留現有 Windows 圖示，先備份並在產生後還原，或以原 `.ico` 抽出最大尺寸作為來源。

### 6.5 npm scripts（新增，不改既有）

```jsonc
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "tauri": "tauri",
    "tauri:dev": "tauri dev",
    "tauri:build": "tauri build",

    "build:web": "vite build --mode web",
    "dev:web": "vite --mode web",
    "tauri:build:linux": "tauri build --bundles deb,rpm,appimage",
    "tauri:build:mac": "tauri build --target universal-apple-darwin",
    "tauri:ios:dev": "tauri ios dev",
    "tauri:ios:build": "tauri ios build",
    "tauri:android:dev": "tauri android dev",
    "tauri:android:build": "tauri android build"
  }
}
```

---

## 7. 建置環境與 CI

### 7.1 各平台建置主機

| 目標 | 必須在何處建置 | 主要工具鏈 |
| --- | --- | --- |
| Windows | Windows | MSVC Build Tools、WebView2 |
| Linux | Linux（建議 Ubuntu 22.04 以取得較舊的 glibc） | webkit2gtk-4.1、gtk3 |
| macOS | macOS | Xcode CLT、`aarch64/x86_64-apple-darwin` |
| iOS | macOS | Xcode、CocoaPods、`aarch64-apple-ios(-sim)` |
| Android | 任一桌面 OS | Android SDK/NDK、JDK 17、4 個 Android Rust targets |
| Web | 任一 | 只需 Node.js |

Tauri 不支援可靠的跨 OS 交叉編譯，請用 CI 矩陣在各自主機上建置。

### 7.2 GitHub Actions 矩陣（概念）

```yaml
jobs:
  desktop:
    strategy:
      fail-fast: false
      matrix:
        include:
          - os: windows-latest   # 回歸基準
            args: ''
          - os: ubuntu-22.04
            args: ''
          - os: macos-latest
            args: '--target universal-apple-darwin'
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - uses: dtolnay/rust-toolchain@stable
        with:
          targets: ${{ matrix.os == 'macos-latest' && 'aarch64-apple-darwin,x86_64-apple-darwin' || '' }}
      - if: matrix.os == 'ubuntu-22.04'
        run: |
          sudo apt-get update
          sudo apt-get install -y libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf
      - run: npm ci
      - uses: tauri-apps/tauri-action@v0
        with: { args: '${{ matrix.args }}' }
  web:
    runs-on: ubuntu-latest
    steps: [ ... npm ci && npm run build:web ... ]
```

行動平台的 job 見 `ios.md`、`android.md`。

### 7.3 可重現建置

建議把 `Cargo.lock`、`package-lock.json` 從 `.gitignore` 移除並提交（應用程式專案的慣例），否則各平台 CI 拿到的依賴版本可能不同，難以判斷回歸原因。`src-tauri/gen/` 的處理見 `ios.md` / `android.md`。

---

## 8. Windows 相容性保證

### 8.1 不可更動清單

- `tauri.conf.json` 的 `productName`、`mainBinaryName`、`identifier`、`app.windows[0]`、`bundle.active`。
- `main.rs` 的 `windows_subsystem` 屬性。
- Command 名稱：`get_monitors_command`、`open_test_window`、`get_my_monitor_data`、`close_window`、`close_app`，以及它們的參數名稱。
- 測試視窗 label 格式 `test-{id}`。
- `windows` crate 版本與 features（升級另開任務）。
- `npm run tauri:build`、`npm run tauri:dev` 指令本身。

### 8.2 Windows 回歸清單（每個階段結束都要跑）

- [ ] `npm run tauri:build` 成功，產出 `src-tauri/target/release/ISeeMT.exe`，檔名大小寫正確。
- [ ] 啟動後沒有多餘的主控台視窗。
- [ ] 單螢幕、雙螢幕（含左右、上下、負座標排列）列舉結果與改造前相同（順序、名稱 `\\.\DISPLAYn`、座標）。
- [ ] 點選每台螢幕都在正確螢幕開出無邊框全螢幕視窗；重複點選同一台會先關閉舊視窗。
- [ ] 所有靜態／動態圖案與改造前截圖逐一比對無差異（縮放 100%）。
- [ ] `Esc` 關閉測試視窗、右鍵顯示面板、左鍵隱藏面板、`+`/`-` 調整灰階正常。
- [ ] 「關閉程式」按鈕結束整個程式。
- [ ] 中英文切換正常。

建議在第一階段開始前，先在 Windows 上把每個圖案截圖存檔（不提交到 repo 亦可），作為像素比對基準。

---

## 9. 分階段執行計劃

| 階段 | 內容 | 驗收 |
| --- | --- | --- |
| **P0 準備** | 提交 lock 檔；建立 Windows 截圖基準；CI 先只跑 Windows 建置 | CI 綠燈 |
| **P1 Rust 重構** | 拆 `lib.rs`/`main.rs`/`commands.rs`/`platform/`；Win32 程式碼原樣搬遷；新增 `get_capabilities` | Windows 回歸清單全過 |
| **P2 前端介面層** | 建立 `src/platform/`（tauri、web），兩個元件改用 adapter；修正 `TAURI_ENV_*` | Windows 回歸 + `npm run dev` 瀏覽器可開 |
| **P3 核心抽離** | 圖案繪製搬到 `src/core/patterns/`；`input.js`、`canvas.js` | Windows 截圖比對無差異 |
| **P4 Linux / macOS** | 實作 `linux.rs`、`macos.rs`、平台設定檔、圖示；CI 加入兩平台 | 見各平台文件 |
| **P5 Web** | `web.js` adapter、`build:web`、取代 `standalone/` | 見 `web.md` |
| **P6 行動平台** | 外掛、單視窗模式、觸控操作、響應式 UI | 見 `ios.md`、`android.md` |
| **P7 DPI 修正** | 實體/邏輯像素換算、`pixelExact` 全平台開啟 | 混合縮放多螢幕回歸 |

P1～P3 完成後專案仍只在 Windows 上「完整」運作，但架構已可容納其他平台；每個平台之後可以獨立並行開發。

---

## 10. 風險與對策

| 風險 | 對策 |
| --- | --- |
| 重構時不小心改變 Windows 行為 | 每階段跑回歸清單；Win32 程式碼原樣搬遷；像素截圖比對 |
| 各平台 WebView 引擎不同（WebView2/Chromium、WKWebView、WebKitGTK、Android WebView），Canvas 色彩管理與 `requestAnimationFrame` 頻率不一 | 在各平台文件記錄差異；必要時於 UI 顯示「本平台色彩經系統色彩管理」提示 |
| 行動平台沒有多視窗，與「每台螢幕一個視窗」模型衝突 | 以 `capabilities.multiWindow` 區分，行動平台改為單畫面切換 + 外接螢幕外掛 |
| Wayland 不允許應用程式自行定位視窗 | 改用 GTK `fullscreen_on_monitor`；必要時以 XWayland 執行（見 `linux.md`） |
| `tauri icon` 覆寫既有 `icon.ico` | 先備份或用原圖示作來源 |
| 依賴版本漂移 | 提交 lock 檔，CI 使用 `npm ci` |
