# 建置說明

## 執行檔名稱配置

已將建置出來的執行檔名稱設定為 **`ISeeMT.exe`**（注意大小寫）。

### 配置位置

在 `src-tauri/tauri.conf.json` 中：

```json
{
  "productName": "ISeeMT",
  "mainBinaryName": "ISeeMT",
  ...
}
```

### 說明

- `productName`: 應用程式顯示名稱
- `mainBinaryName`: 主執行檔名稱（不含副檔名）

建置後的執行檔會是：
- Windows: `ISeeMT.exe`
- macOS: `ISeeMT`
- Linux: `ISeeMT`

## 建置步驟

### 前置需求

1. **Node.js** (v18+)
2. **Rust** (v1.70+)
3. **Visual Studio Build Tools** (Windows)

### 安裝 Rust

#### Windows
```bash
# 方法一：使用 winget
winget install Rustlang.Rustup

# 方法二：從官網下載
# https://rustup.rs/
```

安裝完成後，**重新啟動終端機**以載入環境變數。

### 驗證安裝

```bash
# 檢查 Rust
rustc --version
cargo --version

# 檢查 Node.js
node --version
npm --version
```

### 建置命令

```bash
# 1. 安裝依賴（已完成）
npm install

# 2. 建置應用程式
npm run tauri:build
```

### 建置產物位置

建置完成後，檔案位於：

#### Windows
- **執行檔**: `src-tauri\target\release\ISeeMT.exe`
- **MSI 安裝包**: `src-tauri\target\release\bundle\msi\ISeeMT_1.0.0_x64_en-US.msi`
- **NSIS 安裝包**: `src-tauri\target\release\bundle\nsis\ISeeMT_1.0.0_x64-setup.exe`

#### macOS
- **執行檔**: `src-tauri/target/release/ISeeMT`
- **DMG**: `src-tauri/target/release/bundle/dmg/ISeeMT_1.0.0_x64.dmg`
- **App Bundle**: `src-tauri/target/release/bundle/macos/ISeeMT.app`

#### Linux
- **執行檔**: `src-tauri/target/release/ISeeMT`
- **AppImage**: `src-tauri/target/release/bundle/appimage/ISeeMT_1.0.0_amd64.AppImage`
- **DEB**: `src-tauri/target/release/bundle/deb/iseemt_1.0.0_amd64.deb`

## 開發模式

如果你已經安裝了 Rust，可以使用開發模式：

```bash
npm run tauri:dev
```

這會啟動開發伺服器並自動重載變更。

## 目前狀態

✅ **npm 依賴已安裝**
⚠️ **需要安裝 Rust 才能建置 Tauri 應用程式**
✅ **獨立 HTML 版本可直接使用**（已開啟）

## 替代方案

如果暫時不想安裝 Rust，可以使用獨立 HTML 版本：

```bash
# 直接開啟
start standalone\index.html
```

獨立版本包含所有測試圖案功能，只是無法自動偵測多螢幕。

## 安裝 Rust 後的步驟

1. 安裝 Rust（見上方說明）
2. 重新啟動終端機
3. 執行 `npm run tauri:build`
4. 等待建置完成（首次建置可能需要 5-10 分鐘）
5. 在 `src-tauri\target\release\ISeeMT.exe` 找到執行檔

## 常見問題

### Q: 建置時出現 "rustc not found"
A: 需要重新啟動終端機以載入 Rust 環境變數

### Q: 建置時間很長
A: 首次建置需要編譯所有依賴，可能需要 5-10 分鐘，後續建置會快很多

### Q: 需要 Visual Studio Build Tools
A: Windows 使用者需要安裝 Visual Studio Build Tools
```bash
winget install Microsoft.VisualStudio.2022.BuildTools
```
安裝時選擇「Desktop development with C++」工作負載

### Q: 可以跨平台建置嗎？
A: 一般來說需要在目標平台上建置，但可以使用 Docker 或 CI/CD 進行跨平台建置

## 檔案大小參考

- **執行檔**: 約 5-10 MB
- **MSI 安裝包**: 約 8-15 MB
- **NSIS 安裝包**: 約 8-15 MB

實際大小取決於包含的依賴和功能。

## 版本資訊

- **應用程式版本**: 1.0.0
- **產品名稱**: ISeeMT
- **執行檔名稱**: ISeeMT.exe
- **識別碼**: com.melixyen.iseemt

## 更新版本

要更新版本號，修改 `src-tauri/tauri.conf.json`:

```json
{
  "version": "1.0.1",
  ...
}
```

然後重新建置。

---

**準備好建置了嗎？**

如果已安裝 Rust，執行：
```bash
npm run tauri:build
```

如果還沒安裝 Rust，請先安裝：
```bash
winget install Rustlang.Rustup
```

然後重新啟動終端機再建置。

