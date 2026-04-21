// LevelLoader.js — Level data container: tiles, objects, barriers, units
// Ported from LevelLoader.pde  (CSV → JSON, Android file I/O → localStorage)

class LevelLoader extends Level {
  constructor(cols, rows) {
    super();
    if (cols) this.gridCols = cols;
    if (rows) this.gridRows = rows;

    this.levelName   = '';
    this.renderer    = new Renderer(this.getHeight());

    this.ground      = null;   // LoadTile for painting backgrounds
    this.backgr      = null;   // OffscreenCanvas — pre-rendered tile layer
    this.bckgs       = [];     // flat array indexed [x + y*cols]
    this.objs        = [];     // TileObject[]
    this.barrs       = [];     // Barrier[]
    this.attackers   = [];     // SoldierBasic[]
    this.defenders   = [];     // SoldierBasic[]

    this.viewBck     = true;
    this.viewObj     = true;
    this.viewBarr    = true;
    this.viewUnit    = true;

    this.moving      = true;
    this.adding      = false;
    this.selectedObj = null;
    this.unitName    = Defs.units[0];

    this._drawGrid();
  }

  // ── Initialisation ────────────────────────────────────────────────────────
  _drawGrid() {
    const w = this.getWidth(), h = this.getHeight();
    this.backgr     = new OffscreenCanvas(w, h);
    const ctx       = this.backgr.getContext('2d');
    ctx.fillStyle   = '#111';
    ctx.fillRect(0, 0, w, h);
    this.bckgs      = new Array(this.gridCols * this.gridRows).fill(null);
  }

  _bckIdx(x, y) { return x + y * this.gridCols; }

  // ── Ground tile loading ───────────────────────────────────────────────────
  loadGround(name) {
    this.ground = new LoadTile(`${Storage.dataDirBacks}/${name}`, 16);
    return true;
  }

  // Pre-render all tiles onto the background OffscreenCanvas
  drawTiles() {
    if (!this.ground || !this.ground.loaded) return;
    const s   = this.ground.getTileSide();
    const ctx = this.backgr.getContext('2d');
    for (let i = 0; i < this.ground.xNum; i++)
      for (let j = 0; j < this.ground.yNum; j++) {
        const tile = this.ground.getTile(i, j);
        if (tile) ctx.drawImage(tile, i * s, j * s);
      }
  }

  fillGround(cam) {
    if (!this.ground || !this.ground.loaded) return;
    const tl = cam.screen2World(0, 0);
    const br = cam.screen2World(cam.offX * 2, cam.offY * 2);
    this._fillAreaBack(tl.x, tl.y, br.x, br.y);
  }

  _addBackgr(wx, wy) {
    const s  = this.blockSz;
    const gx = Math.floor(wx / s);
    const gy = Math.floor(wy / s);
    if (gx < 0 || gy < 0 || gx >= this.gridCols || gy >= this.gridRows) return;
    if (!this.ground || !this.ground.loaded) return;
    const tile = this.ground.getRandTile();
    if (!tile) return;
    const ctx = this.backgr.getContext('2d');
    ctx.drawImage(tile, gx * s, gy * s);
    this.bckgs[this._bckIdx(gx, gy)] = {
      pos: { x: gx, y: gy },
      tileName: this.ground.path.split('/').pop(),
      tilePos:  { x: this.ground.xLast, y: this.ground.yLast }
    };
  }

  _fillAreaBack(x1, y1, x2, y2) {
    const s   = this.blockSz;
    const sx  = Math.floor(Math.min(x1, x2) / s);
    const sy  = Math.floor(Math.min(y1, y2) / s);
    const ex  = Math.floor(Math.max(x1, x2) / s);
    const ey  = Math.floor(Math.max(y1, y2) / s);
    for (let i = sx; i <= ex; i++)
      for (let j = sy; j <= ey; j++)
        this._addBackgr(i * s, j * s);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  isSelected()  { return this.selectedObj !== null; }
  setAdding()   { this.moving = false; this.adding = true; }
  setMoving()   { this.moving = true;  this.adding = false; }
  setUnit(name) { this.unitName = name; }

  _fitGrid(v, grid) {
    return { x: Math.floor(v.x / grid) * grid,
             y: Math.floor(v.y / grid) * grid };
  }

  deleteSelected() {
    if (!this.selectedObj) return;
    this.selectedObj.delete();
    this.objs      = this.objs.filter(o => !o.reqDelete);
    this.barrs     = this.barrs.filter(o => !o.reqDelete);
    this.attackers = this.attackers.filter(o => !o.reqDelete);
    this.defenders = this.defenders.filter(o => !o.reqDelete);
    this.selectedObj = null;
  }

  _checkObjInPos(list, px, py) {
    for (const o of list) {
      if (o.posInside(px, py)) { this.selectedObj = o; return true; }
    }
    return false;
  }

  // ── Click handlers (called by Editor) ────────────────────────────────────
  clickBackgr(cam, selFinished, touchStart, touchEnd, mx, my) {
    const target = cam.screen2World(mx, my);
    if (selFinished && touchStart && touchEnd) {
      const s = cam.screen2World(touchStart.x, touchStart.y);
      const e = cam.screen2World(touchEnd.x,   touchEnd.y);
      this._fillAreaBack(s.x, s.y, e.x, e.y);
    } else {
      this._addBackgr(target.x, target.y);
    }
  }

  clickObjs(cam, tlPck, selFinished, touchStart, touchEnd, mx, my) {
    const target  = cam.screen2World(mx, my);
    const snapped = this._fitGrid(target, this.blockSz / 2);
    if (this._moveSelectedObj(cam, selFinished, touchStart, touchEnd)) return;
    if (this._checkObjInPos(this.objs, snapped.x, snapped.y)) return;
    if (!this.adding || !tlPck) return;
    const t = tlPck.getSelectedTileObject();
    if (!t) return;
    t.setLocation(snapped.x, snapped.y);
    this.objs.push(t);
  }

  clickBarr(cam, selFinished, touchStart, touchEnd, mx, my) {
    const target = cam.screen2World(mx, my);
    if (this._moveSelectedObj(cam, selFinished, touchStart, touchEnd)) return;
    if (this._checkObjInPos(this.barrs, target.x, target.y)) return;
    if (!this.adding || !selFinished) return;
    const s  = cam.screen2World(touchStart.x, touchStart.y);
    const e  = cam.screen2World(touchEnd.x,   touchEnd.y);
    const x  = Math.min(s.x, e.x), y = Math.min(s.y, e.y);
    const w  = Math.abs(e.x - s.x), h = Math.abs(e.y - s.y);
    this.barrs.push(new Barrier(x, y, w, h));
  }

  clickUnits(cam, selFinished, touchStart, touchEnd, mx, my, isAttacker) {
    const target = cam.screen2World(mx, my);
    const tx = Math.floor(target.x), ty = Math.floor(target.y);
    if (this._moveSelectedObj(cam, selFinished, touchStart, touchEnd, false)) return;
    if (this._checkObjInPos(this.attackers, tx, ty)) return;
    if (this._checkObjInPos(this.defenders, tx, ty)) return;
    if (!this.adding) return;
    const s = new SoldierBasic(tx, ty, this.unitName);
    s.setState(States.stand); s.dir = Dirs.RD;
    s.teamNum = isAttacker ? 0 : 1;
    if (isAttacker) this.attackers.push(s); else this.defenders.push(s);
  }

  _moveSelectedObj(cam, selFinished, touchStart, touchEnd, fitGrid = true) {
    if (!this.moving) return false;
    if (selFinished && this.selectedObj && touchStart && touchEnd) {
      let s = cam.screen2World(touchStart.x, touchStart.y);
      let e = cam.screen2World(touchEnd.x,   touchEnd.y);
      if (fitGrid) { s = this._fitGrid(s, this.blockSz/2); e = this._fitGrid(e, this.blockSz/2); }
      if (this.selectedObj.posInside(s.x, s.y)) {
        this.selectedObj.position.x += e.x - s.x;
        this.selectedObj.position.y += e.y - s.y;
      }
      return true;
    }
    return false;
  }

  // ── Draw ──────────────────────────────────────────────────────────────────
  update() {
    this.renderer.clear();
    if (this.viewUnit) {
      for (const s of this.attackers) { s.updateUnit(null,null,null,null); this.renderer.add(s); }
      for (const s of this.defenders) { s.updateUnit(null,null,null,null); this.renderer.add(s); }
    }
    if (this.viewObj)  for (const t of this.objs)  this.renderer.add(t);
  }

  draw(ctx) {
    if (this.viewBck)  ctx.drawImage(this.backgr, 0, 0);
    this.update();
    this.renderer.draw(ctx);
    if (this.viewBarr) for (const b of this.barrs) b.draw(ctx);
  }

  drawSelObj(ctx) {
    if (!this.selectedObj) return;
    const o  = this.selectedObj;
    const hw = o.size.x / 2, hh = o.size.y / 2;
    ctx.save();
    ctx.strokeStyle = 'rgba(30,250,30,0.9)';
    ctx.lineWidth   = 2;
    ctx.strokeRect(o.position.x - hw, o.position.y - hh, o.size.x, o.size.y);
    ctx.restore();
  }

  // ── Persistence (JSON) ────────────────────────────────────────────────────
  toJSON() {
    const rows = [];
    rows.push({ type: LevelLoaderTypes.map, x: this.gridCols, y: this.gridRows, param1: this.blockSz });

    for (let i = 0; i < this.gridCols; i++)
      for (let j = 0; j < this.gridRows; j++) {
        const bp = this.bckgs[this._bckIdx(i, j)];
        if (!bp) continue;
        rows.push({ type: LevelLoaderTypes.back, x: bp.pos.x, y: bp.pos.y,
                    file: bp.tileName, param1: bp.tilePos.x, param2: bp.tilePos.y });
      }

    for (const o of this.objs)
      rows.push({ type: LevelLoaderTypes.obj,
                  x: o.position.x, y: o.position.y, file: o.fileName,
                  param1: o.tilePos.x, param2: o.tilePos.y,
                  param3: o.size.x,   param4: o.size.y });

    for (const b of this.barrs)
      rows.push({ type: LevelLoaderTypes.barr,
                  x: b.position.x, y: b.position.y,
                  param1: b.size.x, param2: b.size.y });

    for (const s of this.attackers)
      rows.push({ type: LevelLoaderTypes.unit,
                  x: s.position.x, y: s.position.y, file: s.unitType, param1: 0 });

    for (const s of this.defenders)
      rows.push({ type: LevelLoaderTypes.unit,
                  x: s.position.x, y: s.position.y, file: s.unitType, param1: 1 });

    return rows;
  }

  save2Storage() {
    if (!this.levelName) return false;
    return Storage.saveLevel(this.levelName, this.toJSON());
  }

  clearLevelData() {
    this._drawGrid();
    this.objs = []; this.barrs = []; this.attackers = []; this.defenders = [];
    this.selectedObj = null;
  }

  loadFromStorage() {
    const rows = Storage.loadLevel(this.levelName);
    if (!rows) return false;
    this.clearLevelData();
    for (const row of rows) {
      switch (row.type) {
        case LevelLoaderTypes.map:
          this.gridCols = row.x; this.gridRows = row.y; this.blockSz = row.param1;
          this.bckgs    = new Array(this.gridCols * this.gridRows).fill(null);
          this._drawGrid(); break;

        case LevelLoaderTypes.back: {
          const s = this.blockSz;
          const gx = row.x, gy = row.y, px = row.param1, py = row.param2, file = row.file;
          const img = new Image();
          const apply = () => {
            const oc = new OffscreenCanvas(s, s);
            oc.getContext('2d').drawImage(img, px * s, py * s, s, s, 0, 0, s, s);
            this.backgr.getContext('2d').drawImage(oc, gx * s, gy * s);
            this.bckgs[this._bckIdx(gx, gy)] = {
              pos: { x: gx, y: gy }, tileName: file,
              tilePos: { x: px, y: py }
            };
          };
          img.src = file.includes('/') ? file : `${Storage.dataDirBacks}/${file}`;
          if (img.complete && img.naturalWidth > 0) apply();
          else img.onload = apply;
          break;
        }

        case LevelLoaderTypes.obj: {
          const to  = new TileObject(row.file, row.param1, row.param2, row.param3, row.param4);
          const img = new Image();
          img.src   = `${Storage.dataDirTiles}/${row.file}`;
          img.onload = () => to.loadTileImg(img);
          to.setLocation(row.x, row.y);
          this.objs.push(to); break;
        }

        case LevelLoaderTypes.barr:
          this.barrs.push(new Barrier(row.x - row.param1/2, row.y - row.param2/2,
                                      row.param1, row.param2)); break;

        case LevelLoaderTypes.unit: {
          const s = new SoldierBasic(row.x, row.y, row.file);
          s.setState(States.stand); s.dir = Dirs.RD; s.teamNum = row.param1;
          if (row.param1 === 0) this.attackers.push(s); else this.defenders.push(s);
          break;
        }
      }
    }
    return true;
  }
}
