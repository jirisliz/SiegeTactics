// Wall.js — Impassable wall obstacle with unit separation
// Ported from Wall.pde

class Wall extends GameObject {
  constructor(x, y, w, h) {
    super();
    this.position = { x, y };
    this.w = w; this.h = h;
    this.size = { x: w, y: h };
    this.orig = { x: w/2, y: h/2 };
    this._inside = 0;
  }

  centre() { return { x: this.position.x + this.w / 2, y: this.position.y + this.h / 2 }; }

  intersectsVehicle(u) {
    const x1 = this.position.x - u.r, y1 = this.position.y - u.r;
    const x2 = x1 + this.w + u.r,     y2 = y1 + this.h + u.r;
    const hit = u.position.x > x1 && u.position.x < x2 &&
                u.position.y > y1 && u.position.y < y2;
    if (hit) this._inside++;
    return hit;
  }

  draw(ctx) {
    ctx.fillStyle = '#aaaaaa';
    ctx.fillRect(this.position.x, this.position.y, this.w, this.h / 3);
    ctx.fillStyle = '#787878';
    ctx.fillRect(this.position.x, this.position.y + this.h / 3, this.w, (this.h * 2) / 3);
    this._inside = 0;
  }
}
