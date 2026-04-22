// Button.js — Responsive dark-theme button

class Button {
  constructor(x, y, w, h, text, type = 'default') {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.text    = text;
    this.type    = type;   // 'default' | 'primary' | 'danger'
    this.pressed = false;
    this.checked = false;
    this.visible = true;
    this._flash  = 0;
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

  reset()           { this.pressed = false; }
  setChecked(state) { this.checked = state; }

  onMouseUp(mx, my, trY = 0) {
    if (!this.visible) return;
    if (this.isMouseIn(mx, my, trY)) { this.pressed = true; this._flash = 8; }
  }

  draw(ctx, trY = 0) {
    if (!this.isVisible(trY)) return;
    if (this._flash > 0) this._flash--;

    const x = this.x, y = this.y + trY, w = this.w, h = this.h;
    const r = Math.min(10, h * 0.28);

    let bg, border;
    if (this._flash > 0) {
      bg     = 'rgba(255,255,255,0.30)';
      border = 'rgba(255,255,255,0.70)';
    } else if (this.checked) {
      switch (this.type) {
        case 'danger':  bg = 'rgba(185,28,28,0.92)';  border = 'rgba(252,165,165,0.55)'; break;
        case 'primary': bg = 'rgba(21,128,61,0.92)';  border = 'rgba(134,239,172,0.55)'; break;
        default:        bg = 'rgba(29,78,216,0.92)';  border = 'rgba(147,197,253,0.55)'; break;
      }
    } else {
      switch (this.type) {
        case 'danger':  bg = 'rgba(100,20,20,0.82)';  border = 'rgba(252,165,165,0.22)'; break;
        case 'primary': bg = 'rgba(16,60,34,0.82)';   border = 'rgba(134,239,172,0.22)'; break;
        default:        bg = 'rgba(15,20,36,0.82)';   border = 'rgba(255,255,255,0.13)'; break;
      }
    }

    ctx.save();
    ctx.beginPath();
    ctx.roundRect(x, y, w, h, r);
    ctx.fillStyle = bg;
    ctx.fill();
    ctx.strokeStyle = border;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    const fontSize = Math.max(11, Math.floor(h * 0.40));
    ctx.fillStyle    = this.checked ? '#ffffff' : '#cdd3e0';
    ctx.font         = `bold ${fontSize}px monospace`;
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.text, x + w / 2, y + h / 2, w - 10);
    ctx.restore();
  }
}
