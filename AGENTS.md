# AGENTS.md — ISeeMT 專案導讀

本文件給第一次接觸本專案的開發者與 AI Agent 閱讀，說明專案目的、目錄結構、執行方式、關鍵程式路徑與修改時的注意事項。

---

## 1. 專案是什麼

**ISeeMT（ISee Monitor Test）** 是一套多螢幕顯示器測試工具：

1. 偵測系統上所有螢幕，以「虛擬桌面縮圖」顯示各螢幕的相對位置。
2. 使用者點選某一台螢幕後，在該螢幕上開啟**無邊框全螢幕視窗**。
3. 在全螢幕視窗中繪製各種**靜態**（純色、灰階、色階表、線條、均勻性、堆疊、文字樣板）與**動態**（灰階波動、彈跳方塊、呼吸圓、閃爍、漸變）測試圖案，用來檢查壞點、色偏、均勻性與殘影。

本專案是把 2005 年的 VB.NET（實際為 VB6 格式表單）版本以 **Tauri 2 + Vue 3** 重寫，原始專案保存在 `raw_vb2005/` 作為行為參考。

---

## 2. 技術棧

| 層級 | 技術 | 職責 |
| --- | --- | --- |
| 前端 UI / 繪圖 | Vue 3（Composition API、`<script setup>`）、Canvas 2D | 螢幕選擇器、測試圖案繪製、控制面板、多語系 |
| 建置工具 | Vite 5（dev server 固定在 `1420` port） | 打包前端到 `dist/` |
| 桌面殼 | Tauri 2 | 視窗管理、前後端 IPC |
| 原生層 | Rust（`windows` crate 0.52） | 以 Win32 `EnumDisplayMonitors` / `GetMonitorInfoW` 列舉螢幕 |
| 獨立網頁版 | 純 HTML + JS（`standalone/`） | 不需安裝，瀏覽器開啟即可測試（不支援多螢幕偵測） |

**目前正式支援平台：Windows 10/11**。其他平台的 `get_monitors()` 只回傳一個寫死的 1920×1080 假螢幕（見 `src-tauri/src/monitor.rs`）。跨平台計劃請見 `todo/`。

---

## 3. 目錄結構

```
ISeeMT/
├── AGENTS.md                 # 本文件：專案導讀
├── README.md                 # 使用者面向的說明
├── BUILD_NOTES.md            # 建置細節（執行檔名稱、產物位置）
├── DEVELOPMENT.md            # 開發指南（新增圖案、新增 command）
├── INSTALL.md / QUICKSTART.md / PROJECT_SUMMARY.md
├── index.html                # Vite 入口 HTML
├── package.json              # npm scripts 與前端依賴
├── vite.config.js            # Vite 設定（port 1420、envPrefix TAURI_）
├── src/                      # Vue 3 前端
│   ├── main.js               # 掛載 App
│   ├── App.vue               # 依視窗 label 決定顯示「選擇器」或「測試圖案」
│   ├── components/
│   │   ├── MonitorSelector.vue     # 主視窗：螢幕選擇器（仿 VB FrmMonitorSelect）
│   │   ├── TestPatternDisplay.vue  # 測試視窗：所有圖案與控制面板（仿 VB FrmV1，約 1000 行）
│   │   └── TestPatterns.vue        # 不依賴 Tauri 的簡化版圖案元件（目前 App 未使用）
│   ├── composables/useI18n.js      # 極簡 i18n：回傳 computed 的字典
│   └── locales/{en,zh}.json        # 英文 / 繁中字串
├── src-tauri/                # Tauri / Rust 後端
│   ├── Cargo.toml            # 套件名 iseemt；windows crate 僅在 cfg(windows) 引入
│   ├── tauri.conf.json       # productName/mainBinaryName = ISeeMT，bundle.active = false
│   ├── build.rs
│   ├── icons/icon.ico
│   └── src/
│       ├── main.rs           # Tauri Builder、所有 #[tauri::command]
│       └── monitor.rs        # MonitorInfo 結構、Win32 螢幕列舉、非 Windows fallback
├── standalone/               # 手寫的獨立網頁版（與 Vue 版邏輯重複，需手動同步）
│   ├── index.html
│   └── patterns.js
├── scripts/setup.{sh,bat}    # 檢查 Node/Rust 並 npm install
├── raw_vb2005/               # 原始 VB 專案（.frm/.bas/.cls 為 Big5 編碼），僅供參考，勿修改
└── todo/                     # 開發計劃（跨平台、各 OS、Web 版）
```

---

## 4. 執行與建置

```bash
npm install            # 安裝前端依賴（package-lock.json 被 .gitignore 忽略）
npm run dev            # 只跑前端（瀏覽器開 http://localhost:1420，Tauri API 不可用時走 fallback）
npm run tauri:dev      # 前端 + Tauri 桌面視窗（需 Rust）
npm run build          # 只建置前端到 dist/
npm run tauri:build    # 建置桌面程式，產物：src-tauri/target/release/ISeeMT(.exe)
```

- Windows 需安裝 Visual Studio Build Tools（Desktop development with C++）與 WebView2。
- `tauri.conf.json` 中 `bundle.active` 為 `false`，因此 `tauri:build` 只產出執行檔，不產出 MSI/NSIS 安裝包。
- `Cargo.lock` 與 `package-lock.json` 目前都被 `.gitignore` 忽略，建置結果不保證可重現。

---

## 5. 執行流程（關鍵程式路徑）

### 5.1 主視窗（螢幕選擇器）

1. Tauri 以 `tauri.conf.json` 的 `app.windows[0]` 建立主視窗（label 為 `main`）。
2. `App.vue` 的 `onMounted` 檢查 `window.__TAURI_INTERNALS__`；label 不是 `test-*` 時顯示 `MonitorSelector`。
3. `MonitorSelector.vue` 呼叫 `invoke('get_monitors_command')` → Rust `monitor::get_monitors()` → 回傳 `MonitorInfo[]`。
4. 以 `SCALE = 1/15`（仿 VB 的 twip 換算）把每台螢幕畫成絕對定位的按鈕。

### 5.2 測試視窗

1. 點選螢幕按鈕 → `invoke('open_test_window', { monitorId, x, y, width, height })`。
2. Rust 端把該螢幕資訊存進 `WindowMonitors` 狀態（key 為視窗 label `test-{id}`），若同 label 視窗已存在先關閉，再用 `WebviewWindowBuilder` 建立無邊框、全螢幕的新視窗，載入同一個 `index.html`。
3. 新視窗的 `App.vue` 發現 label 以 `test-` 開頭 → `invoke('get_my_monitor_data')` 取回自己的螢幕資訊 → 顯示 `TestPatternDisplay`。
4. `TestPatternDisplay.vue` 以 `window.innerWidth/innerHeight` 建立 canvas，所有圖案都在 JS 層繪製。按 `Esc` 呼叫 `invoke('close_window')` 關閉視窗。

### 5.3 Tauri Commands 一覽（`src-tauri/src/main.rs`）

| Command | 參數 | 說明 |
| --- | --- | --- |
| `get_monitors_command` | — | 列舉螢幕 |
| `open_test_window` | `monitorId, x, y, width, height` | 在指定座標開全螢幕測試視窗 |
| `get_my_monitor_data` | （由呼叫視窗推得） | 取回此測試視窗對應的螢幕資訊 |
| `close_window` | — | 關閉呼叫者視窗 |
| `close_app` | — | 結束整個程式 |

> 注意：`DEVELOPMENT.md` / `PROJECT_SUMMARY.md` 提到的 `position_window_on_monitor_command` **目前並未註冊**；`monitor.rs` 中的 `position_window_on_monitor()` 也沒有被呼叫，屬於殘留程式碼。

### 5.4 前端對 Tauri 的依賴方式

`MonitorSelector.vue` 與 `TestPatternDisplay.vue` 各自複製了一份 `invoke` 包裝：偵測到 `__TAURI_INTERNALS__` 才動態 `import('@tauri-apps/api/core')`，否則回傳假資料或 `null`。因此 `npm run dev` 在一般瀏覽器中也能開啟畫面。這份包裝是日後抽離成「平台介面層」的起點（見 `todo/os.md`）。

---

## 6. 修改時的注意事項

1. **不要破壞 Windows 版**：任何跨平台改動都必須保持 `npm run tauri:build` 在 Windows 上產出行為一致的 `ISeeMT.exe`。Windows 專用程式碼一律放在 `#[cfg(target_os = "windows")]` 或 `[target.'cfg(windows)'.dependencies]` 之下。
2. **Command 名稱與參數視為公開介面**：前端依賴 `get_monitors_command` 等名稱與 camelCase 參數（Tauri 會自動把 Rust 的 snake_case 參數對應成 camelCase）。`MonitorInfo` 新增欄位請加 `#[serde(default)]`，不要改名或刪除既有欄位。
3. **繪圖邏輯放在 JS**：專案原則是「系統 API 在 Rust，繪製與渲染在 JS」。新增測試圖案時修改 `TestPatternDisplay.vue`；若希望獨立網頁版也有，需同步修改 `standalone/patterns.js`（目前兩份程式碼重複）。
4. **多語系**：新增 UI 文字時同時更新 `src/locales/en.json` 與 `zh.json`，透過 `useI18n(langRef)` 取用。
5. **`raw_vb2005/` 唯讀**：該目錄是行為對照來源，`.frm/.bas/.cls` 為 Big5 編碼，閱讀時可用 `iconv -f big5 -t utf-8`。
6. **已知問題（改動前請留意）**
   - Win32 回傳的是**實體像素**座標，但 `WebviewWindowBuilder::position/inner_size` 吃的是**邏輯像素**，在 Windows 縮放比例非 100% 的多螢幕環境可能定位偏移。
   - Canvas 尺寸用 `window.innerWidth`（CSS 像素）而非乘上 `devicePixelRatio`，在高 DPI 螢幕上 1px 線條測試不是真正的 1 個實體像素。
   - `vite.config.js` 使用 Tauri v1 的環境變數名 `TAURI_DEBUG`，Tauri v2 應為 `TAURI_ENV_DEBUG`。
   - `tauri-plugin-shell` 已初始化但前端未使用。
   - 專案沒有自動化測試，驗證以 `DEVELOPMENT.md` 的手動測試清單為準。

---

## 7. 文件語言與風格

- 專案文件以**繁體中文**撰寫；程式碼識別字與註解沿用既有風格（Rust 註解為繁中、Vue 註解多為英文）。
- JS/Vue：2 空格縮排、Composition API、優先 `const`、箭頭函式。
- Rust：`cargo fmt`、`cargo clippy`。

---

## 8. 開發計劃索引（`todo/`）

| 文件 | 內容 |
| --- | --- |
| `todo/os.md` | 總綱：如何把專案改造成可跨平台編譯，同時維持既有 Windows 建置不受影響 |
| `todo/linux.md` | Linux（X11 / Wayland）建置與實作計劃 |
| `todo/mac.md` | macOS 建置、簽章、公證與實作計劃 |
| `todo/ios.md` | iOS 建置與實作計劃（含外接螢幕） |
| `todo/android.md` | Android 建置與實作計劃（含外接螢幕） |
| `todo/web.md` | 抽離 Rust，只用 JavaScript 在瀏覽器全螢幕運作的計劃 |

建議閱讀順序：`os.md` → 目標平台文件 → `web.md`。
