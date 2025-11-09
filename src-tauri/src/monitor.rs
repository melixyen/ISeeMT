use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonitorInfo {
    pub id: usize,
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
    pub is_primary: bool,
    pub name: String,
}

#[cfg(target_os = "windows")]
pub fn get_monitors() -> Result<Vec<MonitorInfo>, String> {
    use windows::Win32::Graphics::Gdi::{
        EnumDisplayMonitors, GetMonitorInfoW, HMONITOR, MONITORINFOEXW,
    };
    use windows::Win32::Foundation::{BOOL, LPARAM, RECT};
    use std::sync::Mutex;
    use std::mem;

    static MONITORS: Mutex<Vec<MonitorInfo>> = Mutex::new(Vec::new());

    unsafe extern "system" fn enum_monitor_callback(
        hmonitor: HMONITOR,
        _hdc: windows::Win32::Graphics::Gdi::HDC,
        _lprect: *mut RECT,
        lparam: LPARAM,
    ) -> BOOL {
        let mut monitor_info: MONITORINFOEXW = mem::zeroed();
        monitor_info.monitorInfo.cbSize = mem::size_of::<MONITORINFOEXW>() as u32;

        if GetMonitorInfoW(hmonitor, &mut monitor_info.monitorInfo as *mut _ as *mut _).as_bool() {
            let rect = monitor_info.monitorInfo.rcMonitor;
            let is_primary = monitor_info.monitorInfo.dwFlags & 1 != 0;

            // 將寬字符設備名稱轉換為字符串
            let device_name = String::from_utf16_lossy(
                &monitor_info.szDevice
                    .iter()
                    .take_while(|&&c| c != 0)
                    .map(|&c| c)
                    .collect::<Vec<u16>>(),
            );

            let monitors = &mut *(lparam.0 as *mut Vec<MonitorInfo>);
            let id = monitors.len();

            monitors.push(MonitorInfo {
                id,
                x: rect.left,
                y: rect.top,
                width: (rect.right - rect.left) as u32,
                height: (rect.bottom - rect.top) as u32,
                is_primary,
                name: device_name,
            });
        }

        BOOL::from(true)
    }

    let mut monitors = Vec::new();
    
    unsafe {
        EnumDisplayMonitors(
            None,
            None,
            Some(enum_monitor_callback),
            LPARAM(&mut monitors as *mut _ as isize),
        );
    }

    Ok(monitors)
}

#[cfg(not(target_os = "windows"))]
pub fn get_monitors() -> Result<Vec<MonitorInfo>, String> {
    // 非 Windows 平台的備用實現
    Ok(vec![MonitorInfo {
        id: 0,
        x: 0,
        y: 0,
        width: 1920,
        height: 1080,
        is_primary: true,
        name: "Primary Monitor".to_string(),
    }])
}

#[cfg(target_os = "windows")]
pub fn position_window_on_monitor(
    window: &tauri::Window,
    _monitor_id: usize,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
) -> Result<(), String> {
    use tauri::PhysicalPosition;
    use tauri::PhysicalSize;

    // 設置視窗位置和大小
    window
        .set_position(PhysicalPosition::new(x, y))
        .map_err(|e| e.to_string())?;

    window
        .set_size(PhysicalSize::new(width, height))
        .map_err(|e| e.to_string())?;

    // 設置為全螢幕
    window.set_fullscreen(true).map_err(|e| e.to_string())?;

    Ok(())
}

#[cfg(not(target_os = "windows"))]
pub fn position_window_on_monitor(
    window: &tauri::Window,
    _monitor_id: usize,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
) -> Result<(), String> {
    use tauri::PhysicalPosition;
    use tauri::PhysicalSize;

    window
        .set_position(PhysicalPosition::new(x, y))
        .map_err(|e| e.to_string())?;

    window
        .set_size(PhysicalSize::new(width, height))
        .map_err(|e| e.to_string())?;

    window.set_fullscreen(true).map_err(|e| e.to_string())?;

    Ok(())
}

