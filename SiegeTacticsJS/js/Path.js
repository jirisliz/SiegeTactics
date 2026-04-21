// Path.js — Series of line-segment waypoints for path-following
// Ported from Path.pde

class Path {
  constructor(radius = 20, color = '#aaaaaa') {
    this.radius = radius;
    this.color  = color;
    this.points = [];
  }

  addPoint(x, y) { this.points.push({ x, y }); }

  draw(ctx) {
    ctx.save();
    ctx.strokeStyle = this.color;
    ctx.lineWidth   = this.radius * 2;
    ctx.globalAlpha = 0.35;
    ctx.lineCap     = 'round';
    for (let i = 0; i < this.points.length - 1; i += 2) {
      const a = this.points[i], b = this.points[i + 1];
      ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y); ctx.stroke();
    }
    ctx.restore();
  }
}
