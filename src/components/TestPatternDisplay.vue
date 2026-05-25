<template>
  <!-- FrmV1 equivalent: fullscreen black window, no border -->
  <div
    class="frm-v1"
    @contextmenu.prevent="onRightClick"
    @click.left="onLeftClick"
  >
    <canvas ref="canvas" class="picture1"></canvas>

    <!-- Frame2: control panel, shown on right-click, hidden on left-click -->
    <div v-if="showPanel" class="frame2" @click.stop>
      <div class="frame2-caption">
        <span class="label1" @click="hideLabel1">{{ label1Text }}</span>
        &nbsp;&nbsp;{{ t.setColorOrAuto }}
      </div>

      <!-- Row 1: Color1 (R:G:B) / Gray -->
      <div class="row">
        <label class="opt-label">
          <input type="radio" v-model="colorMode" value="rgb"> {{ t.color1 }}
        </label>
        <span class="lbl">R:</span><input class="num3" v-model.number="rgb.r" min="0" max="255" type="number">
        <span class="lbl">G:</span><input class="num3" v-model.number="rgb.g" min="0" max="255" type="number">
        <span class="lbl">B:</span><input class="num3" v-model.number="rgb.b" min="0" max="255" type="number">
        <span class="lbl">{{ t.gray }}</span>
        <input class="num3" v-model.number="grayVal" min="0" max="255" type="number" @input="syncGrayToRgb">
        <button class="btn-sm" @click="decGray">_</button>
        <button class="btn-sm" @click="incGray">+</button>
        <span class="lbl">{{ t.pushLevel }}</span>
        <input class="num2" v-model.number="pushLevel" min="1" max="255" type="number">
      </div>

      <!-- Row 2: Auto Color Show -->
      <div class="row">
        <label class="opt-label">
          <input type="radio" v-model="colorMode" value="auto"> {{ t.autoColorShow }}
        </label>
        <select class="combo-sm" v-model="autoChannel">
          <option>Gray</option><option>Red</option><option>Green</option><option>Blue</option>
        </select>
        <span class="lbl">{{ t.pushLevel }}</span>
        <input class="num2" v-model.number="autoStep" min="1" max="255" type="number">
        <span class="lbl">{{ t.timer100ms }}</span>
        <input class="num2" v-model.number="autoTimerMult" min="1" max="99" type="number">
      </div>

      <!-- Row 3: Show Setting / hints / Close -->
      <div class="row row-hint">
        <button class="btn-wide" @click="showSetting">{{ t.showSetting }}</button>
        <div class="hints">
          <div class="hint-txt">{{ t.hintGray }}</div>
          <div class="hint-txt">{{ t.hintKeyboard }}</div>
        </div>
        <button class="btn-close" @click="handleClose">{{ t.close }}</button>
      </div>

      <hr class="sep">

      <!-- Row 4: Quick Back -->
      <div class="row">
        <span class="lbl">{{ t.quickBack }}</span>
        <label class="chk-label">
          <input type="checkbox" v-model="withGridLines"> {{ t.withGridLines }}
        </label>
        <button class="btn" @click="quickBack(255,255,255)">{{ t.whiteBack }}</button>
        <button class="btn" @click="quickBack(0,0,0)">{{ t.blackBack }}</button>
        <button class="btn" @click="quickBack(255,0,0)">{{ t.redBack }}</button>
        <button class="btn" @click="quickBack(0,255,0)">{{ t.greenBack }}</button>
        <button class="btn" @click="quickBack(0,0,255)">{{ t.blueBack }}</button>
      </div>

      <hr class="sep">

      <!-- Row 5: Color Table -->
      <div class="row">
        <button class="btn-wide2" @click="doColorTable">{{ t.colorTable }}</button>
        <span class="lbl">{{ t.level }}</span>
        <select class="combo-sm" v-model.number="ctLevel">
          <option :value="256">256</option><option :value="128">128</option>
          <option :value="64">64</option><option :value="32">32</option>
          <option :value="16">16</option>
        </select>
        <span class="lbl">{{ t.from }}</span>
        <select class="combo-sm" v-model="ctFrom">
          <option>Black</option><option>White</option>
        </select>
        <span class="lbl">{{ t.toRgb }}</span>
        <select class="combo-sm" v-model.number="ctR">
          <option :value="255">255</option><option :value="0">0</option>
        </select>
        <select class="combo-sm" v-model.number="ctG">
          <option :value="255">255</option><option :value="0">0</option>
        </select>
        <select class="combo-sm" v-model.number="ctB">
          <option :value="255">255</option><option :value="0">0</option>
        </select>
      </div>

      <hr class="sep">

      <!-- Row 6-8: Line tests -->
      <div class="row">
        <button class="btn-wide2" @click="doHorizontalLine">{{ t.horizontalLine }}</button>
        <button class="btn-wide2" @click="doVerticalLine">{{ t.verticalLine }}</button>
        <div style="flex:1"></div>
        <button class="btn" @click="doColorWall">{{ t.colorWall }}</button>
      </div>
      <div class="row row-small">
        <span class="lbl">{{ t.line1Color }}</span>
        <select class="combo-sm" v-model="line1Color">
          <option>Black</option><option>White</option><option>Red</option><option>Green</option><option>Blue</option>
        </select>
        <span class="lbl">{{ t.pixelWidth }}</span>
        <select class="combo-sm" v-model.number="lineW1">
          <option :value="1">1x</option><option :value="2">2x</option>
          <option :value="3">3x</option><option :value="4">4x</option>
        </select>
      </div>
      <div class="row row-small">
        <button class="btn-wide2" @click="doCrossLine">{{ t.crossLine }}</button>
        <span class="lbl">{{ t.crossBack }}</span>
        <select class="combo-sm" v-model="crossBack">
          <option>Black</option><option>White</option><option>Red</option><option>Green</option><option>Blue</option><option>Gray</option>
        </select>
        <span class="lbl">{{ t.line2Color }}</span>
        <select class="combo-sm" v-model="line2Color">
          <option>Black</option><option>White</option><option>Red</option><option>Green</option><option>Blue</option>
        </select>
        <span class="lbl">{{ t.pixelWidth }}</span>
        <select class="combo-sm" v-model.number="lineW2">
          <option :value="1">1x</option><option :value="2">2x</option>
          <option :value="3">3x</option><option :value="4">4x</option>
        </select>
      </div>

      <hr class="sep">

      <!-- Row 9: Contrast View + Stacks -->
      <div class="row">
        <span class="lbl">{{ t.contrastView }}</span>
        <button class="btn-sm2" @click="doCubeGrid">{{ t.cube }}</button>
        <span class="lbl">X:</span><input class="num2" v-model.number="cubeX" min="1" max="20" type="number">
        <span class="lbl">Y:</span><input class="num2" v-model.number="cubeY" min="1" max="20" type="number">
        <button class="btn" @click="doLightStack">{{ t.lightStack }}</button>
        <button class="btn" @click="doMedStack">{{ t.medStack }}</button>
        <button class="btn" @click="doLowStack">{{ t.lowStack }}</button>
        <button class="btn" @click="doDarkStack">{{ t.darkStack }}</button>
      </div>

      <hr class="sep">

      <!-- Row 10: Uniformity -->
      <div class="row">
        <span class="lbl">{{ t.uniformity }}</span>
        <button class="btn" @click="doUniformity(0,0,0, 255,255,255)">{{ t.black }}</button>
        <button class="btn" @click="doUniformity(255,255,255, 0,0,0)">{{ t.white }}</button>
        <button class="btn" @click="doUniformity(128,128,128, 0,0,0)">{{ t.gray128 }}</button>
        <button class="btn" @click="doUniformity(204,204,204, 0,0,0)">{{ t.gray204 }}</button>
        <button class="btn" @click="doUniformity(255,0,0, 0,0,0)">{{ t.red }}</button>
        <button class="btn" @click="doUniformity(0,255,0, 0,0,0)">{{ t.green }}</button>
        <button class="btn" @click="doUniformity(0,0,255, 0,0,0)">{{ t.blue }}</button>
      </div>

      <hr class="sep">

      <!-- Row 11: Dynamic -->
      <div class="row">
        <span class="lbl">{{ t.dynamic }}</span>
        <select class="combo-sm" v-model.number="timerInterval">
          <option :value="100">100ms</option><option :value="250">250ms</option>
          <option :value="500">500ms</option><option :value="1000">1000ms</option>
        </select>
        <button class="btn" @click="doGrayWave">{{ t.grayWave }}</button>
        <button class="btn" @click="doInterval">{{ t.interval }}</button>
        <button class="btn-sm2" @click="doAnimCube">{{ t.cube }}</button>
        <button class="btn-sm2" @click="doAnimCircle">{{ t.circle }}</button>
        <button class="btn" @click="doFullBack">{{ t.fullBack }}</button>
        <button class="btn-sm2" @click="do3Bar">{{ t.threeBar }}</button>
      </div>

      <hr class="sep">

      <!-- Row 12: Text View -->
      <div class="row">
        <span class="lbl">{{ t.textView }}</span>
        <span class="lbl">{{ t.grayLevel }}</span>
        <span class="lbl">{{ t.back }}</span>
        <input class="num3" v-model.number="textBK" min="0" max="255" type="number">
        <span class="lbl">{{ t.font }}</span>
        <input class="num3" v-model.number="textFont" min="0" max="255" type="number">
        <button class="btn" @click="doText1">Text1</button>
        <button class="btn" @click="doText2">Text2</button>
        <button class="btn" @click="doText3">Text3</button>
      </div>
    </div><!-- end frame2 -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useI18n } from '../composables/useI18n.js'

let tauriInvoke = null
const initTauri = async () => {
  try {
    if (typeof window !== 'undefined' && window.__TAURI_INTERNALS__) {
      const m = await import('@tauri-apps/api/core')
      tauriInvoke = m.invoke
    }
  } catch {}
}
const invoke = async (cmd, args) => {
  if (!tauriInvoke && typeof window !== 'undefined' && window.__TAURI_INTERNALS__) await initTauri()
  if (tauriInvoke) return tauriInvoke(cmd, args)
  return null
}

const props = defineProps({
  monitor: { type: Object, required: true },
  lang: { type: String, default: 'en' }
})
const emit = defineEmits(['close'])
const t = useI18n(computed(() => props.lang))

// ── refs ──────────────────────────────────────────────────────────────────
const canvas = ref(null)
let ctx = null
const showPanel = ref(true)
const label1Text = ref('')
const label1Visible = ref(false)

// Color / gray settings
const colorMode = ref('rgb')  // 'rgb' | 'auto'
const rgb = ref({ r: 0, g: 0, b: 0 })
const grayVal = ref(0)
const pushLevel = ref(1)
const autoChannel = ref('Gray')
const autoStep = ref(1)
const autoTimerMult = ref(10)

// Line settings
const withGridLines = ref(false)
const line1Color = ref('Black')
const line2Color = ref('White')
const lineW1 = ref(1)
const lineW2 = ref(1)
const crossBack = ref('Black')

// Color table settings
const ctLevel = ref(256)
const ctFrom = ref('Black')
const ctR = ref(255)
const ctG = ref(255)
const ctB = ref(255)

// Cube grid
const cubeX = ref(4)
const cubeY = ref(4)

// Text settings
const textBK = ref(0)
const textFont = ref(255)

// Animation timer
const timerInterval = ref(250)
let animHandle = null
let timeAdd = 0

// ── helpers ───────────────────────────────────────────────────────────────
const W = () => canvas.value.width
const H = () => canvas.value.height

const wordColor = (name) => {
  switch (name) {
    case 'White': return [255,255,255]
    case 'Black': return [0,0,0]
    case 'Red':   return [255,0,0]
    case 'Green': return [0,255,0]
    case 'Blue':  return [0,0,255]
    case 'Gray':  return [128,128,128]
    default:      return [0,0,0]
  }
}

const fillRect = (x, y, w, h, r, g, b) => {
  ctx.fillStyle = `rgb(${r},${g},${b})`
  ctx.fillRect(x, y, w, h)
}

const fillScreen = (r, g, b) => fillRect(0, 0, W(), H(), r, g, b)

const stopAnim = () => {
  if (animHandle !== null) { clearTimeout(animHandle); animHandle = null }
}

// Draw the 4-line grid (9-point cross) matching Line9a in VB2005
const drawLine9a = (r, g, b) => {
  ctx.strokeStyle = `rgb(${r},${g},${b})`
  ctx.lineWidth = 1
  ctx.beginPath()
  ctx.moveTo(0, H() / 3);       ctx.lineTo(W(), H() / 3)
  ctx.moveTo(0, 2 * H() / 3);   ctx.lineTo(W(), 2 * H() / 3)
  ctx.moveTo(W() / 3, 0);       ctx.lineTo(W() / 3, H())
  ctx.moveTo(2 * W() / 3, 0);   ctx.lineTo(2 * W() / 3, H())
  ctx.stroke()
}

// GTable: matches VB2005 GTable function exactly
// tCR,tCG,tCB: target color 0-255; CLevel: step count; CRtoL: invert
const drawGTable = (tCR, tCG, tCB, CLevel, CRtoL) => {
  if (CLevel <= 1) return
  const w = W(), h = H()
  let McWR = (w / CLevel) * (256 - tCR)
  let McWG = (w / CLevel) * (256 - tCG)
  let McWB = (w / CLevel) * (256 - tCB)
  const McWRP = McWR, McWGP = McWG, McWBP = McWB
  let rr = 0, gg = 0, bb = 0
  const step = Math.floor(255 / (CLevel - 1))

  for (let x = 0; x <= w; x++) {
    if (x - McWR > 0) { McWR += McWRP; rr = Math.min(255, rr + step) }
    if (x - McWG > 0) { McWG += McWGP; gg = Math.min(255, gg + step) }
    if (x - McWB > 0) { McWB += McWBP; bb = Math.min(255, bb + step) }
    ctx.fillStyle = CRtoL
      ? `rgb(${255-rr},${255-gg},${255-bb})`
      : `rgb(${rr},${gg},${bb})`
    ctx.fillRect(x, 0, 1, h)
  }
}

// LevelStack: matches VB2005 LevelStack function
const drawLevelStack = (SColor, EColor, CStep, wordColorA) => {
  const w = W(), h = H()
  const BWidth = Math.floor(w / 64)
  const BHeight = Math.floor(h / 64)
  let MaW = 0, MaH = 0, MbW = w, MbH = h
  let Vx1 = 0
  const [wcR, wcG, wcB] = wordColor(wordColorA)

  ctx.font = `${Math.max(10, Math.floor(h / 40))}px "MS Sans Serif", sans-serif`

  const loop = CStep > 0
    ? (i) => i <= EColor
    : (i) => i >= EColor

  for (let i = SColor; loop(i); i += CStep) {
    fillRect(MaW, MaH, MbW - MaW, MbH - MaH, i, i, i)
    ctx.fillStyle = `rgb(${wcR},${wcG},${wcB})`
    ctx.fillText(String(Vx1), MaW + 2, MaH + BHeight + 12)
    MaW += BWidth; MbW -= BWidth
    MaH += BHeight; MbH -= BHeight
    Vx1++
  }
  // Draw final level count text in center
  const finalI = EColor
  const finalGray = finalI < 0 ? 0 : finalI > 255 ? 255 : finalI
  ctx.fillStyle = `rgb(${wcR},${wcG},${wcB})`
  ctx.font = `${Math.max(12, Math.floor(h / 36))}px "MS Sans Serif", sans-serif`
  const cx = Math.floor(w / 2.7)
  const tl = t.value
  const suffix = tl.stackSuffix ? ' ' + tl.stackSuffix : ''
  ctx.fillText(`${tl.stackFrom} ${SColor} ${tl.stackTo} ${EColor} ${tl.stackStep} ${CStep}${suffix}`, cx, Math.floor(h / 2.5))
  ctx.fillText(`${tl.stackCheck} ${Vx1} ${tl.stackLevels}`, cx, Math.floor(h / 2.3))
}

// Uniformity: matches VB2005 Uniformity function
const drawUniformity = (ccUniR, ccUniG, ccUniB, ccBkR, ccBkG, ccBkB) => {
  const w = W(), h = H()
  fillScreen(ccBkR, ccBkG, ccBkB)
  const MaW = Math.floor(w / 4)
  const MaH = Math.floor(h / 4)
  const HalfX = Math.floor(w / 2)
  const HalfY = Math.floor(h / 2)
  const McX = HalfX - Math.floor(MaW / 2)
  const McY = HalfY - Math.floor(MaH / 2)
  fillRect(McX, McY, MaW, MaH, ccUniR, ccUniG, ccUniB)
  fillRect(0, 0, MaW, MaH, ccUniR, ccUniG, ccUniB)
  fillRect(0, h - MaH, MaW, MaH, ccUniR, ccUniG, ccUniB)
  fillRect(w - MaW, 0, MaW, MaH, ccUniR, ccUniG, ccUniB)
  fillRect(w - MaW, h - MaH, MaW, MaH, ccUniR, ccUniG, ccUniB)
}

// ── pattern handlers ──────────────────────────────────────────────────────

const hidePanel = () => { showPanel.value = false }

const syncGrayToRgb = () => {
  const v = Math.max(0, Math.min(255, grayVal.value))
  rgb.value.r = v; rgb.value.g = v; rgb.value.b = v
}

const incGray = () => {
  grayVal.value = Math.min(255, grayVal.value + pushLevel.value)
  syncGrayToRgb()
}
const decGray = () => {
  grayVal.value = Math.max(0, grayVal.value - pushLevel.value)
  syncGrayToRgb()
}

const hideLabel1 = () => { label1Visible.value = false; label1Text.value = '' }

const showSetting = () => {
  stopAnim()
  if (colorMode.value === 'rgb') {
    const { r, g, b } = rgb.value
    fillScreen(r, g, b)
  } else {
    // Auto Color Show: cycle from 0 to 255
    let i = 0
    const step = autoStep.value
    const delay = autoTimerMult.value * 99
    const run = () => {
      let r = 0, g = 0, b = 0
      if (autoChannel.value === 'Gray') { r = i; g = i; b = i }
      else if (autoChannel.value === 'Red') r = i
      else if (autoChannel.value === 'Green') g = i
      else if (autoChannel.value === 'Blue') b = i
      fillScreen(r, g, b)
      if (i < 255) {
        i = Math.min(255, i + step)
        animHandle = setTimeout(run, delay)
      }
    }
    run()
  }
  hidePanel()
}

const quickBack = (r, g, b) => {
  stopAnim()
  fillScreen(r, g, b)
  if (withGridLines.value) {
    drawLine9a(255 - r, 255 - g, 255 - b)
  }
  hidePanel()
}

// Color Table (Command9): GTable gradient with user-specified level/from/toRGB
const doColorTable = () => {
  stopAnim()
  const BW = ctFrom.value === 'White'
  if (!BW) {
    drawGTable(ctR.value, ctG.value, ctB.value, ctLevel.value, false)
  } else {
    drawGTable(255 - ctR.value, 255 - ctG.value, 255 - ctB.value, ctLevel.value, true)
  }
  hidePanel()
}

// Color Wall (Command14): complex rainbow pattern, black background
const drawColorWallPattern = () => {
  const w = W(), h = H()
  fillScreen(0, 0, 0)   // VB2005: Picture1.BackColor = vbBlack
  const C1W = (w / 2) / 256
  const C1H = h / 32
  const C1RH = 3 * C1H, C1GH = 4 * C1H, C1BH = 5 * C1H
  const C1WH = 6 * C1H
  const HalfX = w / 2

  for (let i = 0; i < 256; i++) {
    const x0 = i * C1W
    fillRect(x0,          C1RH, C1W + 1, C1H, i, 0, 0)
    fillRect(x0,          C1GH, C1W + 1, C1H, 0, i, 0)
    fillRect(x0,          C1BH, C1W + 1, C1H, 0, 0, i)
    fillRect(i*C1W*2,     C1WH + C1H, C1W*2 + 1, C1H, i, i, i)
    fillRect(HalfX + x0,  C1RH, C1W + 1, C1H, 255, i, i)
    fillRect(HalfX + x0,  C1GH, C1W + 1, C1H, i, 255, i)
    fillRect(HalfX + x0,  C1BH, C1W + 1, C1H, i, i, 255)
  }

  const HalfY = h / 2
  const colorV = [
    [255,0,255],[255,0,127],[255,0,0],[255,127,0],
    [255,255,0],[0,255,0],[0,255,255],[0,0,255]
  ]
  const MaW = Math.floor(w / 16), MaH = Math.floor(h / 6)
  const BWidth = Math.floor(w / 64), BHeight = Math.floor(h / 64)
  const TmpXs = HalfX - 4 * MaW - 4 * BWidth
  for (let i = 0; i < 8; i++) {
    const x = TmpXs + i * (MaW + BWidth)
    const [cr, cg, cb] = colorV[i]
    fillRect(x, HalfY - MaH - BHeight, MaW, MaH, cr, cg, cb)
  }

  const D1Y = HalfY + 6 * BHeight + MaH
  const D1H = Math.floor((h - D1Y) / 3)
  const D1W = Math.floor(w / 16)
  for (let i = 0; i < 16; i++) {
    fillRect(i * D1W, D1Y,          D1W, D1H, i * 17, 0, 0)
    fillRect(i * D1W, D1Y + D1H,    D1W, D1H, 0, i * 17, 0)
    fillRect(i * D1W, D1Y + 2*D1H,  D1W, D1H, 0, 0, i * 17)
  }

  const crT = buildColorWheel()
  let Mtmp2 = TmpXs
  for (let j = 0; j <= 18; j++) {
    const [cr, cg, cb] = crT[j]
    fillRect(Mtmp2, HalfY + BHeight, BWidth, BHeight + MaH, cr, cg, cb)
    Mtmp2 += BWidth * 2
  }
}

const buildColorWheel = () => {
  const crT = Array(19).fill(null).map(() => [0,0,0])
  crT[0] = [0,0,0]
  for (let k = 1; k <= 6; k++) {
    const Vx1 = Math.round((2 - (k % 2)) * 127.5)
    const Vx2 = Math.round(Math.floor((k - 1) / 2) * 127.5)
    crT[k] = [Vx1, Vx2, 0]
    crT[k + 6] = [0, Vx1, Vx2]
    crT[k + 12] = [Vx2, 0, Vx1]
  }
  // Reorder like VB2005 crT1 logic
  const crT1 = Array(19).fill(null).map(() => [0,0,0])
  for (let k = 1; k <= 3; k++) {
    crT1[k*6-5] = crT[k*6-4]; crT1[k*6-4] = crT[k*6-5]
    crT1[k*6-3] = crT[k*6-2]; crT1[k*6-2] = crT[k*6]
    crT1[k*6-1] = crT[k*6-3]; crT1[k*6] = crT[k*6-1]
  }
  for (let k = 1; k <= 15; k++) crT[k + 3] = crT1[k]
  for (let k = 1; k <= 3; k++) crT[k] = crT1[k + 15]
  return crT
}

const doHorizontalLine = () => {
  stopAnim()
  const w = W(), h = H()
  const LP1 = lineW1.value, LP2 = lineW2.value
  const [s1r,s1g,s1b] = wordColor(line1Color.value)
  const [s2r,s2g,s2b] = wordColor(line2Color.value)
  let MTmp = 1, Mtmp2 = 5252
  const rows = Math.floor(h / 15)
  for (let i = 0; i <= rows; i++) {
    if (MTmp <= LP1 && Mtmp2 === 5252) {
      fillRect(0, i * 15, w, 15, s1r, s1g, s1b)
      MTmp++
      if (MTmp > LP1) { MTmp = 5252; Mtmp2 = 1 }
    } else if (Mtmp2 <= LP2 && MTmp === 5252) {
      fillRect(0, i * 15, w, 15, s2r, s2g, s2b)
      Mtmp2++
      if (Mtmp2 > LP2) { MTmp = 1; Mtmp2 = 5252 }
    }
  }
  hidePanel()
}

const doVerticalLine = () => {
  stopAnim()
  const w = W(), h = H()
  const LP1 = lineW1.value, LP2 = lineW2.value
  const [s1r,s1g,s1b] = wordColor(line1Color.value)
  const [s2r,s2g,s2b] = wordColor(line2Color.value)
  let MTmp = 1, Mtmp2 = 5252
  const cols = Math.floor(w / 15)
  for (let i = 0; i <= cols; i++) {
    if (MTmp <= LP1 && Mtmp2 === 5252) {
      fillRect(i * 15, 0, 15, h, s1r, s1g, s1b)
      MTmp++
      if (MTmp > LP1) { MTmp = 5252; Mtmp2 = 1 }
    } else if (Mtmp2 <= LP2 && MTmp === 5252) {
      fillRect(i * 15, 0, 15, h, s2r, s2g, s2b)
      Mtmp2++
      if (Mtmp2 > LP2) { MTmp = 1; Mtmp2 = 5252 }
    }
  }
  hidePanel()
}

const doCrossLine = () => {
  stopAnim()
  const w = W(), h = H()
  const LP1 = lineW1.value, LP2 = lineW2.value
  const [bgR,bgG,bgB] = wordColor(crossBack.value)
  const [s1r,s1g,s1b] = wordColor(line1Color.value)
  const [s2r,s2g,s2b] = wordColor(line2Color.value)
  fillScreen(bgR, bgG, bgB)
  // Horizontal lines every (LP1+1)*15 pixels — 1 pixel line
  ctx.strokeStyle = `rgb(${s1r},${s1g},${s1b})`
  ctx.lineWidth = 1
  for (let i = 0; i <= Math.floor(h / 15); i++) {
    if (i % (LP1 + 1) === 0) {
      ctx.beginPath(); ctx.moveTo(0, i * 15); ctx.lineTo(w, i * 15); ctx.stroke()
    }
  }
  // Vertical lines every (LP2+1)*15 pixels
  ctx.strokeStyle = `rgb(${s2r},${s2g},${s2b})`
  for (let i = 0; i <= Math.floor(w / 15); i++) {
    if (i % (LP2 + 1) === 0) {
      ctx.beginPath(); ctx.moveTo(i * 15, 0); ctx.lineTo(i * 15, h); ctx.stroke()
    }
  }
  hidePanel()
}

const doColorWall = () => {
  stopAnim()
  drawColorWallPattern()
  hidePanel()
}

const doCubeGrid = () => {
  stopAnim()
  const w = W(), h = H()
  const WX = cubeX.value, WY = cubeY.value
  const M4W = Math.floor(w / WX), M4H = Math.floor(h / WY)
  for (let i = 1; i <= WX; i++) {
    for (let j = 1; j <= WY; j++) {
      const color = (i + j) % 2 === 0 ? [0,0,0] : [255,255,255]
      fillRect((i-1)*M4W, (j-1)*M4H, M4W, M4H, ...color)
    }
  }
  hidePanel()
}

const doLightStack = () => { stopAnim(); drawLevelStack(207, 255, 3, 'Black'); hidePanel() }
const doMedStack   = () => { stopAnim(); drawLevelStack(110, 172, 2, 'White'); hidePanel() }
const doLowStack   = () => { stopAnim(); drawLevelStack(72, 0, -6, 'White');   hidePanel() }
const doDarkStack  = () => { stopAnim(); drawLevelStack(48, 0, -3, 'White');   hidePanel() }

const doUniformity = (ur, ug, ub, br, bg, bb) => {
  stopAnim(); drawUniformity(ur,ug,ub,br,bg,bb); hidePanel()
}

// Gray Wave animation (Timer1, TimeSel=1)
const doGrayWave = () => {
  stopAnim(); timeAdd = 0; hidePanel()
  const interval = timerInterval.value
  const tick = () => {
    timeAdd++
    if (timeAdd < 8) {
      drawGTable(255, 255, 255, Math.pow(2, timeAdd), false)
    } else {
      drawGTable(255, 255, 255, Math.pow(2, 16 - timeAdd), false)
    }
    if (timeAdd >= 15) timeAdd = 0
    animHandle = setTimeout(tick, interval)
  }
  animHandle = setTimeout(tick, interval)
}

// Interval animation (Timer1, TimeSel=2) - inverts at second half
const doInterval = () => {
  stopAnim(); timeAdd = 0; hidePanel()
  const interval = timerInterval.value
  const tick = () => {
    timeAdd++
    if (timeAdd < 8) {
      drawGTable(255, 255, 255, Math.pow(2, timeAdd), false)
    } else {
      drawGTable(255, 255, 255, Math.pow(2, 16 - timeAdd), true)
    }
    if (timeAdd >= 15) timeAdd = 0
    animHandle = setTimeout(tick, interval)
  }
  animHandle = setTimeout(tick, interval)
}

// Cube animation (Timer2): black rectangle circles around white screen border
const doAnimCube = () => {
  stopAnim(); timeAdd = 0; hidePanel()
  const interval = timerInterval.value
  const tick = () => {
    timeAdd++
    const w = W(), h = H()
    const MaW = Math.floor(w / 5), MaH = Math.floor(h / 5)
    fillScreen(255, 255, 255)
    const t = timeAdd
    if (t >= 1 && t <= 5) {
      fillRect((t-1)*MaW, 0, MaW, MaH, 0, 0, 0)
    } else if (t >= 6 && t <= 9) {
      fillRect(w-MaW, (t-5)*MaH, MaW, MaH, 0, 0, 0)
    } else if (t >= 10 && t <= 13) {
      fillRect((13-t)*MaW, h-MaH, MaW, MaH, 0, 0, 0)
    } else if (t >= 14 && t <= 16) {
      fillRect(0, (17-t)*MaH, MaW, MaH, 0, 0, 0)
    }
    if (timeAdd >= 16) timeAdd = 0
    animHandle = setTimeout(tick, interval)
  }
  animHandle = setTimeout(tick, interval)
}

// Circle animation (Timer3): shrinking circle
const doAnimCircle = () => {
  stopAnim(); timeAdd = 0; hidePanel()
  const interval = Math.min(500, timerInterval.value)
  const MCut = Math.floor(1000 / interval)
  const tick = () => {
    timeAdd++
    const w = W(), h = H()
    const HfW = w / 2, HfH = h / 2
    const MaH = (HfH - h / 24) / MCut
    fillScreen(255, 255, 255)
    const radius = HfH - timeAdd * MaH
    if (radius > 0) {
      ctx.strokeStyle = 'rgb(0,0,0)'
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.arc(HfW, HfH, radius, 0, Math.PI * 2)
      ctx.stroke()
    }
    if (timeAdd >= MCut) {
      timeAdd = 0
      // Pause 5 seconds then restart
      animHandle = setTimeout(tick, 5000)
      return
    }
    animHandle = setTimeout(tick, interval)
  }
  animHandle = setTimeout(tick, interval)
}

// Full Back: black/white flash (Timer4 Case 1)
const doFullBack = () => {
  stopAnim(); timeAdd = 0; hidePanel()
  const interval = timerInterval.value
  let isBlack = true
  const tick = () => {
    fillScreen(isBlack ? 0 : 255, isBlack ? 0 : 255, isBlack ? 0 : 255)
    isBlack = !isBlack
    animHandle = setTimeout(tick, interval)
  }
  animHandle = setTimeout(tick, interval)
}

// 3-Bar: alternating black/white with center horizontal bar (Timer4 Case 2)
const do3Bar = () => {
  stopAnim(); timeAdd = 0; hidePanel()
  const interval = timerInterval.value
  let phase = 1
  const tick = () => {
    const w = W(), h = H()
    const TfH = Math.floor(h / 3)
    if (phase === 1) {
      fillScreen(0, 0, 0)
      fillRect(0, TfH, w, TfH, 255, 255, 255)
    } else {
      fillScreen(255, 255, 255)
      fillRect(0, TfH, w, TfH, 0, 0, 0)
    }
    phase = phase === 1 ? 2 : 1
    animHandle = setTimeout(tick, interval)
  }
  animHandle = setTimeout(tick, interval)
}

// Text1: fills screen with repeating text, 8pt
const doText1 = () => {
  stopAnim()
  const w = W(), h = H()
  const CBK = textBK.value, CC = textFont.value
  fillScreen(CBK, CBK, CBK)
  ctx.fillStyle = `rgb(${CC},${CC},${CC})`
  ctx.font = '11px "MS Sans Serif", monospace'
  const charW = 6.5, lineH = 14
  const charsPerLine = Math.ceil(w / charW)
  const lines = Math.ceil(h / lineH)
  const srcText = t.value.text1Src
  let line = ''
  while (line.length < charsPerLine + srcText.length) line += srcText
  for (let i = 0; i < lines; i++) {
    ctx.fillText(line, 0, (i + 1) * lineH)
  }
  hidePanel()
}

// Text2: varying font sizes
const doText2 = () => {
  stopAnim()
  const w = W(), h = H()
  const CBK = textBK.value, CC = textFont.value
  fillScreen(CBK, CBK, CBK)
  ctx.fillStyle = `rgb(${CC},${CC},${CC})`
  const srcText = t.value.text2Src
  const charsPerLine = Math.ceil(w / 7)
  let line = ''
  while (line.length < charsPerLine + srcText.length) line += srcText
  let y = 0, rowIdx = 0
  while (y < h) {
    const sz = (rowIdx % 9) + 6 - 0.25 * (rowIdx % 9)
    ctx.font = `${sz}px "MS Serif", serif`
    const lh = Math.ceil(sz * 1.4)
    ctx.fillText(`Size:${sz.toFixed(2)}  ` + line, 0, y + lh)
    y += lh
    if (rowIdx % 9 === 8) { ctx.font = '3px sans-serif'; ctx.fillText(' ', 0, y + 4); y += 4 }
    rowIdx++
  }
  hidePanel()
}

// Text3: multi-paragraph colored text
const doText3 = () => {
  stopAnim()
  const w = W(), h = H()
  const CBK = textBK.value, CC = textFont.value
  fillScreen(CBK, CBK, CBK)
  const scrText = t.value.text3Lines
  const tmpCw = [
    [0,0,0], [CC,0,0], [CC,CC,0], [0,CC,0],
    [0,CC,CC], [0,0,CC], [CC,0,CC], [CC,CC,CC]
  ]
  const lineH = 16
  const charsPerLine = Math.ceil(w / 8)
  // Build repeated lines
  const lines = []
  for (let s = 0; s < 5; s++) {
    let t = ''; while (t.length < charsPerLine + scrText[s].length) t += scrText[s]
    lines.push(t)
  }
  ctx.font = '13px "MS Sans Serif", monospace'
  let y = lineH, row = 0
  while (y < h) {
    const si = row % 5
    const ci = row % 8
    const [cr,cg,cb] = tmpCw[ci]
    ctx.fillStyle = `rgb(${cr},${cg},${cb})`
    // Rotate line string by 30 chars per row
    const rotated = lines[si].substring(row * 30 % scrText[si].length) + lines[si]
    ctx.fillText(rotated, 0, y)
    y += lineH
    row++
  }
  hidePanel()
}

const handleClose = async () => {
  stopAnim()
  try {
    await invoke('close_window')
  } catch {
    emit('close')
  }
}

// ── mouse/keyboard ────────────────────────────────────────────────────────
const onRightClick = () => {
  stopAnim()
  showPanel.value = true
  label1Visible.value = true
  label1Text.value = String(label1Text.value || '0')
}

const onLeftClick = () => {
  if (!showPanel.value) return
  showPanel.value = false
}

const handleKey = (e) => {
  if (e.key === 'Escape') { handleClose(); return }
  if (showPanel.value) return
  if (e.key === '+' || e.key === '=') { incGray(); showSetting() }
  if (e.key === '-') { decGray(); showSetting() }
}

// ── canvas init ───────────────────────────────────────────────────────────
const initCanvas = () => {
  if (!canvas.value) return
  canvas.value.width = window.innerWidth
  canvas.value.height = window.innerHeight
  ctx = canvas.value.getContext('2d')
  fillScreen(128, 128, 128)  // VB default: gray BackColor
}

onMounted(() => {
  initCanvas()
  window.addEventListener('resize', initCanvas)
  window.addEventListener('keydown', handleKey)
})

onUnmounted(() => {
  stopAnim()
  window.removeEventListener('resize', initCanvas)
  window.removeEventListener('keydown', handleKey)
})
</script>

<style scoped>
/* FrmV1: black, no border, fullscreen */
.frm-v1 {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  background: #000;
  cursor: default;
  user-select: none;
}

.picture1 {
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
}

/* Frame2: VB6-style control panel, appears on top-left */
.frame2 {
  position: absolute;
  top: 24px;
  left: 24px;
  width: 580px;
  background: #d4d0c8;
  border: 2px solid;
  border-color: #fff #808080 #808080 #fff;
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 11px;
  color: #000;
  padding: 4px 6px 6px 6px;
  z-index: 1000;
  box-shadow: 2px 2px 6px rgba(0,0,0,0.5);
}

.frame2-caption {
  font-size: 11px;
  margin-bottom: 4px;
  color: #000;
  display: flex;
  align-items: center;
  gap: 4px;
}

.label1 {
  display: inline-block;
  background: #e0e0e0;
  border: 1px solid #808080;
  padding: 0 4px;
  font-size: 13px;
  cursor: pointer;
  min-width: 20px;
}

.row {
  display: flex;
  align-items: center;
  gap: 3px;
  flex-wrap: nowrap;
  margin-bottom: 3px;
}
.row-small { margin-bottom: 2px; }
.row-hint { align-items: flex-start; gap: 4px; }

.sep {
  border: none;
  border-top: 1px solid #808080;
  margin: 3px 0;
}

.lbl {
  white-space: nowrap;
  font-size: 11px;
}

.opt-label {
  display: flex;
  align-items: center;
  gap: 2px;
  white-space: nowrap;
  font-size: 11px;
  cursor: pointer;
}
.opt-label input[type="radio"] { margin: 0 2px 0 0; }

.chk-label {
  display: flex;
  align-items: center;
  gap: 2px;
  white-space: nowrap;
  font-size: 11px;
  cursor: pointer;
}

/* Classic VB6 buttons */
.btn, .btn-sm, .btn-sm2, .btn-wide, .btn-wide2, .btn-close {
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 11px;
  background: #d4d0c8;
  border: 2px solid;
  border-color: #fff #808080 #808080 #fff;
  cursor: pointer;
  padding: 1px 4px;
  height: 22px;
  white-space: nowrap;
  color: #000;
}
.btn          { min-width: 58px; }
.btn-sm       { min-width: 20px; padding: 1px 3px; }
.btn-sm2      { min-width: 40px; }
.btn-wide     { min-width: 140px; }
.btn-wide2    { min-width: 90px; }
.btn-close    { min-width: 58px; }

.btn:active, .btn-sm:active, .btn-sm2:active,
.btn-wide:active, .btn-wide2:active, .btn-close:active {
  border-color: #808080 #fff #fff #808080;
  padding: 2px 3px 0 5px;
}
.btn:hover, .btn-sm:hover, .btn-sm2:hover,
.btn-wide:hover, .btn-wide2:hover, .btn-close:hover {
  background: #c8c4bc;
}

.btn-close { background: #d4d0c8; }

.hints {
  flex: 1;
  font-size: 10px;
  color: #333;
  line-height: 1.4;
}
.hint-txt { font-size: 10px; color: #333; white-space: nowrap; }

/* Combos and number inputs */
.combo-sm {
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 11px;
  background: #fff;
  border: 2px solid;
  border-color: #808080 #fff #fff #808080;
  height: 20px;
  padding: 0 1px;
}

.num3, .num2 {
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 11px;
  background: #fff;
  border: 2px solid;
  border-color: #808080 #fff #fff #808080;
  height: 20px;
  padding: 0 2px;
  text-align: center;
}
.num3 { width: 42px; }
.num2 { width: 32px; }
</style>
