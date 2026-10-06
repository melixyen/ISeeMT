# Linux 開發計劃

> 前置閱讀：`todo/os.md`（共用架構、`Platform` trait、`PlatformAdapter`、Windows 相容規則）。
> 本文件只描述 Linux 專屬的部分。

---

## 1. 目標與範圍

- 在 Linux 桌面（X11 與 Wayland）上提供與 Windows 版相同的功能：列舉多螢幕、在指定螢幕開全螢幕測試視窗、所有測試圖案。
- 產出 `.deb`、`.rpm`、`.AppImage` 三種套件；x86_64 為主，aarch64 為次要目標。
- 支援的發行版基準：Ubuntu 22.04+、Debian 12+、Fedora 38+、Arch（滾動）。

不在範圍：Flatpak / Snap（列為後續選項，見第 9 節）。

---

## 2. 建置環境

### 2.1 系統套件

Tauri 2 使用 **WebKitGTK 4.1**（不是 4.0）。

```bash
# Debian / Ubuntu
sudo apt update
sudo apt install -y build-essential curl wget file pkg-config libssl-dev \
  libwebkit2gtk-4.1-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev \
  libxdo-dev patchelf

# Fedora
sudo dnf install -y webkit2gtk4.1-devel openssl-devel curl wget file \
  libappindicator-gtk3-devel librsvg2-devel libxdo-devel
sudo dnf group install -y "c-development"

# Arch
sudo pacman -S --needed webkit2gtk-4.1 base-devel curl wget file openssl \
  appmenu-gtk-module libappindicator-gtk3 librsvg xdotool
```

### 2.2 Rust 與 Node

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add x86_64-unknown-linux-gnu    # 預設即有
# aarch64 建議直接在 ARM 主機（或 GitHub ARM runner）上建置，不做交叉編譯
node --version   # 18+
```

`scripts/setup.sh` 可擴充：偵測發行版並提示安裝上述系統套件（缺少 `pkg-config --exists webkit2gtk-4.1` 時給出指令）。

---

## 3. 程式結構調整

依 `os.md` 第 5 節完成 Rust 重構後，Linux 只需新增：

```
src-tauri/
├── tauri.linux.conf.json
└── src/platform/
    ├── desktop_common.rs   # Linux 與 macOS 共用
    └── linux.rs            # LinuxPlatform
```

`Cargo.toml`：

```toml
[target.'cfg(target_os = "linux")'.dependencies]
gtk = "0.18"   # 必須與 tauri 2 內部使用的 gtk-rs 版本一致，否則型別不相容
# 可選：取得連接埠名稱（HDMI-1、DP-2）與更新率
x11rb = { version = "0.13", features = ["randr"], optional = true }

[features]
linux-randr = ["dep:x11rb"]
```

---

## 4. OS API 實作

### 4.1 螢幕列舉 `LinuxPlatform::monitors`

**主要方案：使用 Tauri 內建的 `available_monitors()`**（底層 tao → GDK），X11 與 Wayland 都能用：

```rust
// src/platform/desktop_common.rs
pub fn monitors_via_tauri<R: Runtime>(app: &AppHandle<R>) -> Result<Vec<MonitorInfo>, String> {
    let primary = app.primary_monitor().map_err(|e| e.to_string())?;
    let list = app.available_monitors().map_err(|e| e.to_string())?;
    Ok(list
        .iter()
        .enumerate()
        .map(|(id, m)| {
            let pos = m.position();   // PhysicalPosition<i32>
            let size = m.size();      // PhysicalSize<u32>
            MonitorInfo {
                id,
                x: pos.x,
                y: pos.y,
                width: size.width,
                height: size.height,
                is_primary: primary.as_ref().map_or(id == 0, |p| p.name() == m.name()),
                name: m.name().cloned().unwrap_or_else(|| format!("Monitor {}", id + 1)),
                scale_factor: m.scale_factor(),
                refresh_rate: None,
                is_internal: None,
            }
        })
        .collect())
}
```

**補強方案（feature `linux-randr`，僅 X11）**：用 `x11rb` 的 RandR 擴充讀取 output 名稱（`eDP-1`、`HDMI-1`）、目前 mode 的更新率，依座標與 Tauri 結果合併。Wayland 下 `DISPLAY` 可能仍指向 XWayland，讀到的資料不一定準確，因此只在 `XDG_SESSION_TYPE=x11` 時啟用。

注意事項：
- GDK 在 Wayland 回報的座標是 compositor 的**邏輯版面座標**，混合縮放時與實體像素不同；`scale_factor` 必須一起傳給前端，選擇器縮圖才能正確排版。
- 螢幕順序以 GDK 回報為準，與 Windows 的 `\\.\DISPLAYn` 順序沒有對應關係，屬正常差異。

### 4.2 開啟測試視窗 `LinuxPlatform::open_test_surface`

**X11**：沿用 Windows 的流程（先定位再全螢幕）即可，但要以邏輯座標建立：

```rust
let logical_x = m.x as f64 / m.scale_factor;
let logical_y = m.y as f64 / m.scale_factor;
```

**Wayland**：應用程式**不能**指定視窗的全域座標，`position()` 會被忽略，`fullscreen(true)` 會全螢幕到 compositor 選的那台（通常是目前焦點所在的螢幕）。解法是取得底層 GTK 視窗並呼叫 `fullscreen_on_monitor`：

```rust
// src/platform/linux.rs
use gtk::prelude::*;

fn fullscreen_on<R: Runtime>(win: &tauri::WebviewWindow<R>, monitor_index: i32) -> Result<(), String> {
    let gtk_win = win.gtk_window().map_err(|e| e.to_string())?;
    let screen = gtk_win.screen().ok_or("no GdkScreen")?;
    gtk_win.fullscreen_on_monitor(&screen, monitor_index);
    Ok(())
}
```

流程：
1. `WebviewWindowBuilder` 以 `.visible(false).decorations(false)` 建立視窗（不設 `fullscreen(true)`）。
2. 在主執行緒（`app.run_on_main_thread`）上呼叫 `fullscreen_on(win, id)`，其中 `id` 必須是 **GDK monitor 索引**，因此 `monitors()` 的 `id` 要與 `gdk::Display::monitor(i)` 的順序一致（4.1 的實作即符合）。
3. `win.show()`。

> X11 也可以使用同一條 `fullscreen_on_monitor` 路徑，讓 Linux 只維護一種實作；X11 下它會設定 `_NET_WM_FULLSCREEN_MONITORS`，在大多數視窗管理器上都正確。

**後備方案**：若特定 compositor 不配合，可提示使用者以 XWayland 執行：`GDK_BACKEND=x11 ISeeMT`。在 `.desktop` 檔中提供第二個 Action「以相容模式啟動」。

### 4.3 關閉視窗、結束程式

與 Windows 相同，直接用 Tauri API（`window.close()`、`app.exit(0)`），放在 `desktop_common.rs`。

### 4.4 防止螢幕休眠 `set_keep_awake`

測試時螢幕保護程式或 DPMS 會干擾。透過 D-Bus 呼叫 `org.freedesktop.ScreenSaver.Inhibit`（GNOME、KDE、Xfce 皆支援），或使用跨平台 crate（如 `keepawake`）：

```toml
[target.'cfg(target_os = "linux")'.dependencies]
zbus = { version = "4", default-features = false, features = ["tokio"] }
```

在 `open_test_surface` 時 Inhibit，最後一個測試視窗關閉時 UnInhibit。失敗時只記錄 log，不影響主流程。

### 4.5 開啟外部連結

前端的 `openBlog` 目前用 `window.open`，WebKitGTK 中不一定會交給系統瀏覽器。統一改走 adapter 的 `openExternal`，Tauri 端使用 `tauri-plugin-opener`（或現有 `tauri-plugin-shell` 的 open），內部呼叫 `xdg-open`。

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

### 5.1 `src-tauri/tauri.linux.conf.json`

```json
{
  "bundle": {
    "active": true,
    "targets": ["deb", "rpm", "appimage"],
    "category": "Utility",
    "shortDescription": "Multi-monitor screen testing tool",
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/128x128@2x.png",
      "icons/icon.png"
    ],
    "linux": {
      "deb": {
        "depends": ["libwebkit2gtk-4.1-0", "libgtk-3-0"],
        "section": "utils"
      },
      "rpm": {
        "depends": ["webkit2gtk4.1"]
      },
      "appimage": {
        "bundleMediaFramework": false
      }
    }
  }
}
```

只有 Linux 建置會套用此檔，`tauri.conf.json` 的 `bundle.active: false` 對 Windows 不變。

### 5.2 `.desktop` 檔

Tauri 會自動產生；若要加入「XWayland 相容模式」Action，在 `bundle.linux.deb.desktopTemplate` 指定自訂模板（`src-tauri/linux/iseemt.desktop.hbs`）。

---

## 6. 前端調整（Linux 特有）

1. **字型**：`MS Sans Serif`、`Tahoma` 在 Linux 不存在。CSS `font-family` 改為 `"MS Sans Serif", Tahoma, "DejaVu Sans", "Noto Sans", sans-serif`；繁中文字加上 `"Noto Sans CJK TC", "Noto Sans TC"`。此修改對 Windows 無影響（前面的字型優先）。
2. **WebKitGTK 繪圖問題**：部分 NVIDIA 驅動 + Wayland 組合會出現白畫面或閃爍，可在啟動時設定環境變數 `WEBKIT_DISABLE_DMABUF_RENDERER=1`（在 `lib.rs` 的 `run()` 開頭、僅 `cfg(target_os = "linux")` 下以 `std::env::set_var` 設定，或寫進 `.desktop` 的 `Exec`）。
3. **requestAnimationFrame**：WebKitGTK 會依螢幕更新率節流；動態測試（閃爍、方塊）在高更新率螢幕上的實際頻率需實測記錄。

---

## 7. 建置與打包

```bash
npm ci
npm run tauri build                                 # 依 tauri.linux.conf.json 產出全部格式
npm run tauri build -- --bundles appimage           # 只產出 AppImage
```

產物：

| 格式 | 路徑 |
| --- | --- |
| 執行檔 | `src-tauri/target/release/ISeeMT` |
| DEB | `src-tauri/target/release/bundle/deb/ISeeMT_1.0.0_amd64.deb` |
| RPM | `src-tauri/target/release/bundle/rpm/ISeeMT-1.0.0-1.x86_64.rpm` |
| AppImage | `src-tauri/target/release/bundle/appimage/ISeeMT_1.0.0_amd64.AppImage` |

注意：
- **glibc 相容性**：AppImage / deb 會綁定建置機的 glibc 版本，請在支援範圍內最舊的發行版（Ubuntu 22.04）建置。
- **aarch64**：在 `ubuntu-22.04-arm` runner 上原生建置。
- **簽章**：AppImage 可選擇以 GPG 簽章（`SIGN=1`、`SIGN_KEY` 環境變數）。

### CI job（加入 `os.md` 的矩陣）

```yaml
- os: ubuntu-22.04
  setup: |
    sudo apt-get update
    sudo apt-get install -y libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev patchelf libxdo-dev
```

---

## 8. 測試清單

- [ ] GNOME（Wayland）、GNOME（X11）、KDE Plasma（Wayland）、Xfce（X11）各測一次。
- [ ] 單螢幕、雙螢幕（左右、上下）、混合縮放（100% + 200%）。
- [ ] 選擇器縮圖位置與系統顯示設定一致。
- [ ] 每台螢幕都能開出全螢幕測試視窗，且出現在正確螢幕上（Wayland 特別注意）。
- [ ] 全螢幕時頂部列 / Dock 不會遮擋。
- [ ] 1px 線條測試以放大鏡確認為實體 1 像素（`pixelExact` 開啟時）。
- [ ] 動態測試流暢度；記錄 60Hz / 144Hz 螢幕下的實際幀率。
- [ ] 螢幕保護程式在測試中不會啟動。
- [ ] deb / rpm 安裝與移除；AppImage 在乾淨系統上直接執行。
- [ ] 中文字顯示正常（無豆腐字）。
- [ ] **Windows 回歸清單（`os.md` 8.2）全過。**

---

## 9. 已知限制與後續

| 項目 | 說明 |
| --- | --- |
| Wayland 定位 | 依賴 compositor 實作 `fullscreen_on_monitor`；少數 compositor 可能忽略，提供 XWayland 後備 |
| 色彩管理 | WebKitGTK 一般不做色彩管理，輸出接近原始 sRGB 值，與 macOS 行為不同 |
| HDR | 不支援 |
| Flatpak | 後續可加 `flatpak/com.melixyen.iseemt.yml`，需宣告 `--socket=wayland --socket=fallback-x11 --device=dri` 與 `org.freedesktop.ScreenSaver` talk-name |
| Snap | 後續選項 |

---

## 10. 任務分解

- [ ] 完成 `os.md` P1～P3（前置）。
- [ ] 新增 `desktop_common.rs`：`monitors_via_tauri`、通用 close / exit。
- [ ] 新增 `linux.rs`：`LinuxPlatform`，含 `fullscreen_on_monitor` 流程。
- [ ] `Cargo.toml` 加入 Linux 目標依賴（`gtk`、可選 `x11rb`、`zbus`）。
- [ ] 實作 `set_keep_awake`（ScreenSaver Inhibit）。
- [ ] 新增 `tauri.linux.conf.json`；以 `tauri icon` 產生 PNG 圖示（保留原 `icon.ico`）。
- [ ] CSS 字型後備清單；`WEBKIT_DISABLE_DMABUF_RENDERER` 處理。
- [ ] `scripts/setup.sh` 增加系統套件檢查。
- [ ] CI 加入 `ubuntu-22.04` job，上傳 deb/rpm/AppImage artifact。
- [ ] 依第 8 節測試並把結果記錄到 `BUILD_NOTES.md`。
