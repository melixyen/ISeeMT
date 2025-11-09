# 開發指南

## 專案架構說明

### 前端架構 (Vue 3)

#### 組件層次
```
App.vue
├── MonitorSelector.vue      # 螢幕選擇器（主畫面）
└── TestPatternDisplay.vue   # 測試圖案顯示（全螢幕測試視窗）
```

#### 獨立組件
- `TestPatterns.vue`: 可獨立使用的測試圖案組件，不依賴 Tauri

### 後端架構 (Rust + Tauri)

#### 模組結構
```
src-tauri/src/
├── main.rs       # 主程式入口，定義 Tauri commands
└── monitor.rs    # Windows API 整合，螢幕偵測功能
```

#### Tauri Commands
- `get_monitors_command()`: 獲取所有螢幕資訊
- `position_window_on_monitor_command()`: 將視窗定位到指定螢幕
- `close_app()`: 關閉應用程式

### 獨立版本 (Standalone)

純 HTML + JavaScript 實作，可在瀏覽器中直接使用：
- `standalone/index.html`: 主頁面
- `standalone/patterns.js`: 測試圖案渲染邏輯

## 開發流程

### 1. 環境設置

#### 安裝 Rust
```bash
# Windows
winget install Rustlang.Rustup

# 或從官網下載
# https://rustup.rs/
```

#### 安裝 Node.js
```bash
# 使用 nvm 或直接下載
# https://nodejs.org/
```

#### 安裝專案依賴
```bash
npm install
```

### 2. 開發模式

#### 啟動開發伺服器
```bash
npm run tauri:dev
```

這會同時啟動：
- Vite 開發伺服器 (http://localhost:1420)
- Tauri 應用程式視窗

#### 只啟動前端
```bash
npm run dev
```

### 3. 建置

#### 建置應用程式
```bash
npm run tauri:build
```

建置產物位於：
- `src-tauri/target/release/iseemt.exe` (Windows)
- `src-tauri/target/release/bundle/` (安裝包)

#### 只建置前端
```bash
npm run build
```

## 新增測試圖案

### 在 Vue 組件中新增

1. 在 `TestPatternDisplay.vue` 中新增按鈕：
```vue
<button @click="showMyPattern">My Pattern</button>
```

2. 實作渲染函數：
```javascript
const showMyPattern = () => {
  stopAnimation()
  clearCanvas()
  
  // 使用 ctx.value 繪製
  ctx.value.fillStyle = '#FF00FF'
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
  
  showControls.value = false
}
```

### 在獨立版本中新增

1. 在 `standalone/index.html` 中新增按鈕：
```html
<button onclick="showPattern('myPattern')">My Pattern</button>
```

2. 在 `standalone/patterns.js` 中新增 case：
```javascript
function showPattern(patternName) {
  // ...
  switch (patternName) {
    // ...
    case 'myPattern':
      drawMyPattern()
      break
  }
}

function drawMyPattern() {
  ctx.fillStyle = '#FF00FF'
  ctx.fillRect(0, 0, canvas.width, canvas.height)
}
```

## Windows API 整合

### 新增螢幕相關功能

在 `src-tauri/src/monitor.rs` 中：

```rust
use windows::Win32::Graphics::Gdi::*;

pub fn my_monitor_function() -> Result<(), String> {
    unsafe {
        // 使用 Windows API
    }
    Ok(())
}
```

在 `src-tauri/src/main.rs` 中註冊 command：

```rust
#[tauri::command]
fn my_command() -> Result<(), String> {
    monitor::my_monitor_function()
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            // ...
            my_command
        ])
        // ...
}
```

## 測試

### 手動測試清單

#### 螢幕偵測
- [ ] 單螢幕環境正常運作
- [ ] 多螢幕環境正確偵測所有螢幕
- [ ] 螢幕配置正確顯示（位置、大小）
- [ ] 主螢幕正確標記

#### 靜態測試圖案
- [ ] 純色顯示正確（白、黑、紅、綠、藍）
- [ ] 灰階顯示正確（128、204）
- [ ] 色階表完整顯示
- [ ] 線條測試正確（水平、垂直、十字）
- [ ] 均勻性測試五點正確顯示

#### 動態測試圖案
- [ ] 灰階波動流暢
- [ ] 方塊動畫正常彈跳
- [ ] 圓形動畫正常呼吸
- [ ] 閃爍測試正常交替
- [ ] 漸變測試流暢

#### 進階功能
- [ ] 亮度堆疊顯示正確
- [ ] 中度堆疊顯示正確
- [ ] 暗度堆疊顯示正確
- [ ] 自訂顏色功能正常
- [ ] 動畫速度調整有效

#### 使用者介面
- [ ] 控制面板正常顯示/隱藏
- [ ] 快捷鍵正常運作
- [ ] 全螢幕模式正常
- [ ] 多語言切換正常

#### 獨立版本
- [ ] 瀏覽器中正常運作
- [ ] 所有測試圖案正常顯示
- [ ] 快捷鍵正常運作

## 常見問題

### Q: Tauri 編譯失敗
A: 確認已安裝 Rust 和 Visual Studio Build Tools (Windows)

### Q: 螢幕偵測不正確
A: 檢查 Windows 顯示設定，確認螢幕配置正確

### Q: 獨立版本無法使用
A: 確認瀏覽器支援 Canvas API，建議使用現代瀏覽器

### Q: 動畫卡頓
A: 檢查硬體加速是否啟用，調整動畫速度參數

## 貢獻指南

1. Fork 專案
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 程式碼風格

### Vue/JavaScript
- 使用 2 空格縮排
- 使用 Composition API
- 優先使用 `const`，必要時使用 `let`
- 函數使用箭頭函數

### Rust
- 遵循 Rust 官方風格指南
- 使用 `cargo fmt` 格式化
- 使用 `cargo clippy` 檢查

## 效能優化建議

1. **Canvas 渲染**
   - 使用 `requestAnimationFrame` 進行動畫
   - 避免不必要的重繪
   - 使用離屏 canvas 進行複雜繪製

2. **記憶體管理**
   - 及時清理動畫定時器
   - 避免記憶體洩漏

3. **Tauri 通訊**
   - 減少前後端通訊次數
   - 批次處理資料

## 參考資源

- [Tauri 官方文件](https://tauri.app/)
- [Vue 3 官方文件](https://vuejs.org/)
- [Canvas API 文件](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)
- [Windows API 文件](https://docs.microsoft.com/en-us/windows/win32/)

