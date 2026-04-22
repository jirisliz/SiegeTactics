// ScrollBar.js — Scrollable list of buttons
// Ported from ScrollBar.pde

class ScrollBar {
  constructor() {
    this.btns           = [];
    this.translateY     = 0;
    this.velocity       = 0;
    this.inertia        = 0.6;
    this._lastY         = 0;
    this._initY         = 0;
    this._pressed       = false;
    this._moving        = false;
    this.loaded         = false;
    this.lastClickedBtn = null;
    this.totalHeight    = window.innerHeight;
    this.layoutTopSpace = 100;
    this._barW          = window.innerWidth * 0.04;
  }

  // Populate from an array of name strings
  fromNames(names, topSpace) {
    this.btns = [];
    if (topSpace !== undefined) this.layoutTopSpace = topSpace;
    for (const n of names) this._addName(n);
    this._recalc();
    this.loaded = this.btns.length > 0;
  }

  _addName(name) {
    const i   = this.btns.length;
    const cW  = window.innerWidth;
    const bH  = UI.btnH;
    const pad = UI.pad;
    const rowH = bH + pad;
    const btn = new Button(pad * 2, i * rowH + pad + this.layoutTopSpace,
                           cW - pad * 4, bH, name);
    this.btns.push(btn);
  }

  _recalc() {
    if (!this.btns.length) return;
    const last       = this.btns[this.btns.length - 1];
    this.totalHeight = last.y + last.h + 20;
  }

  open(my) { this._pressed = true; this._initY = this.translateY; this._lastY = my; }

  update(dy) {
    const max = window.innerHeight;
    if (this.totalHeight + this.translateY + dy > max) {
      this.translateY += dy;
      this._moving     = true;
      if (this.translateY > 0) this.translateY = 0;
    }
    this._lastY -= dy;
  }

  close(my) {
    this._pressed = false;
    if (Math.abs(this._initY - this.translateY) > 20)
      this.velocity = Math.max(-100, Math.min(100, this._lastY - this.translateY));
    if (!this._moving) {
      for (const btn of this.btns) btn.onMouseUp(0, my, this.translateY);  // simulate with last y
    }
    this._checkBtns();
  }

  onMouseUp(mx, my) {
    if (!this._moving) {
      for (const btn of this.btns) btn.onMouseUp(mx, my, this.translateY);
    }
    this._checkBtns();
    this._pressed = false;
    this.velocity = 0;
    this._moving  = false;
  }

  _checkBtns() {
    for (const btn of this.btns) {
      if (btn.pressed) { btn.reset(); this.lastClickedBtn = btn; }
    }
  }

  draw(ctx) {
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, window.innerWidth, window.innerHeight);
    ctx.save();
    ctx.translate(0, this.translateY);
    for (const btn of this.btns) btn.draw(ctx);
    ctx.restore();

    // Inertia
    const cH = window.innerHeight;
    if (this.velocity < -2 * this.inertia) {
      this.velocity  += this.inertia;
      this.translateY -= this.velocity;
      if (this.translateY > 0) { this.translateY = 0; this.velocity = 0; }
    } else if (this.velocity > 2 * this.inertia) {
      this.velocity  -= this.inertia;
      this.translateY -= this.velocity;
      if (this.totalHeight + this.translateY < cH) {
        this.translateY = cH - this.totalHeight; this.velocity = 0;
      }
    } else {
      this._moving = false;
    }

    // Scrollbar thumb
    if (this.totalHeight > cH) {
      const frac = cH / this.totalHeight;
      const tx   = window.innerWidth - this._barW * 1.5;
      const ty   = (-this.translateY / this.totalHeight) * cH;
      ctx.fillStyle = 'rgba(150,150,150,0.5)';
      ctx.beginPath();
      ctx.roundRect(tx, ty, this._barW, frac * cH, this._barW * 0.4);
      ctx.fill();
    }
  }
}
