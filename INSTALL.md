# 安裝指南

本文件提供詳細的安裝步驟，適合不同使用情境。

## 目錄
- [快速開始（推薦）](#快速開始推薦)
- [完整安裝（開發者）](#完整安裝開發者)
- [常見問題](#常見問題)

---

## 快速開始（推薦）

### 使用獨立 HTML 版本

**適合**: 只想快速測試螢幕，不需要安裝任何軟體

#### 步驟
1. 找到 `standalone` 資料夾
2. 雙擊 `index.html` 檔案
3. 檔案會在瀏覽器中開啟
4. 按 `F11` 進入全螢幕模式
5. 開始測試！

#### 優點
- ✅ 無需安裝
- ✅ 跨平台（Windows/Mac/Linux）
- ✅ 立即可用

#### 缺點
- ⚠ 無法自動偵測多螢幕
- ⚠ 需要手動拖曳視窗到要測試的螢幕

---

## 完整安裝（開發者）

### 使用 Tauri 應用程式

**適合**: 需要完整功能，包括自動多螢幕偵測

### 前置需求

#### 1. 安裝 Node.js

**Windows**:
```bash
# 使用 winget
winget install OpenJS.NodeJS

# 或從官網下載
# https://nodejs.org/
```

**macOS**:
```bash
# 使用 Homebrew
brew install node

# 或從官網下載
# https://nodejs.org/
```

**Linux (Ubuntu/Debian)**:
```bash
# 使用 apt
sudo apt update
sudo apt install nodejs npm

# 或使用 nvm (推薦)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
```

**驗證安裝**:
```bash
node --version  # 應該顯示 v18.0.0 或更高
npm --version   # 應該顯示 9.0.0 或更高
```

#### 2. 安裝 Rust

**Windows**:
```bash
# 從官網下載並執行安裝程式
# https://rustup.rs/

# 或使用 winget
winget install Rustlang.Rustup
```

**macOS/Linux**:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**驗證安裝**:
```bash
rustc --version  # 應該顯示 1.70.0 或更高
cargo --version  # 應該顯示 1.70.0 或更高
```

#### 3. 安裝系統依賴

**Windows**:
- 安裝 [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/)
- 選擇「Desktop development with C++」工作負載

**macOS**:
```bash
xcode-select --install
```

**Linux (Ubuntu/Debian)**:
```bash
sudo apt update
sudo apt install libwebkit2gtk-4.0-dev \
    build-essential \
    curl \
    wget \
    file \
    libssl-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev
```

**Linux (Fedora)**:
```bash
sudo dnf install webkit2gtk4.0-devel \
    openssl-devel \
    curl \
    wget \
    file \
    libappindicator-gtk3-devel \
    librsvg2-devel
```

**Linux (Arch)**:
```bash
sudo pacman -Syu
sudo pacman -S webkit2gtk \
    base-devel \
    curl \
    wget \
    file \
    openssl \
    appmenu-gtk-module \
    gtk3 \
    libappindicator-gtk3 \
    librsvg
```

### 安裝步驟

#### 方法一：使用安裝腳本（推薦）

**Windows**:
```bash
cd ISeeMT
scripts\setup.bat
```

**macOS/Linux**:
```bash
cd ISeeMT
chmod +x scripts/setup.sh
./scripts/setup.sh
```

#### 方法二：手動安裝

```bash
# 1. 進入專案目錄
cd ISeeMT

# 2. 安裝 npm 依賴
npm install

# 3. 驗證安裝
npm run tauri:dev
```

### 開發模式

啟動開發模式（支援熱重載）:
```bash
npm run tauri:dev
```

這會：
1. 啟動 Vite 開發伺服器
2. 啟動 Tauri 應用程式視窗
3. 自動重載程式碼變更

### 建置應用程式

建置正式版本:
```bash
npm run tauri:build
```

建置產物位於:
- **Windows**: `src-tauri/target/release/iseemt.exe`
- **macOS**: `src-tauri/target/release/bundle/dmg/`
- **Linux**: `src-tauri/target/release/bundle/appimage/`

安裝包位於:
- **Windows**: `src-tauri/target/release/bundle/msi/`
- **macOS**: `src-tauri/target/release/bundle/dmg/`
- **Linux**: `src-tauri/target/release/bundle/deb/` 或 `rpm/`

---

## 驗證安裝

### 測試獨立版本
```bash
# 開啟瀏覽器並載入
open standalone/index.html

# 或使用本地伺服器
python -m http.server 8000
# 然後開啟 http://localhost:8000/standalone/index.html
```

### 測試 Tauri 版本
```bash
# 開發模式
npm run tauri:dev

# 應該會看到:
# 1. 螢幕選擇器視窗
# 2. 顯示所有連接的螢幕
# 3. 可以點擊螢幕進行測試
```

---

## 常見問題

### Q: npm install 失敗
**A**: 
1. 確認 Node.js 版本 >= 18
2. 清除快取: `npm cache clean --force`
3. 刪除 `node_modules` 和 `package-lock.json`
4. 重新執行 `npm install`

### Q: Rust 編譯失敗
**A**:
1. 確認 Rust 版本 >= 1.70
2. 更新 Rust: `rustup update`
3. Windows 使用者確認已安裝 Visual Studio Build Tools
4. 清除建置快取: `cargo clean`

### Q: Tauri 啟動失敗
**A**:
1. 檢查錯誤訊息
2. 確認所有系統依賴已安裝
3. 嘗試重新建置: `npm run tauri:build`
4. 查看 Tauri 文件: https://tauri.app/

### Q: 獨立版本無法開啟
**A**:
1. 確認瀏覽器支援 HTML5 Canvas
2. 嘗試使用現代瀏覽器（Chrome/Edge/Firefox）
3. 使用本地伺服器開啟（避免 CORS 問題）

### Q: 螢幕偵測不正確
**A**:
1. 確認在 Windows 系統上執行（完整功能）
2. 檢查 Windows 顯示設定
3. 重新啟動應用程式
4. 檢查是否有螢幕配置變更

### Q: 動畫卡頓
**A**:
1. 關閉其他佔用資源的程式
2. 確認瀏覽器/系統硬體加速已啟用
3. 降低動畫速度
4. 使用較新的硬體

---

## 解除安裝

### 移除 Tauri 應用程式
```bash
# 刪除專案目錄
rm -rf ISeeMT

# Windows
rmdir /s ISeeMT
```

### 移除開發環境（可選）
```bash
# 解除安裝 Node.js
# Windows: 使用「新增或移除程式」
# macOS: brew uninstall node
# Linux: sudo apt remove nodejs npm

# 解除安裝 Rust
rustup self uninstall
```

---

## 更新

### 更新專案依賴
```bash
# 更新 npm 依賴
npm update

# 更新 Rust 依賴
cd src-tauri
cargo update
```

### 更新 Rust
```bash
rustup update
```

### 更新 Node.js
```bash
# 使用 nvm
nvm install node
nvm use node

# 或從官網下載最新版本
```

---

## 取得協助

如果遇到問題:
1. 查看 [README.md](README.md)
2. 查看 [QUICKSTART.md](QUICKSTART.md)
3. 查看 [DEVELOPMENT.md](DEVELOPMENT.md)
4. 查看 [Tauri 文件](https://tauri.app/)
5. 查看 [Vue 3 文件](https://vuejs.org/)

---

**祝安裝順利！**

