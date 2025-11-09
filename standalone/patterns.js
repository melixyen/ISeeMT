// ISee Monitor Test - Standalone Pattern Renderer
// Can be used independently without Tauri

const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
let animationId = null;

// Initialize canvas size
function initCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}

// Clear canvas
function clearCanvas() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
}

// Stop any running animation
function stopAnimation() {
  if (animationId) {
    cancelAnimationFrame(animationId);
    clearTimeout(animationId);
    animationId = null;
  }
}

// Toggle controls visibility
function toggleControls() {
  const controls = document.getElementById('controls');
  controls.classList.toggle('hidden');
}

// Main pattern dispatcher
function showPattern(patternName) {
  stopAnimation();
  clearCanvas();
  
  switch (patternName) {
    case 'white':
      drawSolidColor('#FFFFFF');
      break;
    case 'black':
      drawSolidColor('#000000');
      break;
    case 'red':
      drawSolidColor('#FF0000');
      break;
    case 'green':
      drawSolidColor('#00FF00');
      break;
    case 'blue':
      drawSolidColor('#0000FF');
      break;
    case 'gray128':
      drawGrayLevel(128);
      break;
    case 'gray204':
      drawGrayLevel(204);
      break;
    case 'colorTable':
      drawColorTable();
      break;
    case 'grayWave':
      animateGrayWave();
      break;
    case 'horizontalLines':
      drawHorizontalLines();
      break;
    case 'verticalLines':
      drawVerticalLines();
      break;
    case 'crossLines':
      drawCrossLines();
      break;
    case 'uniformityWhite':
      drawUniformity('#FFFFFF', '#000000');
      break;
    case 'uniformityBlack':
      drawUniformity('#000000', '#FFFFFF');
      break;
    case 'uniformityRed':
      drawUniformity('#FF0000', '#000000');
      break;
    case 'uniformityGreen':
      drawUniformity('#00FF00', '#000000');
      break;
    case 'uniformityBlue':
      drawUniformity('#0000FF', '#000000');
      break;
    case 'lightStack':
      drawLevelStack(207, 255, 3, '#000000');
      break;
    case 'medStack':
      drawLevelStack(128, 192, 4, '#000000');
      break;
    case 'darkStack':
      drawLevelStack(48, 0, -3, '#FFFFFF');
      break;
    case 'cube':
      animateCube();
      break;
    case 'circle':
      animateCircle();
      break;
    case 'blink':
      animateBlink();
      break;
    case 'interval':
      animateInterval();
      break;
  }
}

// Custom color
function showCustomColor() {
  const r = parseInt(document.getElementById('customR').value) || 0;
  const g = parseInt(document.getElementById('customG').value) || 0;
  const b = parseInt(document.getElementById('customB').value) || 0;
  
  stopAnimation();
  clearCanvas();
  ctx.fillStyle = `rgb(${r}, ${g}, ${b})`;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

// Pattern implementations
function drawSolidColor(color) {
  ctx.fillStyle = color;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

function drawGrayLevel(level) {
  const hex = level.toString(16).padStart(2, '0');
  ctx.fillStyle = `#${hex}${hex}${hex}`;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

function drawColorTable() {
  const w = canvas.width;
  const h = canvas.height;
  const barHeight = h / 32;
  
  for (let i = 0; i < 256; i++) {
    const x = (i / 256) * (w / 2);
    const width = (w / 2) / 256;
    
    // Left side - pure colors
    ctx.fillStyle = `rgb(${i}, 0, 0)`;
    ctx.fillRect(x, barHeight * 3, width, barHeight);
    
    ctx.fillStyle = `rgb(0, ${i}, 0)`;
    ctx.fillRect(x, barHeight * 4, width, barHeight);
    
    ctx.fillStyle = `rgb(0, 0, ${i})`;
    ctx.fillRect(x, barHeight * 5, width, barHeight);
    
    // Grayscale
    ctx.fillStyle = `rgb(${i}, ${i}, ${i})`;
    ctx.fillRect(x * 2, barHeight * 7, width * 2, barHeight);
    
    // Right side - light colors
    ctx.fillStyle = `rgb(255, ${i}, ${i})`;
    ctx.fillRect(w / 2 + x, barHeight * 3, width, barHeight);
    
    ctx.fillStyle = `rgb(${i}, 255, ${i})`;
    ctx.fillRect(w / 2 + x, barHeight * 4, width, barHeight);
    
    ctx.fillStyle = `rgb(${i}, ${i}, 255)`;
    ctx.fillRect(w / 2 + x, barHeight * 5, width, barHeight);
  }
  
  // Draw 16-level RGB bars at bottom
  const d1Y = h * 0.7;
  const d1H = (h - d1Y) / 3;
  const d1W = w / 16;
  
  for (let i = 0; i < 16; i++) {
    ctx.fillStyle = `rgb(${i * 17}, 0, 0)`;
    ctx.fillRect(i * d1W, d1Y, d1W, d1H);
    
    ctx.fillStyle = `rgb(0, ${i * 17}, 0)`;
    ctx.fillRect(i * d1W, d1Y + d1H, d1W, d1H);
    
    ctx.fillStyle = `rgb(0, 0, ${i * 17})`;
    ctx.fillRect(i * d1W, d1Y + d1H * 2, d1W, d1H);
  }
}

function animateGrayWave() {
  let currentGray = 0;
  let direction = 1;
  
  function animate() {
    ctx.fillStyle = `rgb(${currentGray}, ${currentGray}, ${currentGray})`;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    currentGray += direction;
    if (currentGray >= 255 || currentGray <= 0) {
      direction *= -1;
    }
    
    animationId = setTimeout(() => {
      requestAnimationFrame(animate);
    }, 250);
  }
  
  animate();
}

function drawHorizontalLines() {
  const lineHeight = 15;
  let isBlack = true;
  
  for (let y = 0; y < canvas.height; y += lineHeight) {
    ctx.fillStyle = isBlack ? '#000000' : '#FFFFFF';
    ctx.fillRect(0, y, canvas.width, lineHeight);
    isBlack = !isBlack;
  }
}

function drawVerticalLines() {
  const lineWidth = 15;
  let isBlack = true;
  
  for (let x = 0; x < canvas.width; x += lineWidth) {
    ctx.fillStyle = isBlack ? '#000000' : '#FFFFFF';
    ctx.fillRect(x, 0, lineWidth, canvas.height);
    isBlack = !isBlack;
  }
}

function drawCrossLines() {
  ctx.fillStyle = '#808080';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  
  const w = canvas.width;
  const h = canvas.height;
  
  ctx.strokeStyle = '#000000';
  ctx.lineWidth = 2;
  
  ctx.beginPath();
  ctx.moveTo(0, h / 3);
  ctx.lineTo(w, h / 3);
  ctx.moveTo(0, 2 * h / 3);
  ctx.lineTo(w, 2 * h / 3);
  ctx.moveTo(w / 3, 0);
  ctx.lineTo(w / 3, h);
  ctx.moveTo(2 * w / 3, 0);
  ctx.lineTo(2 * w / 3, h);
  ctx.stroke();
}

function drawUniformity(fg, bg) {
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  
  const w = canvas.width;
  const h = canvas.height;
  const boxW = w / 4;
  const boxH = h / 4;
  
  ctx.fillStyle = fg;
  
  // Center
  ctx.fillRect(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH);
  
  // Four corners
  ctx.fillRect(0, 0, boxW, boxH);
  ctx.fillRect(w - boxW, 0, boxW, boxH);
  ctx.fillRect(0, h - boxH, boxW, boxH);
  ctx.fillRect(w - boxW, h - boxH, boxW, boxH);
}

function drawLevelStack(start, end, step, textColor) {
  const w = canvas.width;
  const h = canvas.height;
  const borderW = w / 64;
  const borderH = h / 64;
  
  let x = 0, y = 0;
  let width = w, height = h;
  let level = 0;
  
  ctx.font = '20px Arial';
  
  for (let gray = start; step > 0 ? gray <= end : gray >= end; gray += step) {
    ctx.fillStyle = `rgb(${gray}, ${gray}, ${gray})`;
    ctx.fillRect(x, y, width, height);
    
    ctx.fillStyle = textColor;
    ctx.fillText(level.toString(), x + borderW, y + borderH + 20);
    
    x += borderW;
    y += borderH;
    width -= borderW * 2;
    height -= borderH * 2;
    level++;
  }
  
  // Add info text
  ctx.fillStyle = textColor;
  ctx.font = '16px Arial';
  const infoY = h / 2.5;
  ctx.fillText(`From Gray Level ${start} to ${end} Step ${step}`, w / 2.7, infoY);
  ctx.fillText(`If it's not discriminable ${level} levels, Check your monitor!`, w / 2.7, infoY + 25);
}

function animateCube() {
  let x = 0, y = 0;
  let dx = 5, dy = 5;
  const size = 100;
  
  function animate() {
    clearCanvas();
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(x, y, size, size);
    
    x += dx;
    y += dy;
    
    if (x + size >= canvas.width || x <= 0) dx *= -1;
    if (y + size >= canvas.height || y <= 0) dy *= -1;
    
    animationId = setTimeout(() => {
      requestAnimationFrame(animate);
    }, 16);
  }
  
  animate();
}

function animateCircle() {
  let radius = 50;
  let growing = true;
  const maxRadius = Math.min(canvas.width, canvas.height) / 2;
  
  function animate() {
    clearCanvas();
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(canvas.width / 2, canvas.height / 2, radius, 0, Math.PI * 2);
    ctx.fill();
    
    if (growing) {
      radius += 5;
      if (radius >= maxRadius) growing = false;
    } else {
      radius -= 5;
      if (radius <= 50) growing = true;
    }
    
    animationId = setTimeout(() => {
      requestAnimationFrame(animate);
    }, 250);
  }
  
  animate();
}

function animateBlink() {
  let isWhite = true;
  
  function animate() {
    ctx.fillStyle = isWhite ? '#FFFFFF' : '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    isWhite = !isWhite;
    
    animationId = setTimeout(() => {
      requestAnimationFrame(animate);
    }, 250);
  }
  
  animate();
}

function animateInterval() {
  let gray = 0;
  let increasing = true;
  
  function animate() {
    ctx.fillStyle = `rgb(${gray}, ${gray}, ${gray})`;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    if (increasing) {
      gray += 5;
      if (gray >= 255) {
        gray = 255;
        increasing = false;
      }
    } else {
      gray -= 5;
      if (gray <= 0) {
        gray = 0;
        increasing = true;
      }
    }
    
    animationId = setTimeout(() => {
      requestAnimationFrame(animate);
    }, 250);
  }
  
  animate();
}

// Event listeners
window.addEventListener('resize', () => {
  initCanvas();
  // Optionally redraw current pattern
});

window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    toggleControls();
  } else if (e.key === 'F11') {
    e.preventDefault();
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen();
    } else {
      document.exitFullscreen();
    }
  }
});

// Initialize on load
initCanvas();
showPattern('white');

