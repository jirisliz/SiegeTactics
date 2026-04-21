// GameObject.js — Abstract base for all game objects
// Ported from Object.pde  (renamed to avoid clash with JS built-in Object)

class GameObject {
  constructor() {
    this.position  = { x: 0, y: 0 };
    this.size      = { x: 16, y: 16 };
    this.orig      = { x: 0, y: 0 };   // local-origin offset used for y-sort
    this.active    = true;
    this.reqDelete = false;
  }

  delete()      { this.reqDelete = true; }

  posInside(px, py) {
    const hw = this.size.x / 2, hh = this.size.y / 2;
    return px > this.position.x - hw && px < this.position.x + hw &&
           py > this.position.y - hh && py < this.position.y + hh;
  }

  intersects(other) {
    const { position: p1, size: s1 } = this;
    const { position: p2, size: s2 } = other;
    return (p1.x < p2.x + s2.x) && (p1.x + s1.x > p2.x) &&
           (p1.y < p2.y + s2.y) && (p1.y + s1.y > p2.y);
  }

  draw(ctx) { /* override */ }
}
