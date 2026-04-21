// main.js — Entry point: canvas setup, game loop, asset manifest
// Ported from sketch.pde

// ── Asset manifest ────────────────────────────────────────────────────────
// List every tileset PNG so the Editor file pickers know what's available.
// Update when you add new tilesets.
window.ASSET_MANIFEST = {
  'assets/backs': [
    'dirtBck.png',
    'grassBck.png'
  ],
  'assets/tiles': [
    'Castle1.png',
    'dirt.png',
    'dirtTile.png',
    'grass.png',
    'tileset16x16_1.png',
    'treesAndObjs.png'
  ]
};

// ── Canvas setup ──────────────────────────────────────────────────────────
const canvas = document.getElementById('gameCanvas');

// All game logic works in CSS / logical pixels (window.innerWidth / Height).
// The canvas backing store is scaled by devicePixelRatio so drawing is crisp
// on HiDPI / Retina screens.  We apply a matching ctx.setTransform() so every
// draw call uses logical coordinates — no game code needs to know about DPR.
function resize() {
  const dpr = window.devicePixelRatio || 1;
  const lw  = window.innerWidth;
  const lh  = window.innerHeight;

  // Physical pixel resolution of the backing store
  canvas.width  = Math.round(lw * dpr);
  canvas.height = Math.round(lh * dpr);

  // CSS display size matches the logical viewport exactly
  canvas.style.width  = lw + 'px';
  canvas.style.height = lh + 'px';

  // Scale context so all draw calls use logical (CSS) pixels
  const ctx = canvas.getContext('2d');
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}

resize();

window.addEventListener('resize', () => {
  resize();
  // Rebuild menu so buttons re-centre for the new viewport size
  if (window._menu) {
    window._menu = new MainMenu(canvas);
  }
});

// Prevent browser scroll / zoom gestures swallowing canvas touch events
canvas.addEventListener('touchstart',  e => e.preventDefault(), { passive: false });
canvas.addEventListener('touchmove',   e => e.preventDefault(), { passive: false });
canvas.addEventListener('contextmenu', e => e.preventDefault());

// ── Game loop ─────────────────────────────────────────────────────────────
let   lastTime   = 0;
const TARGET_FPS = 40;
const FRAME_MS   = 1000 / TARGET_FPS;

function loop(timestamp) {
  const dt = timestamp - lastTime;
  if (dt >= FRAME_MS) {
    lastTime = timestamp - (dt % FRAME_MS);
    window._menu.draw();
  }
  requestAnimationFrame(loop);
}

// ── Boot ──────────────────────────────────────────────────────────────────
window.addEventListener('load', () => {
  window._menu = new MainMenu(canvas);
  requestAnimationFrame(loop);
});
