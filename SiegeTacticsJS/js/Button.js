// Button.js — Rounded-rect UI button
// Ported from Button.pde

class Button {
  constructor(x, y, w, h, text) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.text    = text;
    this.pressed = false;
    this.checked = false;
    this.visible = true;
    this._fillIdle    = 170;
    this._fillChecked = 210;
    this._fill        = 170;
  }

  isMouseIn(mx, my, trY = 0) {
    return mx > this.x && mx < this.x + this.w &&
           my > this.y + trY && my < this.y + this.h + trY;
  }

  isVisible(trY = 0) {
    if (!this.visible) return false;
    return this.x + this.w >= 0 && this.x <= window.innerWidth &&
           this.y + this.h + trY >= 0 && this.y + trY <= window.innerHeight;
  }

  reset()                { this.pressed = false; this._fill = this._fillIdle; }
  setChecked(state)      { this.checked = state; }

  onMouseUp(mx, my, trY = 0) {
    if (!this.visible) return;
    if (this.isMouseIn(mx, my, trY)) { this.pressed = true; this._fill = 80; }
  }

  draw(ctx, trY = 0) {
    if (!this.isVisible(trY)) return;
    if (this._fill < this._fillIdle) this._fill++;
    const f = this.checked ? this._fillChecked : this._fill;
    ctx.save();
    ctx.fillStyle   = `rgba(${f},${f},${f},0.6)`;
    ctx.strokeStyle = 'rgba(30,30,30,0.9)';
    ctx.lineWidth   = 3;
    const r = 14;
    ctx.beginPath();
    ctx.roundRect(this.x, this.y + trY, this.w, this.h, r);
    ctx.fill(); ctx.stroke();
    ctx.fillStyle  = '#191919';
    ctx.font       = `bold ${Math.floor(this.h * 0.4)}px monospace`;
    ctx.textAlign  = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.text, this.x + this.w/2, this.y + this.h/2 + trY);
    ctx.restore();
  }
}
