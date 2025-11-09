# ISee Monitor Test

多螢幕測試工具 - 使用 Tauri 2.0 + Vue 3 重寫

## 功能特色

### 螢幕管理
- 自動偵測所有連接的螢幕
- 視覺化顯示螢幕配置
- 支援多螢幕獨立測試
- 全螢幕模式顯示測試圖案

### 靜態測試圖案
- **純色測試**: 白色、黑色、紅色、綠色、藍色
- **灰階測試**: 128、204 等級灰階
- **色階表**: 完整 RGB 色階漸層顯示
- **線條測試**: 水平線、垂直線、十字線
- **均勻性測試**: 五點均勻性檢測（中央+四角）

### 動態測試圖案
- **灰階波動**: 0-255 灰階循環動畫
- **方塊動畫**: 彈跳方塊測試
- **圓形動畫**: 呼吸圓形測試
- **閃爍測試**: 黑白交替閃爍
- **漸變測試**: 灰階漸變動畫

### 進階測試
- **亮度堆疊**: 高亮度階層測試（207-255）
- **中度堆疊**: 中等亮度階層測試（128-192）
- **暗度堆疊**: 低亮度階層測試（0-48）
- **自訂顏色**: 支援自訂 RGB 值測試

## 技術架構

### 前端
- **Vue 3**: 使用 Composition API
- **Canvas API**: 高效能圖案渲染
- **獨立組件**: 測試圖案組件可單獨編譯使用

### 後端
- **Tauri 2.0**: 輕量級桌面應用框架
- **Rust**: Windows API 整合
- **Windows API**: 螢幕偵測和視窗定位

## 專案結構

```
ISeeMT/
├── src/                      # Vue 3 前端源碼
│   ├── components/
│   │   ├── MonitorSelector.vue      # 螢幕選擇器
│   │   ├── TestPatternDisplay.vue   # 測試圖案顯示（整合版）
│   │   └── TestPatterns.vue         # 測試圖案（獨立版）
│   ├── App.vue
│   └── main.js
├── src-tauri/                # Rust 後端源碼
│   ├── src/
│   │   ├── main.rs          # 主程式
│   │   └── monitor.rs       # Windows 螢幕 API
│   ├── Cargo.toml
│   └── tauri.conf.json
├── standalone/               # 獨立 HTML 版本
│   ├── index.html           # 可單獨使用的測試頁面
│   └── patterns.js          # 純 JavaScript 實作
├── raw_vb2005/              # 原始 VB.Net 2005 專案
├── package.json
├── vite.config.js
└── README.md
```

## 安裝與使用

### 開發環境需求
- Node.js 18+
- Rust 1.70+
- Windows 10/11 (for full functionality)

### 安裝依賴
```bash
npm install
```

### 開發模式
```bash
npm run tauri:dev
```

### 建置應用程式
```bash
npm run tauri:build
```

建置完成後，執行檔位於：
- Windows: `src-tauri\target\release\ISeeMT.exe`
- 安裝包位於 `src-tauri\target\release\bundle\`

### 使用獨立版本
直接開啟 `standalone/index.html` 即可在瀏覽器中使用測試圖案功能（不需要安裝）。

## 使用說明

### 主程式使用
1. 啟動程式後會顯示螢幕選擇器
2. 點擊要測試的螢幕按鈕
3. 在測試視窗中選擇測試圖案
4. 按 ESC 返回螢幕選擇器
5. 按空白鍵切換控制面板顯示/隱藏

### 獨立版本使用
1. 用瀏覽器開啟 `standalone/index.html`
2. 按 F11 進入全螢幕模式
3. 使用右側控制面板選擇測試圖案
4. 按 ESC 切換控制面板顯示/隱藏
5. 使用左右方向鍵切換測試圖案

## 快捷鍵

- **ESC**: 關閉測試視窗 / 切換控制面板
- **空白鍵**: 切換控制面板顯示
- **F11**: 全螢幕模式（獨立版本）
- **左/右方向鍵**: 切換測試圖案（獨立版本）

## 與原版差異

### 改進之處
1. **跨平台**: 使用 Tauri 2.0，理論上可支援 Windows/macOS/Linux
2. **現代化**: Vue 3 + Rust 技術棧
3. **獨立使用**: 測試圖案組件可單獨編譯成 HTML
4. **更好的性能**: Canvas API 硬體加速渲染
5. **更小的體積**: Tauri 應用程式體積遠小於傳統桌面應用

### 保留功能
- 所有原版測試圖案
- 多螢幕支援
- 全螢幕顯示
- 自訂顏色測試
- 動態測試模式

## 授權

本專案基於原作者 melixyen (極光駭客) 的 VB.Net 版本重寫。

原作者 Blog: http://blog.yam.com/user/melix.html

## 版本歷史

- **v1.0.0** (2024): Tauri 2.0 + Vue 3 重寫版本
- **v0.9.23** (2005): 原始 VB.Net 2005 版本
