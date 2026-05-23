<template>
  <div class="app">
    <div v-if="!selectedMonitor" class="selector-wrapper">
      <MonitorSelector :lang="lang" @select="handleMonitorSelect" @changeLang="lang = $event" />
    </div>
    <TestPatternDisplay
      v-else
      :monitor="selectedMonitor"
      :lang="lang"
      @close="handleClose"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import MonitorSelector from './components/MonitorSelector.vue'
import TestPatternDisplay from './components/TestPatternDisplay.vue'

const selectedMonitor = ref(null)
const lang = ref('en')

const handleMonitorSelect = (m) => { selectedMonitor.value = m }
const handleClose = () => { selectedMonitor.value = null }
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
