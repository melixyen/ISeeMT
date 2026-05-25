// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod monitor;

use monitor::get_monitors;
use std::collections::HashMap;
use std::sync::Mutex;
use tauri::{Manager, State};

struct WindowMonitors(Mutex<HashMap<String, monitor::MonitorInfo>>);

#[tauri::command]
fn get_monitors_command() -> Result<Vec<monitor::MonitorInfo>, String> {
    get_monitors()
}

#[tauri::command]
async fn open_test_window(
    app: tauri::AppHandle,
    state: State<'_, WindowMonitors>,
    monitor_id: usize,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
) -> Result<(), String> {
    let label = format!("test-{}", monitor_id);

    {
        let mut map = state.0.lock().map_err(|e| e.to_string())?;
        map.insert(
            label.clone(),
            monitor::MonitorInfo {
                id: monitor_id,
                x,
                y,
                width,
                height,
                is_primary: false,
                name: label.clone(),
            },
        );
    }

    if let Some(existing) = app.get_webview_window(&label) {
        existing.close().map_err(|e| e.to_string())?;
    }

    tauri::WebviewWindowBuilder::new(
        &app,
        &label,
        tauri::WebviewUrl::App("index.html".into()),
    )
    .title("ISee Monitor Test")
    .position(x as f64, y as f64)
    .inner_size(width as f64, height as f64)
    .decorations(false)
    .fullscreen(true)
    .build()
    .map_err(|e| e.to_string())?;

    Ok(())
}

#[tauri::command]
fn get_my_monitor_data(
    window: tauri::WebviewWindow,
    state: State<'_, WindowMonitors>,
) -> Option<monitor::MonitorInfo> {
    state.0.lock().ok()?.get(window.label()).cloned()
}

#[tauri::command]
async fn close_window(window: tauri::WebviewWindow) -> Result<(), String> {
    window.close().map_err(|e| e.to_string())
}

#[tauri::command]
async fn close_app(app: tauri::AppHandle) -> Result<(), String> {
    app.exit(0);
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .manage(WindowMonitors(Mutex::new(HashMap::new())))
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            get_monitors_command,
            open_test_window,
            get_my_monitor_data,
            close_window,
            close_app
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
