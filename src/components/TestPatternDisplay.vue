<template>
  <div class="test-pattern-display" :style="displayStyle">
    <!-- 控制面板 -->
    <div v-if="showControls" class="control-panel">
      <div class="panel-header">
        <h3>{{ t('testSettings') }}</h3>
        <button @click="toggleControls" class="toggle-btn">{{ t('hide') }}</button>
      </div>

      <div class="panel-content">
        <!-- 靜態測試 -->
        <section class="section">
          <h4>{{ t('staticTests') }}</h4>
          <div class="button-grid">
            <button @click="showSolidColor('white')">{{ t('white') }}</button>
            <button @click="showSolidColor('black')">{{ t('black') }}</button>
            <button @click="showSolidColor('red')">{{ t('red') }}</button>
            <button @click="showSolidColor('green')">{{ t('green') }}</button>
            <button @click="showSolidColor('blue')">{{ t('blue') }}</button>
            <button @click="showGrayLevel(128)">{{ t('gray128') }}</button>
            <button @click="showGrayLevel(204)">{{ t('gray204') }}</button>
          </div>
        </section>

        <!-- 色階測試 -->
        <section class="section">
          <h4>{{ t('colorGradient') }}</h4>
          <div class="button-grid">
            <button @click="showColorTable">{{ t('colorTable') }}</button>
            <button @click="showGrayWave">{{ t('grayWave') }}</button>
            <button @click="showLightStack">{{ t('lightStack') }}</button>
            <button @click="showMedStack">{{ t('medStack') }}</button>
            <button @click="showDarkStack">{{ t('darkStack') }}</button>
          </div>
        </section>

        <!-- 線條測試 -->
        <section class="section">
          <h4>{{ t('lineTests') }}</h4>
          <div class="button-grid">
            <button @click="showHorizontalLines">{{ t('horizontalLines') }}</button>
            <button @click="showVerticalLines">{{ t('verticalLines') }}</button>
            <button @click="showCrossLines">{{ t('crossLines') }}</button>
          </div>
        </section>

        <!-- 均勻性測試 -->
        <section class="section">
          <h4>{{ t('uniformity') }}</h4>
          <div class="button-grid">
            <button @click="showUniformity('white')">{{ t('whiteUniformity') }}</button>
            <button @click="showUniformity('black')">{{ t('blackUniformity') }}</button>
            <button @click="showUniformity('red')">{{ t('redUniformity') }}</button>
            <button @click="showUniformity('green')">{{ t('greenUniformity') }}</button>
            <button @click="showUniformity('blue')">{{ t('blueUniformity') }}</button>
          </div>
        </section>

        <!-- 動態測試 -->
        <section class="section">
          <h4>{{ t('dynamicTests') }}</h4>
          <div class="button-grid">
            <button @click="startAnimation('cube')">{{ t('cube') }}</button>
            <button @click="startAnimation('circle')">{{ t('circle') }}</button>
            <button @click="startAnimation('blink')">{{ t('blink') }}</button>
            <button @click="startAnimation('interval')">{{ t('interval') }}</button>
          </div>
          <div class="control-row">
            <label>{{ t('speed') }}:</label>
            <input v-model.number="animationSpeed" type="range" min="50" max="1000" step="50">
            <span>{{ animationSpeed }}ms</span>
          </div>
        </section>

        <!-- 自訂顏色 -->
        <section class="section">
          <h4>{{ t('customColor') }}</h4>
          <div class="color-inputs">
            <div class="input-group">
              <label>R:</label>
              <input v-model.number="customColor.r" type="number" min="0" max="255">
            </div>
            <div class="input-group">
              <label>G:</label>
              <input v-model.number="customColor.g" type="number" min="0" max="255">
            </div>
            <div class="input-group">
              <label>B:</label>
              <input v-model.number="customColor.b" type="number" min="0" max="255">
            </div>
            <button @click="showCustomColor">{{ t('apply') }}</button>
          </div>
        </section>

        <div class="panel-footer">
          <button @click="handleClose" class="close-btn">{{ t('close') }}</button>
        </div>
      </div>
    </div>

    <!-- 顯示按鈕（當控制面板隱藏時） -->
    <button v-else @click="toggleControls" class="show-controls-btn">{{ t('showControls') }}</button>

    <!-- 測試圖案畫布 -->
    <canvas ref="canvas" class="test-canvas"></canvas>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed, watch } from 'vue'

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
    console.warn('Tauri API not available')
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

  return null
}

const props = defineProps({
  monitor: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const canvas = ref(null)
const ctx = ref(null)
const showControls = ref(true)
const animationSpeed = ref(250)
const animationId = ref(null)
const customColor = ref({ r: 0, g: 0, b: 0 })
const language = ref('en')

const translations = {
  en: {
    testSettings: 'Test Settings',
    hide: 'Hide',
    showControls: 'Show Controls',
    staticTests: 'Static Tests',
    white: 'White',
    black: 'Black',
    red: 'Red',
    green: 'Green',
    blue: 'Blue',
    gray128: 'Gray (128)',
    gray204: 'Gray (204)',
    colorGradient: 'Color Gradient',
    colorTable: 'Color Table',
    grayWave: 'Gray Wave',
    lightStack: 'Light Stack',
    medStack: 'Med Stack',
    darkStack: 'Dark Stack',
    lineTests: 'Line Tests',
    horizontalLines: 'Horizontal Lines',
    verticalLines: 'Vertical Lines',
    crossLines: 'Cross Lines',
    uniformity: 'Uniformity',
    whiteUniformity: 'White',
    blackUniformity: 'Black',
    redUniformity: 'Red',
    greenUniformity: 'Green',
    blueUniformity: 'Blue',
    dynamicTests: 'Dynamic Tests',
    cube: 'Cube',
    circle: 'Circle',
    blink: 'Blink',
    interval: 'Interval',
    speed: 'Speed',
    customColor: 'Custom Color',
    apply: 'Apply',
    close: 'Close'
  },
  zh: {
    testSettings: '測試設定',
    hide: '隱藏',
    showControls: '顯示控制',
    staticTests: '靜態測試',
    white: '白色',
    black: '黑色',
    red: '紅色',
    green: '綠色',
    blue: '藍色',
    gray128: '灰階 (128)',
    gray204: '灰階 (204)',
    colorGradient: '色階測試',
    colorTable: '色階表',
    grayWave: '灰階波動',
    lightStack: '亮度堆疊',
    medStack: '中度堆疊',
    darkStack: '暗度堆疊',
    lineTests: '線條測試',
    horizontalLines: '水平線',
    verticalLines: '垂直線',
    crossLines: '十字線',
    uniformity: '均勻性',
    whiteUniformity: '白色',
    blackUniformity: '黑色',
    redUniformity: '紅色',
    greenUniformity: '綠色',
    blueUniformity: '藍色',
    dynamicTests: '動態測試',
    cube: '方塊',
    circle: '圓形',
    blink: '閃爍',
    interval: '間隔',
    speed: '速度',
    customColor: '自訂顏色',
    apply: '套用',
    close: '關閉'
  }
}

const t = (key) => {
  return translations[language.value][key] || key
}

const displayStyle = computed(() => ({
  width: '100vw',
  height: '100vh',
  overflow: 'hidden'
}))

const toggleControls = () => {
  showControls.value = !showControls.value
}

const handleClose = () => {
  stopAnimation()
  emit('close')
}

const stopAnimation = () => {
  if (animationId.value) {
    cancelAnimationFrame(animationId.value)
    animationId.value = null
  }
}

// 初始化畫布
const initCanvas = () => {
  if (!canvas.value) return
  
  canvas.value.width = window.innerWidth
  canvas.value.height = window.innerHeight
  ctx.value = canvas.value.getContext('2d')
}

// 清除畫布
const clearCanvas = () => {
  if (!ctx.value) return
  ctx.value.clearRect(0, 0, canvas.value.width, canvas.value.height)
}

// 純色顯示
const showSolidColor = (color) => {
  stopAnimation()
  clearCanvas()
  
  const colors = {
    white: '#FFFFFF',
    black: '#000000',
    red: '#FF0000',
    green: '#00FF00',
    blue: '#0000FF'
  }
  
  ctx.value.fillStyle = colors[color] || color
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
  showControls.value = false
}

// 灰階顯示
const showGrayLevel = (level) => {
  stopAnimation()
  clearCanvas()
  
  const hex = level.toString(16).padStart(2, '0')
  ctx.value.fillStyle = `#${hex}${hex}${hex}`
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
  showControls.value = false
}

// 自訂顏色
const showCustomColor = () => {
  stopAnimation()
  clearCanvas()
  
  const { r, g, b } = customColor.value
  ctx.value.fillStyle = `rgb(${r}, ${g}, ${b})`
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
  showControls.value = false
}

// 色階表
const showColorTable = () => {
  stopAnimation()
  clearCanvas()

  const w = canvas.value.width
  const h = canvas.value.height
  const barHeight = h / 32

  // RGB 漸層
  for (let i = 0; i < 256; i++) {
    const x = (i / 256) * (w / 2)
    const width = (w / 2) / 256

    // 紅色漸層
    ctx.value.fillStyle = `rgb(${i}, 0, 0)`
    ctx.value.fillRect(x, barHeight * 3, width, barHeight)

    // 綠色漸層
    ctx.value.fillStyle = `rgb(0, ${i}, 0)`
    ctx.value.fillRect(x, barHeight * 4, width, barHeight)

    // 藍色漸層
    ctx.value.fillStyle = `rgb(0, 0, ${i})`
    ctx.value.fillRect(x, barHeight * 5, width, barHeight)

    // 灰階漸層
    ctx.value.fillStyle = `rgb(${i}, ${i}, ${i})`
    ctx.value.fillRect(x * 2, barHeight * 7, width * 2, barHeight)

    // 右側淡色漸層
    ctx.value.fillStyle = `rgb(255, ${i}, ${i})`
    ctx.value.fillRect(w / 2 + x, barHeight * 3, width, barHeight)

    ctx.value.fillStyle = `rgb(${i}, 255, ${i})`
    ctx.value.fillRect(w / 2 + x, barHeight * 4, width, barHeight)

    ctx.value.fillStyle = `rgb(${i}, ${i}, 255)`
    ctx.value.fillRect(w / 2 + x, barHeight * 5, width, barHeight)
  }

  showControls.value = false
}

// 灰階波動
const showGrayWave = () => {
  stopAnimation()
  clearCanvas()

  let currentGray = 0
  let direction = 1

  const animate = () => {
    ctx.value.fillStyle = `rgb(${currentGray}, ${currentGray}, ${currentGray})`
    ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)

    currentGray += direction
    if (currentGray >= 255 || currentGray <= 0) {
      direction *= -1
    }

    animationId.value = setTimeout(() => {
      requestAnimationFrame(animate)
    }, animationSpeed.value)
  }

  animate()
  showControls.value = false
}

// 亮度堆疊
const showLightStack = () => {
  showLevelStack(207, 255, 3, '#000000')
}

const showMedStack = () => {
  showLevelStack(128, 192, 4, '#000000')
}

const showDarkStack = () => {
  showLevelStack(48, 0, -3, '#FFFFFF')
}

const showLevelStack = (start, end, step, textColor) => {
  stopAnimation()
  clearCanvas()

  const w = canvas.value.width
  const h = canvas.value.height
  const borderW = w / 64
  const borderH = h / 64

  let x = 0, y = 0
  let width = w, height = h
  let level = 0

  ctx.value.font = '20px Arial'
  ctx.value.fillStyle = textColor

  for (let gray = start; step > 0 ? gray <= end : gray >= end; gray += step) {
    ctx.value.fillStyle = `rgb(${gray}, ${gray}, ${gray})`
    ctx.value.fillRect(x, y, width, height)

    ctx.value.fillStyle = textColor
    ctx.value.fillText(level.toString(), x + borderW, y + borderH + 20)

    x += borderW
    y += borderH
    width -= borderW * 2
    height -= borderH * 2
    level++
  }

  showControls.value = false
}

// 水平線
const showHorizontalLines = () => {
  stopAnimation()
  clearCanvas()

  const lineHeight = 15
  let isBlack = true

  for (let y = 0; y < canvas.value.height; y += lineHeight) {
    ctx.value.fillStyle = isBlack ? '#000000' : '#FFFFFF'
    ctx.value.fillRect(0, y, canvas.value.width, lineHeight)
    isBlack = !isBlack
  }

  showControls.value = false
}

// 垂直線
const showVerticalLines = () => {
  stopAnimation()
  clearCanvas()

  const lineWidth = 15
  let isBlack = true

  for (let x = 0; x < canvas.value.width; x += lineWidth) {
    ctx.value.fillStyle = isBlack ? '#000000' : '#FFFFFF'
    ctx.value.fillRect(x, 0, lineWidth, canvas.value.height)
    isBlack = !isBlack
  }

  showControls.value = false
}

// 十字線
const showCrossLines = () => {
  stopAnimation()
  clearCanvas()

  ctx.value.fillStyle = '#808080'
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)

  const w = canvas.value.width
  const h = canvas.value.height

  ctx.value.strokeStyle = '#000000'
  ctx.value.lineWidth = 2

  // 九宮格線
  ctx.value.beginPath()
  ctx.value.moveTo(0, h / 3)
  ctx.value.lineTo(w, h / 3)
  ctx.value.moveTo(0, 2 * h / 3)
  ctx.value.lineTo(w, 2 * h / 3)
  ctx.value.moveTo(w / 3, 0)
  ctx.value.lineTo(w / 3, h)
  ctx.value.moveTo(2 * w / 3, 0)
  ctx.value.lineTo(2 * w / 3, h)
  ctx.value.stroke()

  showControls.value = false
}

// 均勻性測試
const showUniformity = (color) => {
  stopAnimation()
  clearCanvas()

  const colors = {
    white: { fg: '#FFFFFF', bg: '#000000' },
    black: { fg: '#000000', bg: '#FFFFFF' },
    red: { fg: '#FF0000', bg: '#000000' },
    green: { fg: '#00FF00', bg: '#000000' },
    blue: { fg: '#0000FF', bg: '#000000' }
  }

  const { fg, bg } = colors[color]

  ctx.value.fillStyle = bg
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)

  const w = canvas.value.width
  const h = canvas.value.height
  const boxW = w / 4
  const boxH = h / 4

  ctx.value.fillStyle = fg

  // 中央
  ctx.value.fillRect(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

  // 四角
  ctx.value.fillRect(0, 0, boxW, boxH)
  ctx.value.fillRect(w - boxW, 0, boxW, boxH)
  ctx.value.fillRect(0, h - boxH, boxW, boxH)
  ctx.value.fillRect(w - boxW, h - boxH, boxW, boxH)

  showControls.value = false
}

// 動畫：方塊
const startAnimation = (type) => {
  stopAnimation()

  if (type === 'cube') {
    animateCube()
  } else if (type === 'circle') {
    animateCircle()
  } else if (type === 'blink') {
    animateBlink()
  } else if (type === 'interval') {
    animateInterval()
  }

  showControls.value = false
}

const animateCube = () => {
  let x = 0, y = 0
  let dx = 5, dy = 5
  const size = 100

  const animate = () => {
    clearCanvas()
    ctx.value.fillStyle = '#000000'
    ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)

    ctx.value.fillStyle = '#FFFFFF'
    ctx.value.fillRect(x, y, size, size)

    x += dx
    y += dy

    if (x + size >= canvas.value.width || x <= 0) dx *= -1
    if (y + size >= canvas.value.height || y <= 0) dy *= -1

    animationId.value = setTimeout(() => {
      requestAnimationFrame(animate)
    }, 16)
  }

  animate()
}

const animateCircle = () => {
  let radius = 50
  let growing = true
  const maxRadius = Math.min(canvas.value.width, canvas.value.height) / 2

  const animate = () => {
    clearCanvas()
    ctx.value.fillStyle = '#000000'
    ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)

    ctx.value.fillStyle = '#FFFFFF'
    ctx.value.beginPath()
    ctx.value.arc(canvas.value.width / 2, canvas.value.height / 2, radius, 0, Math.PI * 2)
    ctx.value.fill()

    if (growing) {
      radius += 5
      if (radius >= maxRadius) growing = false
    } else {
      radius -= 5
      if (radius <= 50) growing = true
    }

    animationId.value = setTimeout(() => {
      requestAnimationFrame(animate)
    }, animationSpeed.value)
  }

  animate()
}

const animateBlink = () => {
  let isWhite = true

  const animate = () => {
    ctx.value.fillStyle = isWhite ? '#FFFFFF' : '#000000'
    ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)

    isWhite = !isWhite

    animationId.value = setTimeout(() => {
      requestAnimationFrame(animate)
    }, animationSpeed.value)
  }

  animate()
}

const animateInterval = () => {
  let gray = 0
  let increasing = true

  const animate = () => {
    ctx.value.fillStyle = `rgb(${gray}, ${gray}, ${gray})`
    ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)

    if (increasing) {
      gray += 5
      if (gray >= 255) {
        gray = 255
        increasing = false
      }
    } else {
      gray -= 5
      if (gray <= 0) {
        gray = 0
        increasing = true
      }
    }

    animationId.value = setTimeout(() => {
      requestAnimationFrame(animate)
    }, animationSpeed.value)
  }

  animate()
}

onMounted(async () => {
  initCanvas()

  // 設置視窗到指定螢幕
  try {
    await invoke('position_window_on_monitor_command', {
      monitorId: props.monitor.id,
      x: props.monitor.x,
      y: props.monitor.y,
      width: props.monitor.width,
      height: props.monitor.height
    })
  } catch (error) {
    console.error('Failed to position window:', error)
  }

  window.addEventListener('resize', initCanvas)
  window.addEventListener('keydown', handleKeyPress)
})

const handleKeyPress = (e) => {
  if (e.key === 'Escape') {
    handleClose()
  } else if (e.key === ' ') {
    toggleControls()
  }
}

onUnmounted(() => {
  stopAnimation()
  window.removeEventListener('resize', initCanvas)
  window.removeEventListener('keydown', handleKeyPress)
})
</script>

<style scoped>
.test-pattern-display {
  position: relative;
  background: #000;
}

.test-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.control-panel {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 350px;
  max-height: calc(100vh - 40px);
  background: rgba(255, 255, 255, 0.95);
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  z-index: 1000;
  overflow-y: auto;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #ddd;
}

.panel-content {
  padding: 15px;
}

.section {
  margin-bottom: 20px;
}

.section h4 {
  margin-bottom: 10px;
  color: #333;
  font-size: 14px;
}

.button-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
}

button {
  padding: 8px 12px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

button:hover {
  background: #0056b3;
}

.close-btn {
  width: 100%;
  background: #dc3545;
}

.close-btn:hover {
  background: #c82333;
}

.show-controls-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 1000;
  padding: 10px 20px;
}

.color-inputs {
  display: flex;
  gap: 8px;
  align-items: center;
}

.input-group {
  display: flex;
  align-items: center;
  gap: 4px;
}

.input-group input {
  width: 60px;
  padding: 4px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.control-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
}

.control-row input[type="range"] {
  flex: 1;
}

.panel-footer {
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid #ddd;
}
</style>

