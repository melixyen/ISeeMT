<template>
  <div class="monitor-selector">
    <div class="header">
      <h1>ISee Monitor Test</h1>
      <div class="controls">
        <button @click="toggleLanguage">{{ language === 'en' ? '中文' : 'English' }}</button>
        <button @click="refreshMonitors">{{ t('refresh') }}</button>
        <button @click="closeApp">{{ t('close') }}</button>
      </div>
    </div>

    <div class="monitor-display">
      <h2>{{ t('selectMonitor') }}</h2>
      <div class="monitor-grid" ref="monitorGrid">
        <button
          v-for="monitor in monitors"
          :key="monitor.id"
          class="monitor-button"
          :style="getMonitorButtonStyle(monitor)"
          @click="selectMonitor(monitor)"
        >
          {{ t('monitor') }} {{ monitor.id }}
        </button>
      </div>
    </div>

    <div class="info">
      <div class="selected-info" v-if="hoveredMonitor">
        <h3>{{ t('monitorInfo') }}</h3>
        <p>{{ t('left') }}: {{ hoveredMonitor.x }}</p>
        <p>{{ t('top') }}: {{ hoveredMonitor.y }}</p>
        <p>{{ t('width') }}: {{ hoveredMonitor.width }}</p>
        <p>{{ t('height') }}: {{ hoveredMonitor.height }}</p>
      </div>
    </div>

    <div class="footer">
      <p>{{ t('author') }}: <a href="http://blog.yam.com/user/melix.html" target="_blank">極光駭客</a></p>
      <p>{{ t('version') }}: v1.0.0 (Tauri 2.0)</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'

// Tauri API - 使用靜態導入但處理錯誤
let tauriInvoke = null

// 嘗試導入 Tauri API（僅在建置時可用）
const initTauriAPI = async () => {
  try {
    if (typeof window !== 'undefined' && window.__TAURI_INTERNALS__) {
      const tauriCore = await import('@tauri-apps/api/core')
      tauriInvoke = tauriCore.invoke
    }
  } catch (e) {
    console.warn('Tauri API not available, using mock data')
  }
}

// 包裝 invoke 函數
const invoke = async (cmd, args) => {
  // 確保 Tauri API 已初始化
  if (!tauriInvoke && typeof window !== 'undefined' && window.__TAURI_INTERNALS__) {
    await initTauriAPI()
  }

  if (tauriInvoke) {
    return await tauriInvoke(cmd, args)
  }

  // Mock data for non-Tauri environment
  if (cmd === 'get_monitors_command') {
    return [
      { id: 0, x: 0, y: 0, width: 1920, height: 1080, is_primary: true, name: 'Monitor 1' }
    ]
  }
  return null
}

const emit = defineEmits(['select'])

const monitors = ref([])
const hoveredMonitor = ref(null)
const language = ref('en')

const translations = {
  en: {
    refresh: 'Refresh',
    close: 'Close',
    selectMonitor: 'Select display monitor',
    monitor: 'Monitor',
    monitorInfo: 'Monitor Information',
    left: 'Left',
    top: 'Top',
    width: 'Width',
    height: 'Height',
    author: 'Author',
    version: 'Version'
  },
  zh: {
    refresh: '重新整理',
    close: '關閉程式',
    selectMonitor: '選擇一個您要測試的螢幕',
    monitor: '螢幕',
    monitorInfo: '螢幕資訊',
    left: '左邊界',
    top: '上邊界',
    width: '寬度',
    height: '高度',
    author: '程式作者',
    version: '版本'
  }
}

const t = (key) => {
  return translations[language.value][key] || key
}

const toggleLanguage = () => {
  language.value = language.value === 'en' ? 'zh' : 'en'
}

const refreshMonitors = async () => {
  try {
    const monitorList = await invoke('get_monitors_command')
    monitors.value = monitorList
  } catch (error) {
    console.error('Failed to get monitors:', error)
  }
}

const selectMonitor = (monitor) => {
  emit('select', monitor)
}

const closeApp = async () => {
  try {
    await invoke('close_app')
  } catch (error) {
    console.error('Failed to close app:', error)
  }
}

const getMonitorButtonStyle = (monitor) => {
  // 計算虛擬桌面的範圍
  const minX = Math.min(...monitors.value.map(m => m.x))
  const minY = Math.min(...monitors.value.map(m => m.y))
  const maxX = Math.max(...monitors.value.map(m => m.x + m.width))
  const maxY = Math.max(...monitors.value.map(m => m.y + m.height))
  
  const virtualWidth = maxX - minX
  const virtualHeight = maxY - minY
  
  // 縮放比例
  const scale = 0.15
  const offsetX = 50
  const offsetY = 100
  
  return {
    position: 'absolute',
    left: `${(monitor.x - minX) * scale + offsetX}px`,
    top: `${(monitor.y - minY) * scale + offsetY}px`,
    width: `${monitor.width * scale}px`,
    height: `${monitor.height * scale}px`
  }
}

onMounted(() => {
  refreshMonitors()
})
</script>

<style scoped>
.monitor-selector {
  width: 100%;
  height: 100%;
  padding: 20px;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #ccc;
}

.header h1 {
  font-size: 24px;
  color: #333;
}

.controls {
  display: flex;
  gap: 10px;
}

button {
  padding: 8px 16px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

button:hover {
  background: #0056b3;
}

.monitor-display {
  flex: 1;
  position: relative;
  border: 1px solid #ccc;
  background: white;
  border-radius: 4px;
  padding: 20px;
  margin-bottom: 20px;
}

.monitor-display h2 {
  margin-bottom: 20px;
  color: #333;
}

.monitor-grid {
  position: relative;
  width: 100%;
  height: calc(100% - 40px);
}

.monitor-button {
  background: #28a745;
  border: 2px solid #1e7e34;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.monitor-button:hover {
  background: #218838;
}

.info {
  min-height: 120px;
  padding: 15px;
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  margin-bottom: 20px;
}

.selected-info h3 {
  margin-bottom: 10px;
  color: #333;
}

.selected-info p {
  margin: 5px 0;
  color: #666;
}

.footer {
  text-align: center;
  padding-top: 10px;
  border-top: 1px solid #ccc;
  color: #666;
}

.footer a {
  color: #007bff;
  text-decoration: none;
}

.footer a:hover {
  text-decoration: underline;
}
</style>

