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

  // Draw a player-assigned path: solid line with directional arrowheads
  drawPlayerPath(ctx) {
    if (this.points.length < 2) return;
    // Pairs format → sequential unique waypoints
    const seq = [this.points[0]];
    for (let i = 1; i < this.points.length; i += 2) seq.push(this.points[i]);

    ctx.save();
    ctx.strokeStyle = this.color;
    ctx.fillStyle   = this.color;
    ctx.lineWidth   = 2.5;
    ctx.globalAlpha = 0.85;
    ctx.lineCap     = 'round';
    ctx.lineJoin    = 'round';

    ctx.beginPath();
    ctx.moveTo(seq[0].x, seq[0].y);
    for (let i = 1; i < seq.length; i++) ctx.lineTo(seq[i].x, seq[i].y);
    ctx.stroke();

    // Arrowhead at 60% along each segment (skip very short ones)
    for (let i = 0; i < seq.length - 1; i++) {
      const a = seq[i], b = seq[i + 1];
      if (Math.hypot(b.x - a.x, b.y - a.y) < 20) continue;
      const t   = 0.6;
      const mx  = a.x + (b.x - a.x) * t;
      const my  = a.y + (b.y - a.y) * t;
      const ang = Math.atan2(b.y - a.y, b.x - a.x);
      const hs  = 7;
      ctx.beginPath();
      ctx.moveTo(mx + Math.cos(ang)       * hs,       my + Math.sin(ang)       * hs);
      ctx.lineTo(mx + Math.cos(ang + 2.4) * hs * 0.6, my + Math.sin(ang + 2.4) * hs * 0.6);
      ctx.lineTo(mx + Math.cos(ang - 2.4) * hs * 0.6, my + Math.sin(ang - 2.4) * hs * 0.6);
      ctx.closePath();
      ctx.fill();
    }

    // Endpoint marker
    const last = seq[seq.length - 1];
    ctx.beginPath();
    ctx.arc(last.x, last.y, 5, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }
}
