// LevelRunner.js — Handles level select → planning → fight → results flow
// Ported from LevelRunner.pde

class LevelRunner {
  constructor() {
    this.finished    = false;
    this.state       = LevelRunnerTypes.select;
    this.level       = null;
    this.cam         = null;
    this.renderer    = null;
    this.projectiles = [];

    const cW = window.innerWidth, cH = window.innerHeight;

    // ── Select screen ──
    this.scrollSelect = new ScrollBar();
    const names       = Storage.listLevels();
    this.scrollSelect.fromNames(names, Math.floor(cH * 0.1));
    this._noLevels = names.length === 0;

    // ── Planning screen buttons ──
    const bh   = Math.floor(cH / 18);
    const bw   = Math.floor(cW * 0.3);
    this.btnFight = new Button(cW - bw - 10, cH - bh - 10, bw, bh, 'Fight!');

    // ── Back button ──
    const bh2 = Math.floor(cH / 20);
    const bw2 = Math.floor(cW * 0.15);
    this.btnBack = new Button(10, 10, bw2, bh2, '← Back');

    // ── Results ──
    this._resultMsg  = '';
    this._resultTimer = 0;
  }

  // ── Input ─────────────────────────────────────────────────────────────────
  onMouseDown(mx, my) {
    switch (this.state) {
      case LevelRunnerTypes.select:
        this.scrollSelect.open(my); break;
      case LevelRunnerTypes.planning:
      case LevelRunnerTypes.fight:
        this.cam.onMouseDown(mx, my); break;
    }
  }

  onMouseMove(mx, my, px, py, drag) {
    switch (this.state) {
      case LevelRunnerTypes.select:
        if (drag) this.scrollSelect.update(my - py); break;
      case LevelRunnerTypes.planning:
      case LevelRunnerTypes.fight:
        this.cam.onMouseMove(mx, my, px, py, drag); break;
    }
  }

  onMouseUp(mx, my) {
    switch (this.state) {
      case LevelRunnerTypes.select:
        this.scrollSelect.onMouseUp(mx, my);
        this.btnBack.onMouseUp(mx, my);
        if (this.btnBack.pressed) { this.btnBack.reset(); this.finished = true; break; }
        this._checkSelectBtn(); break;
      case LevelRunnerTypes.planning:
        this.btnFight.onMouseUp(mx, my);
        this.btnBack.onMouseUp(mx, my);
        if (this.btnBack.pressed) { this.btnBack.reset(); this.finished = true; break; }
        if (!this._checkPlanningBtns()) this.cam.onMouseUp(mx, my);
        break;
      case LevelRunnerTypes.fight:
        this.cam.onMouseUp(mx, my); break;
      case LevelRunnerTypes.results:
        this.finished = true; break;
    }
  }

  onBackPressed() { this.finished = true; }

  // ── Logic ─────────────────────────────────────────────────────────────────
  _checkSelectBtn() {
    const btn = this.scrollSelect.lastClickedBtn;
    if (!btn) return;
    this._loadLevel(btn.text);
  }

  _loadLevel(name) {
    this.level           = new LevelLoader();
    this.level.levelName = name;
    this.level.loadFromStorage();
    this.level.viewBarr = false;
    this.projectiles = [];

    const cW = window.innerWidth, cH = window.innerHeight;
    this.cam = new Camera(this.level.getWidth(), this.level.getHeight());
    this.cam.init(cW, cH);
    this.cam.scaleMin = Math.min(cW / this.level.getWidth(), cH / this.level.getHeight());
    this.cam.scale    = this.cam.scaleMin;
    this.renderer = new Renderer(this.level.getHeight());
    this.state    = LevelRunnerTypes.planning;
  }

  _checkPlanningBtns() {
    if (!this.btnFight.pressed) return false;
    this.btnFight.reset();
    const cW = window.innerWidth, cH = window.innerHeight;

    // Start all units marching
    for (const u of this.level.attackers) {
      u.setState(States.attack);
      u.primaryTarget = { x: this.level.getWidth()/2, y: this.level.getHeight()*0.25 };
      u.target        = { ...u.primaryTarget };
    }
    for (const u of this.level.defenders) {
      u.setState(States.attack);
      u.primaryTarget = { x: this.level.getWidth()/2, y: this.level.getHeight()*0.75 };
      u.target        = { ...u.primaryTarget };
    }
    // Arm ranged units
    for (const u of this.level.attackers)
      if (u.unitType === 'BasicArcher') u.setRanged(true, this.projectiles);
    for (const u of this.level.defenders)
      if (u.unitType === 'BasicArcher') u.setRanged(true, this.projectiles);

    // Build pathfinder from barrier layout
    this._pathfinder = new Pathfinder(
      this.level.gridCols, this.level.gridRows, this.level.blockSz, this.level.barrs
    );
    this._pathTick = 0;
    // Compute initial paths toward primary targets
    for (const u of this.level.attackers) {
      u._navPath   = this._pathfinder.findPath(u.position, u.primaryTarget);
      u._navTarget = { ...u.primaryTarget };
    }
    for (const u of this.level.defenders) {
      u._navPath   = this._pathfinder.findPath(u.position, u.primaryTarget);
      u._navTarget = { ...u.primaryTarget };
    }

    this.state = LevelRunnerTypes.fight;
    return true;
  }

  _refreshPaths(units) {
    for (const u of units) {
      if (!u.alive) continue;
      const navTarget = (u.enemyAttacking && u.enemyAttacking.alive)
        ? u.enemyAttacking.position : u.primaryTarget;
      const prev = u._navTarget;
      if (!prev || Math.hypot(navTarget.x - prev.x, navTarget.y - prev.y) > this.level.blockSz * 2) {
        u._navPath   = this._pathfinder.findPath(u.position, navTarget);
        u._navTarget = { ...navTarget };
      }
    }
  }

  _updateFight() {
    // Target finding
    for (const u of this.level.attackers) u.findNearestEnemy(this.level.defenders);
    for (const u of this.level.defenders) u.findNearestEnemy(this.level.attackers);

    // Refresh A* nav paths every 30 frames
    this._pathTick++;
    if (this._pathTick % 30 === 0) {
      this._refreshPaths(this.level.attackers);
      this._refreshPaths(this.level.defenders);
    }

    // Unit updates
    const walls = this.level.barrs;
    for (const u of this.level.attackers)
      u.updateUnit(this.level.attackers, this.level.defenders, u._navPath || null, walls);
    for (const u of this.level.defenders)
      u.updateUnit(this.level.defenders, this.level.attackers, u._navPath || null, walls);

    // Projectiles
    for (let i = this.projectiles.length - 1; i >= 0; i--) {
      const p = this.projectiles[i];
      p.update();
      p.attackUnits();
      if (p.finished) this.projectiles.splice(i, 1);
    }

    // Clamp units to map bounds
    const mw = this.level.getWidth(), mh = this.level.getHeight();
    for (const u of this.level.attackers) if (u.alive) {
      u.position.x = Math.max(u.r, Math.min(mw - u.r, u.position.x));
      u.position.y = Math.max(u.r, Math.min(mh - u.r, u.position.y));
    }
    for (const u of this.level.defenders) if (u.alive) {
      u.position.x = Math.max(u.r, Math.min(mw - u.r, u.position.x));
      u.position.y = Math.max(u.r, Math.min(mh - u.r, u.position.y));
    }

    // Alive checks
    for (const u of this.level.attackers) u.stillAlive();
    for (const u of this.level.defenders) u.stillAlive();

    // Win / loss detection
    const atkAlive = this.level.attackers.some(u => u.alive);
    const defAlive = this.level.defenders.some(u => u.alive);
    if (!atkAlive || !defAlive) {
      this._resultMsg   = !atkAlive ? 'Defenders win!' : 'Attackers win!';
      this._resultTimer = 180; // frames to show result
      this.state        = LevelRunnerTypes.results;
    }
  }

  // ── Draw ──────────────────────────────────────────────────────────────────
  draw(ctx) {
    switch (this.state) {
      case LevelRunnerTypes.select:
        if (this._noLevels) {
          ctx.fillStyle = '#fff';
          ctx.font      = 'bold 24px monospace';
          ctx.textAlign = 'center';
          ctx.fillText('No levels saved yet.', window.innerWidth/2, window.innerHeight/2);
          ctx.fillText('Create one in the Editor!', window.innerWidth/2, window.innerHeight/2 + 40);
        } else {
          this.scrollSelect.draw(ctx);
        }
        this.btnBack.draw(ctx);
        break;

      case LevelRunnerTypes.planning:
        this._drawLevel(ctx);
        this.btnFight.draw(ctx);
        this.btnBack.draw(ctx);
        break;

      case LevelRunnerTypes.fight:
        this._updateFight();
        this._drawLevel(ctx);
        break;

      case LevelRunnerTypes.results:
        this._drawLevel(ctx);
        this._drawResults(ctx);
        if (--this._resultTimer <= 0) this.finished = true;
        break;
    }
  }

  _drawLevel(ctx) {
    ctx.fillStyle = '#111';
    ctx.fillRect(0, 0, window.innerWidth, window.innerHeight);
    this.cam.push(ctx);
    this.level.draw(ctx);
    // Draw projectiles
    for (const p of this.projectiles) p.draw(ctx);
    this.cam.pop(ctx);
  }

  _drawResults(ctx) {
    const cW = window.innerWidth, cH = window.innerHeight;
    ctx.fillStyle = 'rgba(0,0,0,0.55)';
    ctx.fillRect(0, 0, cW, cH);
    ctx.fillStyle    = '#fff';
    ctx.font         = `bold ${Math.floor(cH * 0.08)}px monospace`;
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this._resultMsg, cW/2, cH/2);
    ctx.font = `${Math.floor(cH * 0.04)}px monospace`;
    ctx.fillText('Tap to continue', cW/2, cH/2 + cH * 0.12);
  }
}
