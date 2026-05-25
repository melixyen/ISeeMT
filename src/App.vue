<template>
  <div class="app">
    <div v-if="isTestWindow && testMonitor" style="width:100vw;height:100vh">
      <TestPatternDisplay :monitor="testMonitor" :lang="lang" />
    </div>
    <div v-else-if="!isTestWindow" class="selector-wrapper">
      <MonitorSelector :lang="lang" @changeLang="lang = $event" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import MonitorSelector from './components/MonitorSelector.vue'
import TestPatternDisplay from './components/TestPatternDisplay.vue'

const lang = ref('en')
const isTestWindow = ref(false)
const testMonitor = ref(null)

onMounted(async () => {
  if (typeof window !== 'undefined' && window.__TAURI_INTERNALS__) {
    try {
      const { getCurrentWindow } = await import('@tauri-apps/api/window')
      const { invoke } = await import('@tauri-apps/api/core')
      const win = getCurrentWindow()
      if (win.label.startsWith('test-')) {
        isTestWindow.value = true
        testMonitor.value = await invoke('get_my_monitor_data')
      }
    } catch (e) {
      console.error(e)
    }
  }
})
</script>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { overflow: hidden; background: #008080; }

.app { width: 100vw; height: 100vh; overflow: hidden; }

.selector-wrapper {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
