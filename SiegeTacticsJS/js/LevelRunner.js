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

    // ── Planning tool state ──
    this._planMode      = 'select';  // 'select' | 'track'
    this._selectedUnits = [];
    this._drawingPath   = false;
    this._pathPoints    = [];        // world-space points accumulated during drag
    this._selRectStart  = null;      // screen-space drag start for rubber-band selection
    this._selRectCurr   = null;      // screen-space current pointer position

    // ── Planning tool buttons ──
    const bh3 = Math.floor(cH / 18);
    const bw3 = Math.floor(cW * 0.15);
    this.btnPlanSelect = new Button(10,            cH - bh3 - 10, bw3, bh3, 'Select');
    this.btnPlanTrack  = new Button(10 + bw3 + 8,  cH - bh3 - 10, bw3, bh3, 'Track');
    this.btnPlanSelect.setChecked(true);
  }

  // ── Input ─────────────────────────────────────────────────────────────────
  onMouseDown(mx, my) {
    switch (this.state) {
      case LevelRunnerTypes.select:
        this.scrollSelect.open(my); break;
      case LevelRunnerTypes.planning:
        if (this._planMode === 'track') {
          const w = this.cam.screen2World(mx, my);
          this._drawingPath = true;
          this._pathPoints  = [{ x: w.x, y: w.y }];
        } else {
          this._selRectStart = { x: mx, y: my };
          this._selRectCurr  = { x: mx, y: my };
        }
        break;
      case LevelRunnerTypes.fight:
        this.cam.onMouseDown(mx, my); break;
    }
  }

  onMouseMove(mx, my, px, py, drag) {
    switch (this.state) {
      case LevelRunnerTypes.select:
        if (drag) this.scrollSelect.update(my - py); break;
      case LevelRunnerTypes.planning:
        if (this._planMode === 'track' && this._drawingPath) {
          const w    = this.cam.screen2World(mx, my);
          const last = this._pathPoints[this._pathPoints.length - 1];
          if (Math.hypot(w.x - last.x, w.y - last.y) > 20)
            this._pathPoints.push({ x: w.x, y: w.y });
        } else if (this._planMode === 'select') {
          this._selRectCurr = { x: mx, y: my };
        }
        break;
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

      case LevelRunnerTypes.planning: {
        // Check all buttons first
        this.btnPlanSelect.onMouseUp(mx, my);
        this.btnPlanTrack.onMouseUp(mx, my);
        this.btnFight.onMouseUp(mx, my);
        this.btnBack.onMouseUp(mx, my);

        if (this.btnPlanSelect.pressed) {
          this.btnPlanSelect.reset();
          if (this._planMode === 'select') this._selectedUnits = [];  // re-click = deselect all
          else this._setPlanMode('select');
          break;
        }
        if (this.btnPlanTrack.pressed) {
          this.btnPlanTrack.reset();
          this._setPlanMode('track');
          break;
        }
        if (this.btnBack.pressed) { this.btnBack.reset(); this.finished = true; break; }
        if (this._checkPlanningBtns()) break;

        // Mode-specific pointer action
        if (this._planMode === 'track' && this._drawingPath) {
          this._drawingPath = false;
          if (this._pathPoints.length >= 2 && this._selectedUnits.length > 0) {
            const path = new Path(8, '#f97316');
            for (let k = 0; k < this._pathPoints.length - 1; k++) {
              path.addPoint(this._pathPoints[k].x,     this._pathPoints[k].y);
              path.addPoint(this._pathPoints[k + 1].x, this._pathPoints[k + 1].y);
            }
            for (const u of this._selectedUnits) u._playerPath = path;
          }
        } else if (this._planMode === 'select' && this._selRectStart) {
          // Add every unit inside the rubber-band rect to the selection
          const x1 = Math.min(this._selRectStart.x, mx);
          const y1 = Math.min(this._selRectStart.y, my);
          const x2 = Math.max(this._selRectStart.x, mx);
          const y2 = Math.max(this._selRectStart.y, my);
          const wMin = this.cam.screen2World(x1, y1);
          const wMax = this.cam.screen2World(x2, y2);
          for (const u of [...this.level.attackers, ...this.level.defenders]) {
            if (u.position.x >= wMin.x && u.position.x <= wMax.x &&
                u.position.y >= wMin.y && u.position.y <= wMax.y &&
                !this._selectedUnits.includes(u)) {
              this._selectedUnits.push(u);
            }
          }
          this._selRectStart = null;
          this._selRectCurr  = null;
        }
        break;
      }

      case LevelRunnerTypes.fight:
        this.cam.onMouseUp(mx, my); break;
      case LevelRunnerTypes.results:
        this.finished = true; break;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  _findUnitAt(wx, wy) {
    for (const u of [...this.level.attackers, ...this.level.defenders]) {
      if (Math.hypot(u.position.x - wx, u.position.y - wy) < u.r * 3) return u;
    }
    return null;
  }

  _setPlanMode(mode) {
    this._planMode = mode;
    this._drawingPath = false;
    this._pathPoints  = [];
    this.btnPlanSelect.setChecked(mode === 'select');
    this.btnPlanTrack.setChecked(mode === 'track');
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
    // Compute initial paths toward primary targets (use player path when available)
    for (const u of this.level.attackers)  this._initNavPath(u);
    for (const u of this.level.defenders)  this._initNavPath(u);

    this.state = LevelRunnerTypes.fight;
    return true;
  }

  _initNavPath(u) {
    if (u._playerPath) {
      // Use last waypoint of player path as primary target
      const pts = u._playerPath.points;
      const last = pts[pts.length - 1];
      u.primaryTarget = { x: last.x, y: last.y };
      u.target        = { ...u.primaryTarget };
      u._navPath      = u._playerPath;
      u._navTarget    = { ...u.primaryTarget };
    } else {
      u._navPath   = this._pathfinder.findPath(u.position, u.primaryTarget);
      u._navTarget = { ...u.primaryTarget };
    }
  }

  _refreshPaths(units) {
    for (const u of units) {
      if (!u.alive) continue;
      if (u._playerPath) {
        // Keep following player-drawn path; enemy engagement handled by applySeek
        u._navPath = u._playerPath;
        continue;
      }
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
        this.btnPlanSelect.draw(ctx);
        this.btnPlanTrack.draw(ctx);
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

    // Draw player-assigned paths (planning + fight)
    for (const u of [...this.level.attackers, ...this.level.defenders]) {
      if (u._playerPath) u._playerPath.drawPlayerPath(ctx);
    }

    // Live path preview while drawing
    if (this._drawingPath && this._pathPoints.length >= 2) {
      ctx.save();
      ctx.strokeStyle = '#f97316';
      ctx.lineWidth   = 2;
      ctx.globalAlpha = 0.6;
      ctx.lineCap     = 'round';
      ctx.lineJoin    = 'round';
      ctx.setLineDash([6, 4]);
      ctx.beginPath();
      ctx.moveTo(this._pathPoints[0].x, this._pathPoints[0].y);
      for (let i = 1; i < this._pathPoints.length; i++)
        ctx.lineTo(this._pathPoints[i].x, this._pathPoints[i].y);
      ctx.stroke();
      ctx.restore();
    }

    // Selection rings around all selected units
    if (this.state === LevelRunnerTypes.planning && this._selectedUnits.length > 0) {
      ctx.save();
      ctx.strokeStyle = '#22c55e';
      ctx.lineWidth   = 2;
      ctx.globalAlpha = 0.9;
      ctx.setLineDash([4, 4]);
      for (const u of this._selectedUnits) {
        ctx.beginPath();
        ctx.arc(u.position.x, u.position.y, u.r * 2.2, 0, Math.PI * 2);
        ctx.stroke();
      }
      ctx.restore();
    }

    // Draw projectiles
    for (const p of this.projectiles) p.draw(ctx);
    this.cam.pop(ctx);

    // Rubber-band selection rect (screen space — drawn after pop)
    if (this.state === LevelRunnerTypes.planning &&
        this._planMode === 'select' &&
        this._selRectStart && this._selRectCurr) {
      const sx = Math.min(this._selRectStart.x, this._selRectCurr.x);
      const sy = Math.min(this._selRectStart.y, this._selRectCurr.y);
      const sw = Math.abs(this._selRectCurr.x - this._selRectStart.x);
      const sh = Math.abs(this._selRectCurr.y - this._selRectStart.y);
      ctx.save();
      ctx.strokeStyle = '#facc15';
      ctx.lineWidth   = 1.5;
      ctx.globalAlpha = 0.9;
      ctx.setLineDash([]);
      ctx.strokeRect(sx, sy, sw, sh);
      ctx.fillStyle   = '#facc15';
      ctx.globalAlpha = 0.08;
      ctx.fillRect(sx, sy, sw, sh);
      ctx.restore();
    }
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
