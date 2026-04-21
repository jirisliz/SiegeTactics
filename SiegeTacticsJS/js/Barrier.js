// Barrier.js — Editor-placed visual barrier (red outline box)
// Ported from Barrier.pde

class Barrier extends GameObject {
  constructor(x, y, w, h) {
    super();
    this.size     = { x: w, y: h };
    this.position = { x: x + w/2, y: y + h/2 };
    this.orig     = { x: w/2, y: h/2 };
  }

  centre() { return { x: this.position.x, y: this.position.y }; }

  intersectsVehicle(u) {
    const hw = this.size.x / 2 + u.r, hh = this.size.y / 2 + u.r;
    return u.position.x > this.position.x - hw && u.position.x < this.position.x + hw &&
           u.position.y > this.position.y - hh && u.position.y < this.position.y + hh;
  }

  draw(ctx) {
    ctx.save();
    ctx.strokeStyle = 'rgba(250,30,30,0.9)';
    ctx.lineWidth   = 2;
    ctx.strokeRect(this.position.x - this.size.x/2, this.position.y - this.size.y/2,
                   this.size.x, this.size.y);
    ctx.restore();
  }
}
