<template>
  <div class="test-patterns" :style="{ width: '100vw', height: '100vh' }">
    <canvas ref="canvas" class="pattern-canvas"></canvas>
    
    <!-- 簡易控制（可選） -->
    <div v-if="showSimpleControls" class="simple-controls">
      <button @click="nextPattern">Next Pattern</button>
      <button @click="prevPattern">Previous Pattern</button>
      <span>{{ currentPatternName }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'

const props = defineProps({
  pattern: {
    type: String,
    default: 'white'
  },
  showSimpleControls: {
    type: Boolean,
    default: false
  }
})

const canvas = ref(null)
const ctx = ref(null)
const currentPattern = ref(props.pattern)
const animationId = ref(null)

const patterns = [
  'white', 'black', 'red', 'green', 'blue',
  'gray128', 'gray204', 'colorTable', 'grayWave',
  'horizontalLines', 'verticalLines', 'crossLines',
  'uniformityWhite', 'uniformityBlack',
  'lightStack', 'medStack', 'darkStack',
  'cube', 'circle', 'blink'
]

const currentPatternName = computed(() => currentPattern.value)

const nextPattern = () => {
  const currentIndex = patterns.indexOf(currentPattern.value)
  const nextIndex = (currentIndex + 1) % patterns.length
  currentPattern.value = patterns[nextIndex]
  renderPattern(currentPattern.value)
}

const prevPattern = () => {
  const currentIndex = patterns.indexOf(currentPattern.value)
  const prevIndex = (currentIndex - 1 + patterns.length) % patterns.length
  currentPattern.value = patterns[prevIndex]
  renderPattern(currentPattern.value)
}

const initCanvas = () => {
  if (!canvas.value) return
  
  canvas.value.width = window.innerWidth
  canvas.value.height = window.innerHeight
  ctx.value = canvas.value.getContext('2d')
}

const clearCanvas = () => {
  if (!ctx.value) return
  ctx.value.clearRect(0, 0, canvas.value.width, canvas.value.height)
}

const stopAnimation = () => {
  if (animationId.value) {
    cancelAnimationFrame(animationId.value)
    clearTimeout(animationId.value)
    animationId.value = null
  }
}

const renderPattern = (patternName) => {
  stopAnimation()
  clearCanvas()
  
  switch (patternName) {
    case 'white':
      drawSolidColor('#FFFFFF')
      break
    case 'black':
      drawSolidColor('#000000')
      break
    case 'red':
      drawSolidColor('#FF0000')
      break
    case 'green':
      drawSolidColor('#00FF00')
      break
    case 'blue':
      drawSolidColor('#0000FF')
      break
    case 'gray128':
      drawGrayLevel(128)
      break
    case 'gray204':
      drawGrayLevel(204)
      break
    case 'colorTable':
      drawColorTable()
      break
    case 'grayWave':
      animateGrayWave()
      break
    case 'horizontalLines':
      drawHorizontalLines()
      break
    case 'verticalLines':
      drawVerticalLines()
      break
    case 'crossLines':
      drawCrossLines()
      break
    case 'uniformityWhite':
      drawUniformity('#FFFFFF', '#000000')
      break
    case 'uniformityBlack':
      drawUniformity('#000000', '#FFFFFF')
      break
    case 'lightStack':
      drawLevelStack(207, 255, 3, '#000000')
      break
    case 'medStack':
      drawLevelStack(128, 192, 4, '#000000')
      break
    case 'darkStack':
      drawLevelStack(48, 0, -3, '#FFFFFF')
      break
    case 'cube':
      animateCube()
      break
    case 'circle':
      animateCircle()
      break
    case 'blink':
      animateBlink()
      break
  }
}

const drawSolidColor = (color) => {
  ctx.value.fillStyle = color
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
}

const drawGrayLevel = (level) => {
  const hex = level.toString(16).padStart(2, '0')
  ctx.value.fillStyle = `#${hex}${hex}${hex}`
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
}

const drawColorTable = () => {
  const w = canvas.value.width
  const h = canvas.value.height
  const barHeight = h / 32
  
  for (let i = 0; i < 256; i++) {
    const x = (i / 256) * (w / 2)
    const width = (w / 2) / 256
    
    ctx.value.fillStyle = `rgb(${i}, 0, 0)`
    ctx.value.fillRect(x, barHeight * 3, width, barHeight)
    
    ctx.value.fillStyle = `rgb(0, ${i}, 0)`
    ctx.value.fillRect(x, barHeight * 4, width, barHeight)
    
    ctx.value.fillStyle = `rgb(0, 0, ${i})`
    ctx.value.fillRect(x, barHeight * 5, width, barHeight)
    
    ctx.value.fillStyle = `rgb(${i}, ${i}, ${i})`
    ctx.value.fillRect(x * 2, barHeight * 7, width * 2, barHeight)
    
    ctx.value.fillStyle = `rgb(255, ${i}, ${i})`
    ctx.value.fillRect(w / 2 + x, barHeight * 3, width, barHeight)
    
    ctx.value.fillStyle = `rgb(${i}, 255, ${i})`
    ctx.value.fillRect(w / 2 + x, barHeight * 4, width, barHeight)
    
    ctx.value.fillStyle = `rgb(${i}, ${i}, 255)`
    ctx.value.fillRect(w / 2 + x, barHeight * 5, width, barHeight)
  }
}

const animateGrayWave = () => {
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
    }, 250)
  }
  
  animate()
}

const drawHorizontalLines = () => {
  const lineHeight = 15
  let isBlack = true
  
  for (let y = 0; y < canvas.value.height; y += lineHeight) {
    ctx.value.fillStyle = isBlack ? '#000000' : '#FFFFFF'
    ctx.value.fillRect(0, y, canvas.value.width, lineHeight)
    isBlack = !isBlack
  }
}

const drawVerticalLines = () => {
  const lineWidth = 15
  let isBlack = true
  
  for (let x = 0; x < canvas.value.width; x += lineWidth) {
    ctx.value.fillStyle = isBlack ? '#000000' : '#FFFFFF'
    ctx.value.fillRect(x, 0, lineWidth, canvas.value.height)
    isBlack = !isBlack
  }
}

const drawCrossLines = () => {
  ctx.value.fillStyle = '#808080'
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
  
  const w = canvas.value.width
  const h = canvas.value.height
  
  ctx.value.strokeStyle = '#000000'
  ctx.value.lineWidth = 2
  
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
}

const drawUniformity = (fg, bg) => {
  ctx.value.fillStyle = bg
  ctx.value.fillRect(0, 0, canvas.value.width, canvas.value.height)
  
  const w = canvas.value.width
  const h = canvas.value.height
  const boxW = w / 4
  const boxH = h / 4
  
  ctx.value.fillStyle = fg
  
  ctx.value.fillRect(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)
  ctx.value.fillRect(0, 0, boxW, boxH)
  ctx.value.fillRect(w - boxW, 0, boxW, boxH)
  ctx.value.fillRect(0, h - boxH, boxW, boxH)
  ctx.value.fillRect(w - boxW, h - boxH, boxW, boxH)
}

const drawLevelStack = (start, end, step, textColor) => {
  const w = canvas.value.width
  const h = canvas.value.height
  const borderW = w / 64
  const borderH = h / 64
  
  let x = 0, y = 0
  let width = w, height = h
  let level = 0
  
  ctx.value.font = '20px Arial'
  
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
    }, 250)
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
    }, 250)
  }
  
  animate()
}

onMounted(() => {
  initCanvas()
  renderPattern(currentPattern.value)
  
  window.addEventListener('resize', () => {
    initCanvas()
    renderPattern(currentPattern.value)
  })
  
  window.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight') nextPattern()
    else if (e.key === 'ArrowLeft') prevPattern()
  })
})

onUnmounted(() => {
  stopAnimation()
})

// 暴露方法供外部調用
defineExpose({
  renderPattern,
  nextPattern,
  prevPattern
})
</script>

<style scoped>
.test-patterns {
  position: relative;
  overflow: hidden;
  background: #000;
}

.pattern-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.simple-controls {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 10px;
  align-items: center;
  background: rgba(255, 255, 255, 0.9);
  padding: 10px 20px;
  border-radius: 8px;
  z-index: 1000;
}

.simple-controls button {
  padding: 8px 16px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.simple-controls button:hover {
  background: #0056b3;
}

.simple-controls span {
  font-weight: bold;
  color: #333;
}
</style>

