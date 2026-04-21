// Projectile.js — Arcing ranged projectile
// Ported from Projectile.pde

class Projectile extends GameObject {
  constructor(pos, imgPath) {
    super();
    this.position    = { ...pos };
    this.finished    = false;
    this.started     = false;
    this.attackHeight = false;
    this.maxSpeed    = 3;
    this.v           = { x:0, y:0 };
    this.curvePos    = { x:0, y:0 };
    this._arcDy      = 0;
    this.dist2Target = 0;
    this.target      = null;
    this.targetUnit  = null;
    this._img        = null;
    this.size        = { x:8, y:8 };
    this.orig        = { x:4, y:4 };
    if (imgPath) {
      const img = new Image();
      img.src   = imgPath;
      img.onload = () => { this._img = img; this.size = { x:img.width, y:img.height }; };
    }
  }

  _len(v)      { return Math.hypot(v.x, v.y); }
  _norm(v)     { const l = this._len(v)||1; return { x:v.x/l, y:v.y/l }; }
  _sub(a,b)    { return { x:a.x-b.x, y:a.y-b.y }; }
  _add(a,b)    { return { x:a.x+b.x, y:a.y+b.y }; }
  _scale(v,s)  { return { x:v.x*s,   y:v.y*s   }; }
  _dist(a,b)   { return Math.hypot(b.x-a.x, b.y-a.y); }
  _rotate(v,a) { return { x:v.x*Math.cos(a)-v.y*Math.sin(a), y:v.x*Math.sin(a)+v.y*Math.cos(a) }; }

  fire(target) {
    this.targetUnit  = target;
    this.target      = { ...target.position };
    this.v           = this._scale(this._norm(this._sub(this.target, this.position)), this.maxSpeed);
    this.dist2Target = this._dist(this.target, this.position);
    this.curvePos    = { x:0, y:0 };
    this._arcDy      = 0;
    this.started     = true;
  }

  update() {
    if (!this.started) return;
    this.position     = this._add(this.position, this.v);
    const curr        = this._dist(this.target, this.position);
    const t           = Math.max(0, 1 - curr / this.dist2Target);
    const arcH        = Math.min(this.dist2Target * 0.25, 60);
    const prevY       = this.curvePos.y;
    this.curvePos     = { x: 0, y: -4 * arcH * t * (1 - t) };
    this._arcDy       = this.curvePos.y - prevY;
    this.attackHeight = curr < this.dist2Target / 4;
    if (curr < 4) this.finished = true;
  }

  attackUnits() {
    if (!this.attackHeight) return;
    if (this.targetUnit) {
      if (this.targetUnit.alive &&
          this._dist(this.targetUnit.position, this.position) < 10) {
        this.targetUnit.attack(1); this.finished = true;
      }
      return;
    }
  }

  draw(ctx) {
    if (!this.started) return;
    const dx    = this.v.x;
    const dy    = this.v.y + this._arcDy;
    const angle = Math.atan2(dy, dx) + Math.PI / 2;
    const rx    = this.position.x + this.curvePos.x;
    const ry    = this.position.y + this.curvePos.y;
    ctx.save();
    ctx.translate(rx, ry);
    ctx.rotate(angle);
    if (this._img) {
      ctx.drawImage(this._img, -this._img.width/2, -this._img.height/2);
    } else {
      ctx.fillStyle = '#c0c000';
      ctx.fillRect(-2, -6, 4, 12);
    }
    ctx.restore();
  }
}
