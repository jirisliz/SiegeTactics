// TilePicker.js — Lets the user pick a tile region from a tileset image
// Ported from TilePicker.pde

class TilePicker {
  constructor(tileFile) {
    this.finished  = false;
    this.tileFile  = tileFile;
    this.selTiles  = null;
    this.selArea   = null;   // OffscreenCanvas of the selected region
    this._mx       = 0;
    this._my       = 0;
    this.tilePos   = null;
    this.tileSz    = null;

    const cW = window.innerWidth, cH = window.innerHeight;
    this.cam = new Camera(512, 512);
    this.cam.init(cW, cH);
    this.cam.fitWidth(cW);
    this.cam.scaleMin /= 2;
    this.cam.scaleMax  = this.cam.scaleMin + 20;
    this.cam.scale     = this.cam.scaleMin;
    this.cam.selEnabled = true;
    this.cam.bordersCheck = false;

    this.btnBack   = new Button(cW * 6/8, cH * 19/20, cW * 2/8 - 4, cH / 21, 'Back');
    this.btnSelect = new Button(cW * 1/8, cH * 19/20, cW * 4/8,     cH / 21, 'Select');

    // Load the tileset as a plain image for display + extraction
    this._tileImg = new LoadTile(`${Storage.dataDirTiles}/${tileFile}`, 16);
    this._blockSz = 16;

    // Pre-render full tileset onto an OffscreenCanvas for display
    this._sheet = null;
    const raw   = new Image();
    raw.src     = `${Storage.dataDirTiles}/${tileFile}`;
    raw.onload  = () => {
      this._sheet = new OffscreenCanvas(raw.width, raw.height);
      this._sheet.getContext('2d').drawImage(raw, 0, 0);
      this.cam = new Camera(raw.width, raw.height);
      this.cam.init(cW, cH);
      const fit = Math.min(cW / raw.width, (cH * 0.9) / raw.height);
      this.cam.scaleMin     = fit * 0.25;
      this.cam.scale        = fit;
      this.cam.selEnabled   = true;
      this.cam.bordersCheck = false;
      this._blockSz = Math.floor(raw.height / Math.round(raw.height / 16));
    };
  }

  getSelectedTileObject() {
    if (!this.selArea) return null;
    const to = new TileObject(this.tileFile,
                              this.tilePos.x, this.tilePos.y,
                              this.tileSz.x,  this.tileSz.y);
    to.setTileImg(this.selArea);
    return to;
  }

  // ── Input ─────────────────────────────────────────────────────────────────
  onMouseDown(mx, my) { this.cam.onMouseDown(mx, my); }
  onMouseMove(mx, my, px, py, drag) { this._mx = mx; this._my = my; }

  onMouseUp(mx, my) {
    this.btnBack.onMouseUp(mx, my);
    this.btnSelect.onMouseUp(mx, my);
    if (this._checkBtns()) return;
    this.cam.onMouseUp(mx, my);
    this._buildSelection(mx, my);
  }

  _buildSelection(mx, my) {
    if (!this._sheet) return;
    const s = this._blockSz;
    this.selTiles = [];

    if (this.cam.selFinished && this.cam.touchStart && this.cam.touchEnd) {
      const ws = this.cam.screen2World(this.cam.touchStart.x, this.cam.touchStart.y);
      const we = this.cam.screen2World(this.cam.touchEnd.x,   this.cam.touchEnd.y);
      const sx = Math.floor(Math.min(ws.x, we.x) / s);
      const sy = Math.floor(Math.min(ws.y, we.y) / s);
      const ex = Math.floor(Math.max(ws.x, we.x) / s);
      const ey = Math.floor(Math.max(ws.y, we.y) / s);
      for (let i = sx; i <= ex; i++)
        for (let j = sy; j <= ey; j++)
          this.selTiles.push({ x: i, y: j });
    } else {
      const w = this.cam.screen2World(mx, my);
      this.selTiles.push({ x: Math.floor(w.x / s), y: Math.floor(w.y / s) });
    }

    if (!this.selTiles.length) return;
    const xs = this.selTiles.map(t => t.x), ys = this.selTiles.map(t => t.y);
    const mx2 = Math.min(...xs), my2 = Math.min(...ys);
    const Mx  = Math.max(...xs), My  = Math.max(...ys);
    if (Mx < mx2 || My < my2) { this.selArea = null; return; }

    this.tileSz  = { x: (Mx - mx2 + 1) * s, y: (My - my2 + 1) * s };
    this.tilePos = { x: mx2 * s, y: my2 * s };
    this.selArea = new OffscreenCanvas(this.tileSz.x, this.tileSz.y);
    const ctx    = this.selArea.getContext('2d');
    for (const t of this.selTiles)
      ctx.drawImage(this._sheet,
        t.x * s, t.y * s, s, s,
        (t.x - mx2) * s, (t.y - my2) * s, s, s);
  }

  _checkBtns() {
    if (this.btnBack.pressed)   { this.btnBack.reset();   this.finished = true; return true; }
    if (this.btnSelect.pressed) { this.btnSelect.reset(); this.finished = true; return true; }
    return false;
  }

  // ── Draw ──────────────────────────────────────────────────────────────────
  draw(ctx) {
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, window.innerWidth, window.innerHeight);

    if (this._sheet) {
      this.cam.push(ctx);
      ctx.drawImage(this._sheet, 0, 0);

      const s = this._blockSz;

      // Committed selection highlight
      if (this.selTiles) {
        ctx.save();
        ctx.fillStyle   = 'rgba(30,250,30,0.2)';
        ctx.strokeStyle = 'rgba(30,250,30,0.9)';
        ctx.lineWidth   = 1;
        for (const t of this.selTiles) {
          ctx.fillRect  (t.x * s, t.y * s, s, s);
          ctx.strokeRect(t.x * s, t.y * s, s, s);
        }
        ctx.restore();
      }

      // Live selection preview while dragging
      if (this.cam.touchStart && !this.cam.selFinished) {
        const ws = this.cam.screen2World(this.cam.touchStart.x, this.cam.touchStart.y);
        const we = this.cam.screen2World(this._mx, this._my);
        const sx = Math.floor(Math.min(ws.x, we.x) / s);
        const sy = Math.floor(Math.min(ws.y, we.y) / s);
        const ex = Math.floor(Math.max(ws.x, we.x) / s);
        const ey = Math.floor(Math.max(ws.y, we.y) / s);
        ctx.save();
        ctx.fillStyle   = 'rgba(30,250,30,0.15)';
        ctx.strokeStyle = 'rgba(30,250,30,0.7)';
        ctx.lineWidth   = 1;
        ctx.fillRect  (sx * s, sy * s, (ex - sx + 1) * s, (ey - sy + 1) * s);
        ctx.strokeRect(sx * s, sy * s, (ex - sx + 1) * s, (ey - sy + 1) * s);
        ctx.restore();
      }

      this.cam.pop(ctx);
    }

    if (this.selArea)
      ctx.drawImage(this.selArea, this.selArea.width + 10, this.selArea.height + 10);

    this.btnBack.draw(ctx);
    this.btnSelect.draw(ctx);
  }
}
