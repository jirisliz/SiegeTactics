// Vehicle.js — Craig Reynolds steering behaviours
// Ported from Vehicle.pde  (Nature of Code – Daniel Shiffman)

class Vehicle extends GameObject {
  constructor(x = 0, y = 0, maxSpeed = 2, maxForce = 0.1) {
    super();
    this.position     = { x, y };
    this.velocity     = { x: 0, y: 0 };
    this.acceleration = { x: 0, y: 0 };
    this.r            = 8;
    this.maxSpeed     = maxSpeed;
    this.maxForce     = maxForce;
    this.mass         = 1.8;
    this.target        = null;
    this.primaryTarget = null;
  }

  // ── Vector helpers ────────────────────────────────────────────────────────
  _len(v)         { return Math.hypot(v.x, v.y); }
  _norm(v)        { const l = this._len(v) || 1; return { x: v.x / l, y: v.y / l }; }
  _scale(v, s)    { return { x: v.x * s, y: v.y * s }; }
  _add(a, b)      { return { x: a.x + b.x, y: a.y + b.y }; }
  _sub(a, b)      { return { x: a.x - b.x, y: a.y - b.y }; }
  _dot(a, b)      { return a.x * b.x + a.y * b.y; }
  _dist(a, b)     { return Math.hypot(b.x - a.x, b.y - a.y); }
  _heading(v)     { return Math.atan2(v.y, v.x); }
  _limit(v, max)  { const l = this._len(v); return l > max ? this._scale(v, max / l) : { ...v }; }
  _copy(v)        { return { x: v.x, y: v.y }; }

  // ── Core forces ───────────────────────────────────────────────────────────
  applyForce(f) {
    this.acceleration.x += f.x / this.mass;
    this.acceleration.y += f.y / this.mass;
  }

  seek(target) {
    const desired = this._norm(this._sub(target, this.position));
    const d = this._scale(desired, this.maxSpeed);
    const steer = this._sub(d, this.velocity);
    return this._limit(steer, this.maxForce);
  }

  applySeek() {
    if (!this.target) return;
    this.applyForce(this.seek(this.target));
  }

  // ── Path following (Reynolds algorithm) ──────────────────────────────────
  follow(path) {
    if (!path || path.points.length < 2) return { x: 0, y: 0 };

    const predict = this._scale(this._norm(this.velocity), 25);
    const predPos = this._add(this.position, predict);

    let normal = null, target = null, best = 1e9;

    for (let i = 0; i < path.points.length - 1; i += 2) {
      const a = path.points[i];
      const b = path.points[i + 1];
      let np  = this._normalPoint(predPos, a, b);

      // If normal is outside segment, snap to end point
      if (np.x < Math.min(a.x, b.x) || np.x > Math.max(a.x, b.x) ||
          np.y < Math.min(a.y, b.y) || np.y > Math.max(a.y, b.y)) {
        np = this._copy(b);
      }

      const d = this._dist(predPos, np);
      if (d < best) {
        best   = d;
        normal = np;
        const dir = this._scale(this._norm(this._sub(b, a)), 25);
        target    = this._add(np, dir);
      }
    }

    if (normal && best > path.radius) return this.seek(target);
    return { x: 0, y: 0 };
  }

  _normalPoint(p, a, b) {
    const ap  = this._sub(p, a);
    const ab  = this._norm(this._sub(b, a));
    const proj = this._scale(ab, this._dot(ap, ab));
    return this._add(a, proj);
  }

  // ── Separation — circular agents ─────────────────────────────────────────
  separateCirc(agents) {
    if (!agents) return { x: 0, y: 0 };
    const desired = this.r * 2;
    let steer = { x: 0, y: 0 }, count = 0;
    for (const other of agents) {
      if (!other.active) continue;
      const d = this._dist(this.position, other.position);
      if (d > 0 && d < desired) {
        const diff = this._scale(this._norm(this._sub(this.position, other.position)), 1 / d);
        steer = this._add(steer, diff);
        count++;
      }
    }
    return this._finishSeparation(steer, count);
  }

  // ── Separation — rectangular walls ───────────────────────────────────────
  separateRect(walls) {
    if (!walls) return { x: 0, y: 0 };
    let steer = { x: 0, y: 0 }, count = 0;
    for (const wall of walls) {
      if (!wall.active) continue;
      if (wall.intersectsVehicle(this)) {
        const wallCentre = wall.centre();
        const diff = this._scale(this._norm(this._sub(this.position, wallCentre)), 1 / (this.r * 2));
        steer = this._add(steer, diff);
        count++;
      }
    }
    return this._finishSeparation(steer, count);
  }

  _finishSeparation(steer, count) {
    if (count > 0) { steer.x /= count; steer.y /= count; }
    if (this._len(steer) > 0) {
      const s = this._scale(this._norm(steer), this.maxSpeed);
      steer   = this._limit(this._sub(s, this.velocity), this.maxForce);
    }
    return steer;
  }

  applyFollow(path) {
    if (!path) return;
    const f = this.follow(path);
    this.applyForce(this._scale(f, 2));
  }

  applySeparationCirc(agents) {
    if (!agents) return;
    this.applyForce(this._scale(this.separateCirc(agents), 2));
  }

  applySeparationRect(walls) {
    if (!walls) return;
    this.applyForce(this._scale(this.separateRect(walls), 4));
  }

  // ── Physics update ────────────────────────────────────────────────────────
  update() {
    this.velocity     = this._limit(this._add(this.velocity, this.acceleration), this.maxSpeed);
    this.position.x  += this.velocity.x;
    this.position.y  += this.velocity.y;
    this.acceleration = { x: 0, y: 0 };
  }

  borders(canvasW) {
    if (this.position.x < -this.r) this.position.x = canvasW + this.r;
    if (this.position.x > canvasW + this.r) this.position.x = -this.r;
  }
}
