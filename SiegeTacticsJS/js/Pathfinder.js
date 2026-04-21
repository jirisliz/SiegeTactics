// Pathfinder.js — A* grid pathfinding with line-of-sight path simplification

class Pathfinder {
  constructor(cols, rows, sz, barriers) {
    this.cols    = cols;
    this.rows    = rows;
    this.sz      = sz;
    this.blocked = new Uint8Array(cols * rows);
    // expand each barrier by one cell so units don't clip corners
    const margin = sz * 0.6;
    for (const b of barriers) {
      const x1 = Math.max(0,       Math.floor((b.position.x - b.size.x / 2 - margin) / sz));
      const y1 = Math.max(0,       Math.floor((b.position.y - b.size.y / 2 - margin) / sz));
      const x2 = Math.min(cols-1,  Math.ceil ((b.position.x + b.size.x / 2 + margin) / sz));
      const y2 = Math.min(rows-1,  Math.ceil ((b.position.y + b.size.y / 2 + margin) / sz));
      for (let y = y1; y <= y2; y++)
        for (let x = x1; x <= x2; x++)
          this.blocked[x + y * cols] = 1;
    }
  }

  _idx(x, y) { return x + y * this.cols; }

  // Bresenham line-of-sight check between two grid cells
  _hasLOS(x1, y1, x2, y2) {
    const { cols, rows, blocked } = this;
    let dx = Math.abs(x2 - x1), dy = Math.abs(y2 - y1);
    let sx = x1 < x2 ? 1 : -1, sy = y1 < y2 ? 1 : -1;
    let err = dx - dy, x = x1, y = y1;
    for (;;) {
      if (x < 0 || y < 0 || x >= cols || y >= rows || blocked[x + y * cols]) return false;
      if (x === x2 && y === y2) return true;
      const e2 = 2 * err;
      if (e2 > -dy) { err -= dy; x += sx; }
      if (e2 <  dx) { err += dx; y += sy; }
    }
  }

  // Find nearest open cell within a small search radius
  _nearestOpen(cx, cy) {
    const { cols, rows, blocked } = this;
    if (!blocked[this._idx(cx, cy)]) return { x: cx, y: cy };
    for (let r = 1; r < 6; r++) {
      for (let dy = -r; dy <= r; dy++) {
        for (let dx = -r; dx <= r; dx++) {
          const nx = cx + dx, ny = cy + dy;
          if (nx >= 0 && ny >= 0 && nx < cols && ny < rows && !blocked[this._idx(nx, ny)])
            return { x: nx, y: ny };
        }
      }
    }
    return null;
  }

  findPath(from, to) {
    const { cols, rows, sz, blocked } = this;
    const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));
    const wx = v => clamp(Math.floor(v / sz), 0, cols - 1);
    const wy = v => clamp(Math.floor(v / sz), 0, rows - 1);

    const sOpen = this._nearestOpen(wx(from.x), wy(from.y));
    const gOpen = this._nearestOpen(wx(to.x),   wy(to.y));
    if (!sOpen || !gOpen) return null;
    const { x: sx, y: sy } = sOpen;
    const { x: gx, y: gy } = gOpen;
    if (sx === gx && sy === gy) return null;

    // A* — 8-directional movement
    const N      = cols * rows;
    const gScore = new Float32Array(N).fill(Infinity);
    const fScore = new Float32Array(N).fill(Infinity);
    const came   = new Int32Array(N).fill(-1);
    const inOpen = new Uint8Array(N);
    const closed = new Uint8Array(N);

    const h  = (x, y) => Math.hypot(gx - x, gy - y);
    const si = this._idx(sx, sy);
    gScore[si] = 0;
    fScore[si] = h(sx, sy);
    inOpen[si] = 1;

    const open = [si];
    const DIRS = [
      [1,0,1],[0,1,1],[-1,0,1],[0,-1,1],
      [1,1,1.414],[1,-1,1.414],[-1,1,1.414],[-1,-1,1.414]
    ];

    let found = false;
    while (open.length) {
      // pop lowest fScore
      let bi = 0;
      for (let i = 1; i < open.length; i++)
        if (fScore[open[i]] < fScore[open[bi]]) bi = i;
      const cur = open.splice(bi, 1)[0];
      inOpen[cur] = 0;

      const cx = cur % cols, cy = (cur / cols) | 0;
      if (cx === gx && cy === gy) { found = true; break; }
      closed[cur] = 1;

      for (const [dx, dy, cost] of DIRS) {
        const nx = cx + dx, ny = cy + dy;
        if (nx < 0 || ny < 0 || nx >= cols || ny >= rows) continue;
        const ni = this._idx(nx, ny);
        if (closed[ni] || blocked[ni]) continue;
        const tg = gScore[cur] + cost;
        if (tg < gScore[ni]) {
          came[ni]   = cur;
          gScore[ni] = tg;
          fScore[ni] = tg + h(nx, ny);
          if (!inOpen[ni]) { open.push(ni); inOpen[ni] = 1; }
        }
      }
    }

    if (!found) return null;

    // Reconstruct waypoints
    const raw = [];
    let cur = this._idx(gx, gy);
    while (cur !== -1) {
      const cx = cur % cols, cy = (cur / cols) | 0;
      raw.unshift({ gx: cx, gy: cy, x: (cx + 0.5) * sz, y: (cy + 0.5) * sz });
      cur = came[cur];
    }

    // Greedy line-of-sight simplification (string pulling)
    const simp = [raw[0]];
    let i = 0;
    while (i < raw.length - 1) {
      let j = raw.length - 1;
      while (j > i + 1 && !this._hasLOS(raw[i].gx, raw[i].gy, raw[j].gx, raw[j].gy)) j--;
      simp.push(raw[j]);
      i = j;
    }

    // Build Path object — addPoint in pairs as expected by Vehicle.follow()
    const path = new Path(sz * 0.8);
    for (let k = 0; k < simp.length - 1; k++) {
      path.addPoint(simp[k].x,     simp[k].y);
      path.addPoint(simp[k+1].x,   simp[k+1].y);
    }
    return path;
  }
}
