// Renderer.js — Y-sorted depth renderer
// Ported from Renderer.pde

class Renderer {
  constructor(worldHeight = 2000) {
    this._h      = worldHeight;
    this._buckets = [];
    this._back    = [];
    this._resize(worldHeight);
  }

  _resize(h) {
    this._h       = h;
    this._buckets = new Array(h).fill(null).map(() => []);
    this._back    = [];
  }

  add(obj) {
    const y = Math.floor(obj.position ? obj.position.y : 0);
    if (!obj.active) {
      this._back.push(obj);
    } else if (y >= 0 && y < this._buckets.length) {
      this._buckets[y].push(obj);
    }
  }

  clear() {
    for (let i = 0; i < this._buckets.length; i++) {
      if (this._buckets[i].length) this._buckets[i] = [];
    }
    this._back = [];
  }

  draw(ctx) {
    for (const obj of this._back)    obj.draw(ctx);
    for (const row of this._buckets) {
      for (const obj of row)         obj.draw(ctx);
    }
  }
}
