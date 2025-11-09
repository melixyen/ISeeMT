// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod monitor;

use monitor::{get_monitors, position_window_on_monitor};
use tauri::Manager;

#[tauri::command]
fn get_monitors_command() -> Result<Vec<monitor::MonitorInfo>, String> {
    get_monitors()
}

#[tauri::command]
async fn position_window_on_monitor_command(
    window: tauri::Window,
    monitor_id: usize,
    x: i32,
    y: i32,
    width: u32,
    height: u32,
) -> Result<(), String> {
    position_window_on_monitor(&window, monitor_id, x, y, width, height)
}

#[tauri::command]
async fn close_app(app: tauri::AppHandle) -> Result<(), String> {
    app.exit(0);
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            get_monitors_command,
            position_window_on_monitor_command,
            close_app
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

