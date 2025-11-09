# ISee Monitor Test - Standalone Version

這是 ISee Monitor Test 的獨立版本，可以直接在瀏覽器中使用，無需安裝任何軟體。

## 使用方法

### 方法一：直接開啟
1. 雙擊 `index.html` 檔案
2. 檔案會在預設瀏覽器中開啟
3. 按 F11 進入全螢幕模式
4. 開始測試！

### 方法二：本地伺服器（推薦）
如果直接開啟遇到問題，可以使用本地伺服器：

#### 使用 Python
```bash
# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

然後在瀏覽器開啟 `http://localhost:8000/index.html`

#### 使用 Node.js
```bash
npx http-server -p 8000
```

然後在瀏覽器開啟 `http://localhost:8000/index.html`

## 功能說明

### 控制面板
- 位於右上角
- 包含所有測試圖案選項
- 可以使用 ESC 鍵切換顯示/隱藏

### 測試圖案

#### 靜態測試 (Static Tests)
- **White**: 白色純色測試
- **Black**: 黑色純色測試
- **Red**: 紅色純色測試
- **Green**: 綠色純色測試
- **Blue**: 藍色純色測試
- **Gray (128)**: 中灰階測試
- **Gray (204)**: 亮灰階測試

#### 色彩漸層 (Color Gradient)
- **Color Table**: RGB 色階表
- **Gray Wave**: 灰階波動動畫
- **Light Stack**: 高亮度階層測試
- **Med Stack**: 中等亮度階層測試
- **Dark Stack**: 低亮度階層測試

#### 線條測試 (Line Tests)
- **Horizontal**: 水平線測試
- **Vertical**: 垂直線測試
- **Cross Lines**: 十字線測試

#### 均勻性測試 (Uniformity)
- **White**: 白色均勻性測試
- **Black**: 黑色均勻性測試
- **Red**: 紅色均勻性測試
- **Green**: 綠色均勻性測試
- **Blue**: 藍色均勻性測試

#### 動態測試 (Dynamic Tests)
- **Cube**: 彈跳方塊動畫
- **Circle**: 呼吸圓形動畫
- **Blink**: 黑白閃爍測試
- **Interval**: 灰階漸變動畫

#### 自訂顏色 (Custom Color)
- 輸入 RGB 值 (0-255)
- 點擊 Apply 套用

## 快捷鍵

- **ESC**: 切換控制面板顯示/隱藏
- **F11**: 進入/退出全螢幕模式
- **左方向鍵**: 上一個測試圖案
- **右方向鍵**: 下一個測試圖案

## 多螢幕測試

### 方法一：手動拖曳
1. 將瀏覽器視窗拖到要測試的螢幕
2. 按 F11 進入全螢幕
3. 開始測試

### 方法二：開啟多個視窗
1. 複製瀏覽器分頁（Ctrl+Shift+D 或 Cmd+Shift+D）
2. 將不同分頁拖到不同螢幕
3. 分別按 F11 進入全螢幕
4. 可以同時測試多個螢幕

## 瀏覽器相容性

### 完全支援
- ✓ Google Chrome 90+
- ✓ Microsoft Edge 90+
- ✓ Firefox 88+
- ✓ Safari 14+
- ✓ Opera 76+

### 部分支援
- ⚠ Internet Explorer 11 (不支援某些動畫效果)

### 建議
使用最新版本的 Chrome、Edge 或 Firefox 以獲得最佳體驗。

## 測試建議

### 新螢幕檢測
1. **亮點檢測**: 使用黑色背景
2. **暗點檢測**: 使用白色背景
3. **色偏檢測**: 使用紅、綠、藍純色
4. **均勻性檢測**: 使用白色和黑色均勻性測試
5. **動態響應**: 使用方塊動畫檢查殘影

### 日常維護
1. 白色背景快速檢查
2. 黑色背景快速檢查
3. 灰階測試檢查色偏

## 常見問題

### Q: 為什麼無法全螢幕？
A: 
- 確認瀏覽器支援全螢幕 API
- 某些瀏覽器需要使用者互動才能進入全螢幕
- 嘗試點擊頁面後再按 F11

### Q: 動畫卡頓怎麼辦？
A:
- 關閉其他佔用資源的程式
- 確認瀏覽器硬體加速已啟用
- 嘗試使用 Chrome 或 Edge

### Q: 可以離線使用嗎？
A: 可以！所有檔案都是本地的，不需要網路連線。

### Q: 可以修改測試圖案嗎？
A: 可以！編輯 `patterns.js` 檔案即可自訂測試圖案。

## 檔案說明

- `index.html`: 主頁面，包含 UI 結構
- `patterns.js`: 測試圖案渲染邏輯
- `README.md`: 本說明檔案

## 技術細節

### 使用技術
- HTML5 Canvas API
- Vanilla JavaScript (ES6+)
- CSS3

### 渲染方式
- 使用 Canvas 2D Context 進行繪製
- 動畫使用 requestAnimationFrame
- 響應式設計，自動適應視窗大小

## 授權

本專案基於原作者 melixyen (極光駭客) 的 VB.Net 版本重寫。

原作者 Blog: http://blog.yam.com/user/melix.html

## 回報問題

如果遇到問題，請回到主專案目錄查看完整文件：
- [主 README](../README.md)
- [快速開始指南](../QUICKSTART.md)
- [開發指南](../DEVELOPMENT.md)

---

**享受測試！**

