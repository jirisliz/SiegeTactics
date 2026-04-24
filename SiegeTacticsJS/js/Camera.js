// Camera.js — Pan / zoom camera (world ↔ screen transform)
// Ported from Screen.pde

class Camera {
  constructor(worldW, worldH) {
    this.worldW = worldW;
    this.worldH = worldH;

    this.scale    = 1;
    this.scaleMin = 0.25;
    this.scaleMax = 10;
    this.transX   = 0;
    this.transY   = 0;
    this.offX     = 0;   // canvas centre — set via init()
    this.offY     = 0;

    this.bordersCheck = true;
    this.selEnabled   = false;
    this.selFinished  = false;
    this.touchStart   = null;
    this.touchEnd     = null;

    // Internal two-finger state
    this._trStart    = false;
    this._scaleOld   = 1;
    this._distOld    = 0;
    this._transXOld  = 0;
    this._transYOld  = 0;
    this._transXSt   = 0;
    this._transYSt   = 0;
    this._f1Old      = null;
    this._f2Old      = null;
  }

  init(canvasW, canvasH) {
    this.offX = canvasW / 2;
    this.offY = canvasH / 2;
    const s1  = canvasW / this.worldW;
    const s2  = canvasH / this.worldH;
    this.scaleMin = Math.max(s1, s2);
    this.scale    = this.scaleMin;
    this.transX   = -this.worldW / 2;
    this.transY   = -this.worldH / 2;
  }

  fitWidth(canvasW) {
    this.scaleMin = canvasW / this.worldW;
    this.scale    = this.scaleMin;
  }

  // Apply world transform — call before drawing scene
  push(ctx) {
    ctx.save();
    ctx.translate(this.offX, this.offY);
    ctx.scale(this.scale, this.scale);
    ctx.translate(this.transX, this.transY);
  }

  pop(ctx) { ctx.restore(); }

  world2Screen(wx, wy) {
    return {
      x: (wx + this.transX) * this.scale + this.offX,
      y: (wy + this.transY) * this.scale + this.offY
    };
  }

  screen2World(sx, sy) {
    return {
      x: (sx - this.offX) / this.scale - this.transX,
      y: (sy - this.offY) / this.scale - this.transY
    };
  }

  // ── Mouse events ──────────────────────────────────────────────────────────
  onMouseDown(x, y) {
    this.selFinished = false;
    if (this.selEnabled) this.touchStart = { x, y };
  }

  onMouseMove(x, y, prevX, prevY, isDragging) {
    if (!isDragging) return;
    const dx = (x - prevX) / this.scale;
    const dy = (y - prevY) / this.scale;
    this.transX += dx;
    this.transY += dy;
    if (this.bordersCheck) this.checkBorders();
  }

  onMouseUp(x, y) {
    if (this.selEnabled && this.touchStart) {
      const d = Math.hypot(x - this.touchStart.x, y - this.touchStart.y);
      if (d > 16) {
        this.touchEnd    = { x, y };
        this.selFinished = true;
      } else {
        this.touchEnd    = null;
        this.selFinished = false;
      }
    }
  }

  onWheel(deltaY) {
    const factor = deltaY > 0 ? 0.9 : 1.1;
    this.scale   = Math.min(this.scaleMax, Math.max(this.scaleMin, this.scale * factor));
    if (this.bordersCheck) this.checkBorders();
  }

  // ── Touch (pinch-zoom / two-finger pan) ───────────────────────────────────
  onTouchStart(touches) {
    this._trStart = false;
    this.selFinished = false;
    if (this.selEnabled && touches.length === 1) {
      this.touchStart = { x: touches[0].clientX, y: touches[0].clientY };
    }
  }

  onTouchMove(touches) {
    if (touches.length !== 2) return;
    const f1 = { x: touches[0].clientX, y: touches[0].clientY };
    const f2 = { x: touches[1].clientX, y: touches[1].clientY };
    if (!this._trStart) {
      this._trStart   = true;
      this._scaleOld  = this.scale;
      this._distOld   = Math.hypot(f2.x - f1.x, f2.y - f1.y);
      this._transXOld = this.transX;
      this._transYOld = this.transY;
      this._transXSt  = (f1.x + f2.x) / 2;
      this._transYSt  = (f1.y + f2.y) / 2;
      return;
    }
    const dist   = Math.hypot(f2.x - f1.x, f2.y - f1.y);
    const scl    = (dist - this._distOld) / (this.offY * 2);
    this.scale   = Math.min(this.scaleMax, Math.max(this.scaleMin, this._scaleOld + scl * 2));
    const midX   = (f1.x + f2.x) / 2;
    const midY   = (f1.y + f2.y) / 2;
    this.transX  = this._transXOld + (midX - this._transXSt) / this.scale;
    this.transY  = this._transYOld + (midY - this._transYSt) / this.scale;
    if (this.bordersCheck) this.checkBorders();
  }

  onTouchEnd(touches) {
    if (touches.length === 0) {
      this._trStart = false;
      if (this.selEnabled && this.touchStart) {
        // Single-tap: treated as zero-drag mouseUp
        this.touchEnd    = null;
        this.selFinished = false;
      }
    }
  }

  checkBorders() {
    // Clamp so at least half the map is always visible in each axis.
    // Pan limit: map edge may reach canvas centre but not beyond.
    if (this.transX > 0)           this.transX = 0;
    if (this.transX < -this.worldW) this.transX = -this.worldW;
    if (this.transY > 0)           this.transY = 0;
    if (this.transY < -this.worldH) this.transY = -this.worldH;
  }

  // Draw selection rectangle in screen space (call outside push/pop)
  drawSelRect(ctx, curX, curY) {
    if (!this.selEnabled || !this.touchStart) return;
    ctx.save();
    ctx.strokeStyle = 'rgba(30,250,30,0.9)';
    ctx.lineWidth   = 1.5;
    ctx.setLineDash([5, 3]);
    ctx.strokeRect(
      this.touchStart.x, this.touchStart.y,
      curX - this.touchStart.x, curY - this.touchStart.y
    );
    ctx.restore();
  }
}
