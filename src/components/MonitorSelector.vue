<template>
  <div class="selector-root">
    <!-- Top toolbar row matching VB2005 FrmMonitorSelect -->
    <div class="toolbar">
      <span class="lbl">{{ t.changeLanguage }}</span>
      <button class="btn" @click="setLang('en')">English</button>
      <button class="btn" @click="setLang('zh')">繁體中文</button>
      <div class="vline"></div>
      <button class="btn" @click="closeApp">{{ t.closeApp }}</button>
      <div class="spacer"></div>
      <span class="lbl">{{ t.whichView }}</span>
      <select v-model="viewIdx" class="combo">
        <option v-for="i in monitors.length" :key="i" :value="i">{{ i }}</option>
      </select>
      <button class="btn" @click="viewDesktopRange">{{ t.viewDesktopRange }}</button>
    </div>

    <!-- Frame1: virtual desktop / monitor selection -->
    <fieldset class="frame1">
      <legend>{{ t.selectDisplayLegend }}</legend>
      <div class="vdesktop" ref="vdesktop">
        <button
          v-for="(m, i) in monitors"
          :key="m.id"
          class="monitor-btn"
          :style="btnStyle(m)"
          @click="selectMonitor(m)"
          @mouseenter="hoveredMonitor = m"
          @mouseleave="hoveredMonitor = null"
        >
          {{ t.monitor }}<br>{{ i + 1 }}
        </button>
      </div>
    </fieldset>

    <!-- Frame2: Chinese footer info matching VB2005 -->
    <fieldset class="frame2">
      <legend>This Frame Using Chinese BIG-5 繁體中文資訊</legend>
      <div class="footer-row">
        <span class="red2">程式新作 by :</span>&nbsp;
        <span style="color:#FF0000">極</span><span style="color:#FF8000">光</span><span style="color:#00AA00">駭</span><span style="color:#00CC00">客</span>
        &nbsp;&nbsp;
        <span class="red2">部落格 :</span>&nbsp;
        <a class="blog-link" href="#" @click.prevent="openBlog">http://blog.yam.com/user/melix.html</a>
        &nbsp;&nbsp;
        <span class="red3">可將您的建議增加功能或提供圖形供作者參考</span>
        <span class="ver">V0.9.23</span>
      </div>
      <div class="disclaimer">
        您要使用就要遵守，否則就不要使用：Free！不得將程式語法與圖形供作它用或商業用途，其他請全力支持！
      </div>
    </fieldset>

    <!-- Monitor info popup on hover -->
    <div v-if="hoveredMonitor" class="monitor-info-popup">
      <div>{{ t.leftStart }} {{ hoveredMonitor.x }}</div>
      <div>{{ t.topStart }} {{ hoveredMonitor.y }}</div>
      <div>{{ t.rightEnd }} {{ hoveredMonitor.x + hoveredMonitor.width }}</div>
      <div>{{ t.bottomEnd }} {{ hoveredMonitor.y + hoveredMonitor.height }}</div>
      <div>{{ t.widthLabel }} {{ hoveredMonitor.width }}</div>
      <div>{{ t.heightLabel }} {{ hoveredMonitor.height }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
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
  if (cmd === 'get_monitors_command') {
    return [{ id: 0, x: 0, y: 0, width: 1920, height: 1080, is_primary: true, name: 'Monitor 1' }]
  }
  return null
}

const props = defineProps({
  lang: { type: String, default: 'en' }
})
const emit = defineEmits(['changeLang'])
const t = useI18n(computed(() => props.lang))

const monitors = ref([])
const viewIdx = ref(1)
const hoveredMonitor = ref(null)
const vdesktop = ref(null)

const setLang = (l) => { emit('changeLang', l) }

const refreshMonitors = async () => {
  try {
    monitors.value = await invoke('get_monitors_command')
  } catch (e) {
    console.error(e)
  }
}

const selectMonitor = async (m) => {
  await invoke('open_test_window', {
    monitorId: m.id,
    x: m.x,
    y: m.y,
    width: m.width,
    height: m.height,
  })
}

const closeApp = async () => {
  try { await invoke('close_app') } catch {}
}

const openBlog = () => {
  window.open('http://blog.yam.com/user/melix.html', '_blank')
}

const viewDesktopRange = () => {
  const idx = viewIdx.value - 1
  const m = monitors.value[idx]
  if (!m) return
  const tl = t.value
  const msg = `${tl.leftStart} ${m.x}\n${tl.topStart} ${m.y}\n${tl.rightEnd} ${m.x + m.width}\n${tl.bottomEnd} ${m.y + m.height}\n${tl.widthLabel} ${m.width}\n${tl.heightLabel} ${m.height}`
  alert(msg)
}

// VB2005 CmdMntFix positioning: 1 pixel = 1 twip = 1/15 display pixel
// MyStartX=4760, MyStartY=3600 twips; Frame1 Top=720 twips
const SCALE = 1 / 15
const OFFSET_X = 4760 / 15
const OFFSET_Y = (3600 - 720) / 15

const btnStyle = (m) => {
  const minX = Math.min(...monitors.value.map(mon => mon.x))
  const minY = Math.min(...monitors.value.map(mon => mon.y))
  return {
    position: 'absolute',
    left: `${(m.x - minX) * SCALE + OFFSET_X}px`,
    top: `${(m.y - minY) * SCALE + OFFSET_Y}px`,
    width: `${m.width * SCALE}px`,
    height: `${m.height * SCALE}px`,
    minWidth: '40px',
    minHeight: '24px',
  }
}

onMounted(async () => {
  await refreshMonitors()
})
</script>

<style scoped>
/* Classic Windows 9x/2000 style */
.selector-root {
  width: 784px;
  min-height: 440px;
  background: #d4d0c8;
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 12px;
  color: #000;
  padding: 4px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  position: relative;
}

.toolbar {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 2px 0;
  flex-wrap: nowrap;
}

.lbl {
  white-space: nowrap;
  font-size: 12px;
}

.spacer { flex: 1; }

.vline {
  width: 2px;
  height: 20px;
  background: linear-gradient(to right, #808080, #fff);
  margin: 0 4px;
}

.btn {
  padding: 2px 8px;
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 12px;
  background: #d4d0c8;
  border: 2px solid;
  border-color: #fff #808080 #808080 #fff;
  cursor: pointer;
  min-width: 60px;
  white-space: nowrap;
}
.btn:active {
  border-color: #808080 #fff #fff #808080;
  padding: 3px 7px 1px 9px;
}
.btn:hover { background: #e0ddd5; }

.combo {
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 12px;
  background: #fff;
  border: 2px solid;
  border-color: #808080 #fff #fff #808080;
  padding: 1px 2px;
  height: 22px;
}

.frame1 {
  flex: 1;
  border: 2px solid;
  border-color: #808080 #fff #fff #808080;
  background: #d4d0c8;
  padding: 4px;
  min-height: 280px;
  position: relative;
}
.frame1 legend {
  font-size: 12px;
  padding: 0 4px;
  background: #d4d0c8;
}

.vdesktop {
  position: relative;
  width: 100%;
  height: 260px;
  overflow: visible;
}

.monitor-btn {
  position: absolute;
  background: #d4d0c8;
  border: 2px solid;
  border-color: #fff #808080 #808080 #fff;
  font-family: "MS Sans Serif", "Tahoma", sans-serif;
  font-size: 11px;
  font-weight: bold;
  cursor: pointer;
  text-align: center;
  line-height: 1.2;
  color: #000;
  padding: 2px;
}
.monitor-btn:hover {
  background: #c4c0b8;
}
.monitor-btn:active {
  border-color: #808080 #fff #fff #808080;
}

.frame2 {
  border: 2px solid;
  border-color: #808080 #fff #fff #808080;
  background: #d4d0c8;
  padding: 4px 8px;
}
.frame2 legend {
  font-size: 12px;
  padding: 0 4px;
  background: #d4d0c8;
}

.footer-row {
  display: flex;
  align-items: center;
  gap: 2px;
  flex-wrap: wrap;
  font-size: 12px;
  margin-bottom: 4px;
  position: relative;
}

.red2 { color: #C00000; }
.red3 { color: #C00000; font-size: 11px; }

.blog-link {
  color: #0000CC;
  text-decoration: underline;
  cursor: pointer;
  font-size: 12px;
}

.ver {
  margin-left: auto;
  font-size: 12px;
  color: #000;
}

.disclaimer {
  font-size: 11px;
  color: #333;
}

.monitor-info-popup {
  position: absolute;
  bottom: 80px;
  right: 10px;
  background: #ffffcc;
  border: 1px solid #808080;
  padding: 6px 8px;
  font-size: 11px;
  z-index: 100;
  box-shadow: 2px 2px 4px rgba(0,0,0,0.3);
  line-height: 1.6;
}
</style>
