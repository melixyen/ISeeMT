# Web 版開發計劃：抽離 Rust，只用 JavaScript 在瀏覽器全螢幕運作

> 前置閱讀：`todo/os.md` 第 4 節（`PlatformAdapter`、`src/core/` 核心抽離、Vite alias 切換）。
> Web 版**完全不需要 Rust 與 Tauri**，是 `os.md` 架構中的 `web` adapter 實作；同一份 `src/` 原始碼，以不同的建置模式產出。

---

## 1. 目標與範圍

- 以 `npm run build:web` 產出**純靜態網頁**（HTML + JS + CSS），可：
  1. 放到任何靜態主機（GitHub Pages 等）以 https 開啟；
  2. 產出**單一 `index.html` 檔**，雙擊即可離線使用（取代現有手寫的 `standalone/`）。
- 功能與桌面版一致：所有靜態 / 動態測試圖案、控制面板、中英文切換、`+`/`-` 灰階、右鍵面板。
- 點選後進入**瀏覽器全螢幕**（Fullscreen API），不需使用者按 F11。
- 在支援的瀏覽器（Chromium 系列）上，透過 **Window Management API** 列舉多螢幕，並直接在指定螢幕全螢幕顯示。
- 不支援多螢幕 API 的瀏覽器自動降級為「目前螢幕」模式。
- 產出的 bundle 中不得包含任何 `@tauri-apps/*` 程式碼。

---

## 2. 現況

| 項目 | 狀況 |
| --- | --- |
| `npm run dev` | 已可在瀏覽器開啟：`invoke` 包裝偵測不到 `__TAURI_INTERNALS__` 時回傳一台假的 1920×1080 螢幕；但點螢幕按鈕沒有反應（`open_test_window` 回傳 `null`），無法進入測試畫面 |
| `npm run build` | 產出的 bundle 仍含動態載入的 `@tauri-apps/api` chunk |
| `standalone/` | 手寫的 `index.html` + `patterns.js`，圖案種類與操作和 `TestPatternDisplay.vue` 不一致（較少），兩份程式碼需手動同步 |

結論：不另寫一份程式，而是把 Vue 版的平台相依部分換成瀏覽器實作，讓 Web 版自動跟上所有功能。

---

## 3. Rust 功能 → 瀏覽器 API 對照

| 現有 Tauri command / 行為 | 瀏覽器替代方案 | 支援度 |
| --- | --- | --- |
| `get_monitors_command`（Win32 列舉） | `window.getScreenDetails()`（Window Management API） | Chromium 100+；需使用者授權 |
| 〃 降級 | `window.screen` + `devicePixelRatio`（只有目前螢幕） | 全部 |
| `open_test_window`（新視窗 + 定位 + 全螢幕） | 同頁切換到測試畫面 + `element.requestFullscreen({ screen })` | `screen` 選項：Chromium 100+；無選項：全部（iPhone 除外，見第 8 節） |
| 同時在多台螢幕各開一個測試畫面（進階） | `window.open(url, '', 'popup,left,top,width,height')` + 各自全螢幕 | Chromium + 授權 |
| `get_my_monitor_data`（依視窗 label 查狀態） | URL hash：`#/test/<id>` | 全部 |
| `close_window` | `document.exitFullscreen()` + 回到 `#/`；彈出視窗則 `window.close()` | 全部 |
| `close_app` | 不提供（隱藏按鈕）；`capabilities.canExitApp = false` | — |
| 防止螢幕休眠 | Screen Wake Lock API：`navigator.wakeLock.request('screen')` | Chromium 84+、Safari 16.4+、Firefox 126+ |
| 開啟外部連結 | `window.open(url, '_blank', 'noopener')` | 全部 |

---

## 4. 程式結構

```
src/
├── platform/
│   ├── index.js          # export { default } from '@platform-impl'
│   ├── tauri.js          # 桌面 / 行動
│   └── web.js            # ← 本文件的主角
├── core/                 # 與平台無關（os.md 4.1）
│   └── remote.js         # window.ISeeMT 控制 API（Web 版與行動外接螢幕共用）
└── web/
    ├── manifest.webmanifest   # PWA（可選）
    └── sw.js                  # Service Worker（可選，或由 vite-plugin-pwa 產生）
```

`vite.config.js` 依 `mode === 'web'` 把 `@platform-impl` 指向 `src/platform/web.js`（見 `os.md` 4.5）。因為 `web.js` 完全不 import `@tauri-apps/*`，Rollup 不會把 Tauri API 打包進去。

---

## 5. `src/platform/web.js` 實作要點

### 5.1 螢幕列舉

```js
// src/platform/web.js（節錄）
const supportsMultiScreen = typeof window.getScreenDetails === 'function'
let screenDetails = null      // ScreenDetails，授權後取得
let screenObjects = []        // 與 DisplayInfo.id 對應的 ScreenDetailed 物件

const toDisplay = (s, i) => ({
  id: i,
  // 瀏覽器只提供 CSS 像素座標；實體解析度 = width × scale_factor
  x: s.left ?? 0,
  y: s.top ?? 0,
  width: s.width,
  height: s.height,
  is_primary: s.isPrimary ?? i === 0,
  is_internal: s.isInternal,
  name: s.label || `Screen ${i + 1}`,
  scale_factor: s.devicePixelRatio ?? window.devicePixelRatio,
})

async function listDisplays() {
  if (supportsMultiScreen) {
    try {
      // 首次呼叫會跳出權限詢問（window-management），建議由按鈕點擊觸發
      screenDetails ??= await window.getScreenDetails()
      screenObjects = [...screenDetails.screens]
      return screenObjects.map(toDisplay)
    } catch {
      // 使用者拒絕授權 → 降級
    }
  }
  screenObjects = [window.screen]
  return [toDisplay(window.screen, 0)]
}
```

- 選擇器在 Web 版多一個按鈕「偵測所有螢幕」，點擊時才呼叫 `getScreenDetails()`，避免一開頁就跳權限視窗。
- `screenDetails.addEventListener('screenschange', ...)` 對應 adapter 的 `onDisplaysChanged`，插拔螢幕時即時更新選擇器。
- 單位說明：Web 版的 `x/y/width/height` 是 CSS 像素（瀏覽器只提供這個座標系），選擇器顯示解析度時乘上 `scale_factor`。

### 5.2 進入測試畫面與全螢幕

```js
async function openTestSurface(display) {
  // ⚠ requestFullscreen 必須在使用者點擊的「使用者啟用（user activation）」期間呼叫，
  //    因此放在第一行，前面不能有其他 await。
  const target = screenObjects[display.id]
  const opts = { navigationUI: 'hide' }
  if (supportsMultiScreen && target && target !== window.screen) opts.screen = target
  const fs = document.documentElement.requestFullscreen(opts)

  location.hash = `#/test/${display.id}`          // 切換到測試畫面
  await fs
  await setKeepAwake(true)
}
```

`MonitorSelector.vue` 的 `selectMonitor` 目前經由 `invoke` 包裝呼叫（包裝內可能先 `await` 動態 import）；改用 adapter 後必須確保 `platform.openTestSurface(m)` 是點擊處理函式中第一個被呼叫的非同步動作（Safari 對使用者啟用的時效較嚴格）。

### 5.3 畫面狀態（取代視窗 label）

```js
function getSurfaceContext() {
  const m = location.hash.match(/^#\/test\/(\d+)/)
  if (!m) return Promise.resolve({ role: 'selector' })
  const id = Number(m[1])
  const s = screenObjects[id] ?? window.screen
  return Promise.resolve({ role: 'test', display: toDisplay(s, id) })
}

function onSurfaceChanged(cb) {
  window.addEventListener('hashchange', cb)
  return () => window.removeEventListener('hashchange', cb)
}
```

用 hash 而不是 History API，是為了讓 `file://` 與任何靜態主機都能正常運作，也不需要引入 Vue Router。

### 5.4 離開全螢幕 = 關閉測試畫面

在瀏覽器全螢幕中按 `Esc` 會**先被瀏覽器攔截**用來離開全螢幕，頁面的 `keydown` 收不到。因此以 `fullscreenchange` 事件對應桌面版「`Esc` 關閉測試視窗」：

```js
document.addEventListener('fullscreenchange', () => {
  if (!document.fullscreenElement && location.hash.startsWith('#/test/')) {
    closeTestSurface()
  }
})

async function closeTestSurface() {
  if (document.fullscreenElement) await document.exitFullscreen()
  await setKeepAwake(false)
  if (window.opener) window.close()              // 5.6 的多視窗模式（由主視窗開出的彈出視窗）
  else location.hash = '#/'
}
```

如此使用者體驗與桌面版一致：按 `Esc` 回到選擇器。

### 5.5 防止休眠

```js
let wakeLock = null
async function setKeepAwake(on) {
  try {
    if (on && 'wakeLock' in navigator) {
      wakeLock = await navigator.wakeLock.request('screen')
    } else if (!on && wakeLock) {
      await wakeLock.release(); wakeLock = null
    }
  } catch { /* 不支援或被拒絕時忽略 */ }
}
// 分頁切回前景時 Wake Lock 會被系統釋放，需重新取得
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible' && location.hash.startsWith('#/test/')) setKeepAwake(true)
})
```

### 5.6 多螢幕同時測試（進階，僅 Chromium）

桌面版可以同時在每台螢幕開一個測試視窗。Web 版對應做法：

1. 取得 `window-management` 授權後，`window.open(location.href.split('#')[0] + '#/test/' + id, '', \`popup,left=${s.availLeft},top=${s.availTop},width=${s.availWidth},height=${s.availHeight}\`)`，視窗會開在目標螢幕上。
2. 每個彈出視窗**各自需要一次使用者點擊**才能進全螢幕：彈出視窗載入後顯示「點擊此處進入全螢幕」覆蓋層，點擊後 `requestFullscreen()`。
3. 主視窗與彈出視窗之間可用 `BroadcastChannel('iseemt')` 同步圖案（例如「所有螢幕同時切白畫面」），訊息格式沿用 `core/remote.js` 的 `apply(pattern, options)`。

需要瀏覽器允許彈出視窗；被封鎖時提示使用者。

### 5.7 Capabilities

```js
capabilities: {
  multiDisplay: supportsMultiScreen,
  multiWindow: supportsMultiScreen,   // 5.6
  canExitApp: false,
  hasPhysicalKeyboard: !matchMedia('(pointer: coarse)').matches,
  fullscreenNeedsGesture: true,
  keepAwake: 'wakeLock' in navigator,
}
```

UI 依此隱藏「關閉程式」、顯示「偵測所有螢幕」按鈕、在觸控裝置上顯示手勢提示（手勢定義見 `ios.md` 4.3，共用 `core/input.js`）。

---

## 6. 測試畫面的瀏覽器細節

| 項目 | 做法 |
| --- | --- |
| 像素精準 | `core/canvas.js` 以 `innerWidth × devicePixelRatio` 設定 canvas 實體尺寸（`os.md` 4.4）；瀏覽器縮放（Ctrl +/-）會改變 `devicePixelRatio`，在測試畫面偵測到 `devicePixelRatio` 與螢幕的 `scale_factor` 不符時提示「請將瀏覽器縮放重設為 100%」 |
| 游標 | 閒置 2 秒後 `cursor: none`，移動滑鼠時恢復 |
| 右鍵 | 沿用現行右鍵顯示面板，`contextmenu` 事件 `preventDefault()` |
| 捲動 / 縮放 | `body { overflow: hidden; touch-action: none; overscroll-behavior: none; }` |
| 選字 | 測試畫面 `user-select: none` |
| 動畫 | 動態測試以 `requestAnimationFrame` + `performance.now()` 計時；分頁切到背景時瀏覽器會暫停 rAF，回到前景時重設計時基準 |
| 色彩 | Chromium 預設以 sRGB 輸出並做色彩管理；Safari 可選 `colorSpace: 'display-p3'`（同 `mac.md` 6.2） |

---

## 7. 建置

### 7.1 npm scripts

```jsonc
{
  "scripts": {
    "dev:web": "vite --mode web",
    "build:web": "vite build --mode web",
    "preview:web": "vite preview --mode web --outDir dist-web"
  }
}
```

### 7.2 Vite 設定（web 模式專屬部分）

```js
// vite.config.js（節錄，與 os.md 4.5 合併）
import { viteSingleFile } from 'vite-plugin-singlefile'

export default defineConfig(({ mode }) => {
  const isWeb = mode === 'web'
  return {
    base: isWeb ? './' : '/',                       // 相對路徑，任何子目錄與 file:// 都可用
    plugins: [vue(), ...(isWeb ? [viteSingleFile()] : [])],
    build: {
      outDir: isWeb ? 'dist-web' : 'dist',
      ...(isWeb && { assetsInlineLimit: 100_000_000, cssCodeSplit: false }),
    },
    // resolve.alias['@platform-impl'] → src/platform/web.js
  }
})
```

- **為什麼要單檔**：Chrome 以 `file://` 開啟時，`<script type="module" src="./assets/x.js">` 會因 CORS 被擋，頁面一片空白。`vite-plugin-singlefile` 把 JS/CSS 全部內嵌進 `index.html`，雙擊即可執行。
- 新增 devDependency：`vite-plugin-singlefile`（只在 web 模式使用，不影響 Tauri 建置）。
- `dist-web/` 加入 `.gitignore`。

### 7.3 驗證 bundle 不含 Tauri

在 CI 的 web job 中加入檢查：

```bash
npm run build:web
! grep -q "__TAURI" dist-web/index.html
! grep -q "@tauri-apps" dist-web/index.html
```

---

## 8. 各瀏覽器 / 裝置行為

| 環境 | 全螢幕 | 多螢幕 | Wake Lock | 備註 |
| --- | --- | --- | --- | --- |
| Chrome / Edge（桌面） | ✅ | ✅（授權後） | ✅ | 功能最完整 |
| Firefox（桌面） | ✅ | ❌ → 目前螢幕 | ✅（126+） | 需手動把視窗拖到要測的螢幕 |
| Safari（macOS） | ✅ | ❌ → 目前螢幕 | ✅（16.4+） | 色彩管理見第 6 節 |
| Chrome（Android） | ✅ | ❌ | ✅ | 建議安裝為 PWA 以獲得完整全螢幕 |
| Safari（iPadOS） | ✅ | ❌ | ✅ | |
| Safari（iPhone） | ❌（只支援影片元素全螢幕） | ❌ | ✅ | 必須「加入主畫面」以 PWA 方式開啟才能無瀏覽器 UI |
| `file://` 開啟 | ✅ | 依瀏覽器，部分安全情境 API 可能不可用 | 依瀏覽器 | 完整功能建議用 https 或 `localhost` |

降級原則：偵測不到 API 就隱藏對應功能，絕不讓頁面因 API 不存在而報錯。

---

## 9. PWA（可選，但對行動裝置很重要）

讓使用者「安裝」後以全螢幕啟動、離線可用：

```json
// src/web/manifest.webmanifest
{
  "name": "ISee Monitor Test",
  "short_name": "ISeeMT",
  "start_url": "./",
  "display": "fullscreen",
  "background_color": "#000000",
  "theme_color": "#000000",
  "orientation": "any",
  "icons": [
    { "src": "icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

- iOS 另需 `<meta name="apple-mobile-web-app-capable" content="yes">` 與 `<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">`。
- 這些 `<link>` / `<meta>` 只在 web 模式注入：在 Vite 設定中以 `transformIndexHtml` 外掛依 `mode` 加入，`index.html` 本身不改，Tauri 建置不受影響。
- Service Worker 可用 `vite-plugin-pwa` 產生；注意 PWA 版與「單檔版」是兩種產物：PWA 走多檔 + SW 快取，單檔版給離線雙擊使用。可用兩個 mode 區分（`web` 單檔、`pwa` 多檔）。

---

## 10. 部署

GitHub Pages（推薦）：

```yaml
# .github/workflows/web.yml（概念）
on: { push: { branches: [main] } }
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions: { pages: write, id-token: write }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci && npm run build:web
      - uses: actions/upload-pages-artifact@v3
        with: { path: dist-web }
      - uses: actions/deploy-pages@v4
```

Pages 為 https，滿足 Window Management、Wake Lock 等 API 的安全情境要求。

---

## 11. 與 `standalone/` 的關係

1. Web 版功能與 `TestPatternDisplay.vue` 對齊並通過第 12 節測試後，`standalone/index.html` 改為由 `npm run build:web` 產生（把 `dist-web/index.html` 複製過去），刪除手寫的 `patterns.js`。
2. `standalone/README.md` 更新說明：此目錄內容由建置產生，請勿手動修改；新增圖案請改 `src/core/patterns/`。
3. 過渡期保留現有 `standalone/` 不動，避免使用者失去可用版本。

---

## 12. 測試清單

- [ ] `npm run build:web` 產出單一 `dist-web/index.html`，不含 `__TAURI` / `@tauri-apps` 字樣。
- [ ] 直接雙擊 `dist-web/index.html`（`file://`）可在 Chrome、Edge、Firefox、Safari 開啟並使用。
- [ ] 部署到 https 後，Chrome 多螢幕：授權 → 列出所有螢幕 → 點選任一台 → 該螢幕全螢幕顯示。
- [ ] 拒絕授權或不支援的瀏覽器：自動降級為目前螢幕，無錯誤。
- [ ] 按 `Esc` 離開全螢幕後回到選擇器。
- [ ] 所有靜態 / 動態圖案與 Windows 桌面版截圖一致（同一台螢幕、縮放 100%）。
- [ ] `+`/`-`、右鍵面板、中英文切換正常。
- [ ] 1px 線條在 `devicePixelRatio` = 1、1.25、1.5、2 下皆為實體 1 像素；瀏覽器縮放非 100% 時出現提示。
- [ ] 測試中螢幕不休眠；切換分頁回來後仍不休眠。
- [ ] Android Chrome 與 iPad Safari 全螢幕正常；iPhone 以 PWA 開啟無瀏覽器 UI。
- [ ] 插拔螢幕時選擇器即時更新（Chromium）。
- [ ] （進階）多視窗模式：多台螢幕同時全螢幕，`BroadcastChannel` 同步切換圖案。
- [ ] **Windows 桌面版回歸清單（`os.md` 8.2）全過**（Web 版共用 `src/`，任何前端改動都可能影響桌面版）。

---

## 13. 任務分解

- [ ] 完成 `os.md` P2～P3（`src/platform/` 介面層、`src/core/` 核心抽離）。
- [ ] 實作 `src/platform/web.js`：列舉、全螢幕、hash 狀態、`fullscreenchange`、Wake Lock、capabilities。
- [ ] `MonitorSelector.vue`：「偵測所有螢幕」按鈕、確保 `openTestSurface` 在點擊後第一個呼叫。
- [ ] `src/core/remote.js`（`window.ISeeMT` 控制 API）。
- [ ] `vite.config.js` web 模式：alias、`base: './'`、`vite-plugin-singlefile`、`dist-web`。
- [ ] `package.json` 新增 `dev:web`、`build:web`、`preview:web`；`.gitignore` 加入 `dist-web/`。
- [ ] 游標隱藏、瀏覽器縮放偵測、`contextmenu` 處理。
- [ ] （可選）PWA manifest、Service Worker、iOS meta。
- [ ] （進階）多視窗模式與 `BroadcastChannel` 同步。
- [ ] CI：web 建置 + Tauri 字樣檢查 + GitHub Pages 部署。
- [ ] 功能對齊後以建置產物取代 `standalone/`。
