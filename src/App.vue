<template>
  <div class="app">
    <MonitorSelector v-if="!selectedMonitor" @select="handleMonitorSelect" />
    <TestPatternDisplay 
      v-else 
      :monitor="selectedMonitor" 
      @close="handleClose" 
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import MonitorSelector from './components/MonitorSelector.vue'
import TestPatternDisplay from './components/TestPatternDisplay.vue'

const selectedMonitor = ref(null)

const handleMonitorSelect = (monitor) => {
  selectedMonitor.value = monitor
}

const handleClose = () => {
  selectedMonitor.value = null
}
</script>

<style>
.app {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}
</style>

