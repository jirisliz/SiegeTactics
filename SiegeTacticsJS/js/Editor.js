// Editor.js — Level editor (tile painting, unit/object/barrier placement)
// Ported from Creator.pde

class Editor {
  constructor() {
    this.finished  = false;
    this.state     = CreatorStates.menu;
    this._prevState = CreatorStates.menu;

    const cW = window.innerWidth, cH = window.innerHeight;
    const bh = Math.floor(cH / 13);
    const bw = Math.floor(cW / 2);
    const bx = Math.floor(cW / 4);

    // ── Menu buttons ──
    this.btnNew    = new Button(bx, Math.floor(cH * 7/10), bw, bh, 'New map');
    this.btnOpen   = new Button(bx, Math.floor(cH * 8/10), bw, bh, 'Open map');
    this.btnBack   = new Button(bx, Math.floor(cH * 9/10), bw, bh, 'Back');

    // ── Creator toolbar ──
    const D  = 31;
    const bsH = Math.floor(cH / D);
    const bsW = Math.floor(cW * 3 / 8);
    const bsX = Math.floor(cW / 8);
    const smW = Math.floor(cW / 8) - 2;
    const smX = 2;
    const rX  = Math.floor(cW * 7/8) - smW;
    const r2X = Math.floor(cW * 5/8) - smW;

    this.btnBck    = new Button(bsX, cH*(D-4)/D, bsW, bsH, 'Background'); this.btnBck.setChecked(true);
    this.btnObj    = new Button(bsX, cH*(D-3)/D, bsW, bsH, 'Objects');
    this.btnBarr   = new Button(bsX, cH*(D-2)/D, bsW, bsH, 'Barriers');
    this.btnUnit   = new Button(bsX, cH*(D-1)/D, bsW, bsH, 'Units');

    this.btnBckV   = new Button(smX, cH*(D-4)/D, smW, bsH, 'Hide'); this.btnBckV.setChecked(true);
    this.btnObjV   = new Button(smX, cH*(D-3)/D, smW, bsH, 'Hide'); this.btnObjV.setChecked(true);
    this.btnBarrV  = new Button(smX, cH*(D-2)/D, smW, bsH, 'Hide'); this.btnBarrV.setChecked(true);
    this.btnUnitV  = new Button(smX, cH*(D-1)/D, smW, bsH, 'Hide'); this.btnUnitV.setChecked(true);

    this.btnLoad   = new Button(rX,  cH*(D-3)/D, smW, bsH, 'Load');
    this.btnAdd    = new Button(rX,  cH*(D-2)/D, smW, bsH, 'Add');
    this.btnDel    = new Button(r2X, cH*(D-3)/D, smW, bsH, 'Del');
    this.btnMove   = new Button(r2X, cH*(D-2)/D, smW, bsH, 'Move'); this.btnMove.setChecked(true);

    this.btnAttacker = new Button(rX,  cH*(D-1)/D, Math.floor(cW/6), bsH, 'Attacker');
    this.btnDefender = new Button(r2X, cH*(D-1)/D, Math.floor(cW/6), bsH, 'Defender');
    this.btnAttacker.setChecked(true);
    this.btnAttacker.visible = false;
    this.btnDefender.visible = false;

    this.btnSave        = new Button(rX,  cH*(D-4)/D, smW, bsH, 'Save');
    this.btnGrid        = new Button(r2X, cH*(D-4)/D, smW, bsH, 'Grid');
    this.btnCreatorBack = new Button(4,   4,           smW, bsH, '← Back');
    this.btnSelectBack  = new Button(bsX, cH*(D-1)/D, bsW, bsH, '← Back');

    this._creatorBtns = [this.btnBck, this.btnObj, this.btnBarr, this.btnUnit,
                         this.btnBckV,this.btnObjV,this.btnBarrV,this.btnUnitV,
                         this.btnLoad,this.btnAdd, this.btnDel,  this.btnMove,
                         this.btnAttacker, this.btnDefender,
                         this.btnSave, this.btnGrid, this.btnCreatorBack];

    // ── Level & camera ──
    this.level       = new LevelLoader();
    this.cam         = new Camera(this.level.getWidth(), this.level.getHeight());
    this.cam.init(cW, cH);
    this.cam.scaleMin = Math.min(cW / this.level.getWidth(), cH / this.level.getHeight());
    this.cam.scale    = this.cam.scaleMin;
    this.cam.selEnabled = true;

    this.levelLoaded  = false;
    this.scrollSelect = null;
    this.tlPck        = null;
    this._showGrid    = false;
    this._smW         = smW;
    this._bsH         = bsH;

    // ── Name dialog (HTML overlay) ──
    this._nameDialog   = null;
    this._nameResolve  = null;
    this._dlgIsNewMap  = false;
    this._buildDialog();
  }

  // ── HTML name-input dialog ────────────────────────────────────────────────
  _buildDialog() {
    const dlg          = document.createElement('div');
    dlg.id             = 'nameDialog';
    dlg.style.cssText  = `display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);
      z-index:100;display:none;align-items:center;justify-content:center;`;
    dlg.innerHTML      = `
      <div style="background:#222;padding:28px 32px;border-radius:14px;min-width:300px;text-align:center">
        <p id="dlgMsg" style="color:#ddd;font:bold 18px monospace;margin:0 0 14px"></p>
        <input id="dlgInput" type="text"
          style="width:100%;padding:8px 10px;font:16px monospace;border-radius:8px;border:none;outline:none;background:#111;color:#eee"/>
        <div id="dlgSizeGroup" style="display:none;margin-top:12px;gap:10px;align-items:center;justify-content:center;flex-wrap:wrap">
          <label style="color:#aaa;font:13px monospace">Cols:</label>
          <input id="dlgCols" type="number" min="4" max="64" value="16"
            style="width:60px;padding:6px 8px;font:14px monospace;border-radius:6px;border:none;background:#111;color:#eee;text-align:center"/>
          <label style="color:#aaa;font:13px monospace">Rows:</label>
          <input id="dlgRows" type="number" min="4" max="128" value="32"
            style="width:60px;padding:6px 8px;font:14px monospace;border-radius:6px;border:none;background:#111;color:#eee;text-align:center"/>
        </div>
        <div style="margin-top:16px;display:flex;gap:10px;justify-content:center">
          <button id="dlgOk"     style="padding:8px 22px;border-radius:8px;border:none;background:#4a7;color:#fff;font:bold 15px monospace;cursor:pointer">OK</button>
          <button id="dlgCancel" style="padding:8px 22px;border-radius:8px;border:none;background:#555;color:#fff;font:bold 15px monospace;cursor:pointer">Cancel</button>
        </div>
      </div>`;
    document.body.appendChild(dlg);
    this._nameDialog = dlg;
    document.getElementById('dlgOk').onclick     = () => this._dlgConfirm();
    document.getElementById('dlgCancel').onclick  = () => this._dlgCancel();
    document.getElementById('dlgInput').onkeydown = e => { if (e.key === 'Enter') this._dlgConfirm(); };
  }

  _showDialog(msg, defaultVal = '') {
    return new Promise(resolve => {
      document.getElementById('dlgMsg').textContent   = msg;
      document.getElementById('dlgInput').value       = defaultVal;
      this._nameDialog.style.display = 'flex';
      document.getElementById('dlgInput').focus();
      this._nameResolve = resolve;
    });
  }

  _showNewMapDialog() {
    return new Promise(resolve => {
      document.getElementById('dlgMsg').textContent = 'New map name:';
      document.getElementById('dlgInput').value = '';
      document.getElementById('dlgCols').value  = '16';
      document.getElementById('dlgRows').value  = '32';
      document.getElementById('dlgSizeGroup').style.display = 'flex';
      this._nameDialog.style.display = 'flex';
      document.getElementById('dlgInput').focus();
      this._nameResolve = resolve;
      this._dlgIsNewMap = true;
    });
  }

  _dlgConfirm() {
    const val = document.getElementById('dlgInput').value.trim();
    document.getElementById('dlgSizeGroup').style.display = 'none';
    this._nameDialog.style.display = 'none';
    if (this._nameResolve) {
      if (this._dlgIsNewMap) {
        const cols = Math.max(4, Math.min(64,  parseInt(document.getElementById('dlgCols').value, 10) || 16));
        const rows = Math.max(4, Math.min(128, parseInt(document.getElementById('dlgRows').value, 10) || 32));
        this._nameResolve(val ? { name: val, cols, rows } : null);
      } else {
        this._nameResolve(val || null);
      }
      this._nameResolve = null;
      this._dlgIsNewMap = false;
    }
  }

  _dlgCancel() {
    document.getElementById('dlgSizeGroup').style.display = 'none';
    this._nameDialog.style.display = 'none';
    if (this._nameResolve) { this._nameResolve(null); this._nameResolve = null; }
    this._dlgIsNewMap = false;
  }

  // ── Input ─────────────────────────────────────────────────────────────────
  onMouseDown(mx, my) {
    switch (this.state) {
      case CreatorStates.select:
        this.scrollSelect.open(my); break;
      case CreatorStates.creator:
        this.cam.onMouseDown(mx, my); break;
      case CreatorStates.tilePicker:
        this.tlPck.onMouseDown(mx, my); break;
    }
  }

  onMouseMove(mx, my, px, py, drag) {
    switch (this.state) {
      case CreatorStates.select:
        if (drag) this.scrollSelect.update(my - py); break;
      case CreatorStates.creator:
        this.cam.onMouseMove(mx, my, px, py, drag); break;
      case CreatorStates.tilePicker:
        this.tlPck.onMouseMove(mx, my, px, py, drag); break;
    }
  }

  onMouseUp(mx, my) {
    switch (this.state) {
      case CreatorStates.menu:
        this.btnNew.onMouseUp(mx, my);
        this.btnOpen.onMouseUp(mx, my);
        this.btnBack.onMouseUp(mx, my);
        this._checkMenuBtns(); break;

      case CreatorStates.select:
        this.scrollSelect.onMouseUp(mx, my);
        this.btnSelectBack.onMouseUp(mx, my);
        this._checkSelectBtns(); break;

      case CreatorStates.creator: {
        for (const b of this._creatorBtns) b.onMouseUp(mx, my);
        const consumed = this._checkCreatorBtns();
        if (!consumed) {
          this.cam.onMouseUp(mx, my);
          const sf = this.cam.selFinished;
          const ts = this.cam.touchStart;
          const te = this.cam.touchEnd;
          if (this.btnBck.checked)  this.level.clickBackgr(this.cam, sf, ts, te, mx, my);
          if (this.btnObj.checked)  this.level.clickObjs  (this.cam, this.tlPck, sf, ts, te, mx, my);
          if (this.btnBarr.checked) this.level.clickBarr  (this.cam, sf, ts, te, mx, my);
          if (this.btnUnit.checked) {
            this.level.clickUnits(this.cam, sf, ts, te, mx, my, this.btnAttacker.checked);
            if (this.level.isSelected()) {
              const sel = this.level.selectedObj;
              if (sel instanceof Unit) {
                this.btnAttacker.setChecked(sel.teamNum === 0);
                this.btnDefender.setChecked(sel.teamNum !== 0);
              }
            }
          }
        }
        break;
      }

      case CreatorStates.tilePicker:
        this.tlPck.onMouseUp(mx, my);
        if (this.tlPck.finished) this.state = CreatorStates.creator;
        break;
    }
  }

  onBackPressed() {
    switch (this.state) {
      case CreatorStates.menu:        this.finished = true; break;
      case CreatorStates.select:      this.state = CreatorStates.menu; break;
      case CreatorStates.creator:     this.state = CreatorStates.menu; break;
      case CreatorStates.tilePicker:  this.state = CreatorStates.creator; break;
    }
  }

  // ── Button logic ──────────────────────────────────────────────────────────
  _checkMenuBtns() {
    if (this.btnNew.pressed) {
      this.btnNew.reset();
      this.levelLoaded = false;
      this._showNewMapDialog().then(result => {
        if (!result) return;
        const cW2 = window.innerWidth, cH2 = window.innerHeight;
        this.level = new LevelLoader(result.cols, result.rows);
        this.level.levelName = result.name;
        this.cam = new Camera(this.level.getWidth(), this.level.getHeight());
        this.cam.init(cW2, cH2);
        this.cam.scaleMin = Math.min(cW2 / this.level.getWidth(), cH2 / this.level.getHeight());
        this.cam.scale    = this.cam.scaleMin;
        this.cam.selEnabled = true;
        this.state = CreatorStates.creator;
        this._selectTileDir(Storage.dataDirBacks);
      });
    }
    if (this.btnOpen.pressed) {
      this.btnOpen.reset();
      const names = Storage.listLevels();
      if (names.length === 0) { alert('No saved levels found.'); return; }
      this.scrollSelect = new ScrollBar();
      this.scrollSelect.fromNames(names, Math.floor(window.innerHeight * 0.1));
      this._prevState = CreatorStates.menu;
      this.state      = CreatorStates.select;
    }
    if (this.btnBack.pressed) {
      this.btnBack.reset();
      try { this.level.save2Storage(); } catch(e) {}
      this.finished = true;
    }
  }

  _selectTileDir(dir) {
    // Build tile file list by scanning known asset names
    // In a real deployment, this list would come from a manifest.json
    const files = window.ASSET_MANIFEST ? window.ASSET_MANIFEST[dir] : [];
    if (!files || files.length === 0) {
      console.warn(`No manifest entries for ${dir}. Skipping tile selection.`);
      return;
    }
    this.scrollSelect = new ScrollBar();
    this.scrollSelect.fromNames(files.map(f => f.replace(/\.png$/i, '')),
                                Math.floor(window.innerHeight * 0.1));
    this._prevState = CreatorStates.creator;
    this.state      = CreatorStates.select;
  }

  _checkCreatorBtns() {
    let hit = false;

    const radioLayer = (active, others) => {
      active.setChecked(true); for (const b of others) b.setChecked(false);
    };

    if (this.btnBck.pressed)  { this.btnBck.reset();  radioLayer(this.btnBck,  [this.btnObj,this.btnBarr,this.btnUnit]); this._showObjBtns(false); hit=true; }
    if (this.btnObj.pressed)  { this.btnObj.reset();  radioLayer(this.btnObj,  [this.btnBck,this.btnBarr,this.btnUnit]); this._showObjBtns(false); hit=true; }
    if (this.btnBarr.pressed) { this.btnBarr.reset(); radioLayer(this.btnBarr, [this.btnBck,this.btnObj, this.btnUnit]); this._showObjBtns(false); hit=true; }
    if (this.btnUnit.pressed) { this.btnUnit.reset(); radioLayer(this.btnUnit, [this.btnBck,this.btnObj, this.btnBarr]); this._showObjBtns(true);  hit=true; }

    if (this.btnLoad.pressed) {
      this.btnLoad.reset();
      if (this.btnBck.checked || this.btnObj.checked) {
        const dir = this.btnBck.checked ? Storage.dataDirBacks : Storage.dataDirTiles;
        this._selectTileDir(dir);
      } else if (this.btnUnit.checked) {
        this.scrollSelect = new ScrollBar();
        this.scrollSelect.fromNames(Defs.units, Math.floor(window.innerHeight * 0.1));
        this._prevState = CreatorStates.creator;
        this.state      = CreatorStates.select;
      }
      hit = true;
    }

    if (this.btnSave.pressed) {
      this.btnSave.reset();
      if (this.level.levelName) {
        this.level.save2Storage();
        Storage.exportLevel(this.level.levelName);
      }
      hit = true;
    }
    if (this.btnGrid.pressed) {
      this.btnGrid.reset();
      this._showGrid = !this._showGrid;
      this.btnGrid.setChecked(this._showGrid);
      hit = true;
    }
    if (this.btnCreatorBack.pressed) {
      this.btnCreatorBack.reset();
      this.state = CreatorStates.menu;
      hit = true;
    }

    if (this.btnDel.pressed)  { this.btnDel.reset();  this.level.deleteSelected(); hit=true; }
    if (this.btnMove.pressed) { this.btnMove.reset(); this.btnMove.setChecked(true); this.btnAdd.setChecked(false); this.level.setMoving(); hit=true; }
    if (this.btnAdd.pressed)  { this.btnAdd.reset();  this.btnAdd.setChecked(true); this.btnMove.setChecked(false); this.level.setAdding(); hit=true; }

    if (this.btnAttacker.pressed) {
      this.btnAttacker.reset(); this.btnAttacker.setChecked(true); this.btnDefender.setChecked(false);
      if (this.level.selectedObj instanceof Unit) this.level.selectedObj.teamNum = 0;
      hit = true;
    }
    if (this.btnDefender.pressed) {
      this.btnDefender.reset(); this.btnDefender.setChecked(false); this.btnAttacker.setChecked(false); this.btnDefender.setChecked(true);
      if (this.level.selectedObj instanceof Unit) this.level.selectedObj.teamNum = 1;
      hit = true;
    }

    // Visibility toggles
    for (const [btn, prop] of [[this.btnBckV,'viewBck'],[this.btnObjV,'viewObj'],[this.btnBarrV,'viewBarr'],[this.btnUnitV,'viewUnit']]) {
      if (btn.pressed) {
        btn.reset(); btn.setChecked(!btn.checked);
        btn.text          = btn.checked ? 'Hide' : 'Show';
        this.level[prop]  = btn.checked;
        hit = true;
      }
    }
    return hit;
  }

  _checkSelectBtns() {
    if (this.btnSelectBack.pressed) {
      this.btnSelectBack.reset();
      this.state = this._prevState;
      return;
    }
    const btn = this.scrollSelect ? this.scrollSelect.lastClickedBtn : null;
    if (!btn) return;

    switch (this._prevState) {
      case CreatorStates.menu:
        this.level = new LevelLoader();
        this.level.levelName = btn.text;
        this.level.loadFromStorage();
        this.levelLoaded = true;
        this.cam = new Camera(this.level.getWidth(), this.level.getHeight());
        this.cam.init(window.innerWidth, window.innerHeight);
        this.cam.scaleMin = Math.min(window.innerWidth / this.level.getWidth(), window.innerHeight / this.level.getHeight());
        this.cam.scale    = this.cam.scaleMin;
        this.cam.selEnabled = true;
        this.state = CreatorStates.creator;
        break;

      case CreatorStates.creator:
        if (this.btnBck.checked) {
          this.level.loadGround(`${btn.text}.png`);
        } else if (this.btnObj.checked) {
          this.tlPck = new TilePicker(`${btn.text}.png`);
          this.state = CreatorStates.tilePicker;
          return;
        } else if (this.btnUnit.checked) {
          this.level.setUnit(btn.text);
        }
        this.state = CreatorStates.creator;
        break;
    }
  }

  _showObjBtns(show) {
    this.btnAttacker.visible = show;
    this.btnDefender.visible = show;
  }

  // ── Draw ──────────────────────────────────────────────────────────────────
  draw(ctx) {
    const cW = window.innerWidth, cH = window.innerHeight;
    switch (this.state) {
      case CreatorStates.menu:
        ctx.fillStyle = 'rgba(0,0,0,0)'; // background drawn by MainMenu
        this.btnNew.draw(ctx);
        this.btnOpen.draw(ctx);
        this.btnBack.draw(ctx);
        break;

      case CreatorStates.select:
        if (this.scrollSelect) this.scrollSelect.draw(ctx);
        this.btnSelectBack.draw(ctx);
        break;

      case CreatorStates.creator:
        ctx.fillStyle = '#111';
        ctx.fillRect(0, 0, cW, cH);
        this.cam.push(ctx);
        this.level.draw(ctx);
        this.level.drawSelObj(ctx);
        if (this._showGrid) this._drawGrid(ctx);
        this.cam.pop(ctx);
        for (const b of this._creatorBtns) b.draw(ctx);
        if (this.level.levelName) {
          ctx.fillStyle    = 'rgba(255,255,255,0.7)';
          ctx.font         = '14px monospace';
          ctx.textAlign    = 'left';
          ctx.textBaseline = 'middle';
          ctx.fillText(`Level: ${this.level.levelName}`, this._smW + 12, this._bsH / 2 + 4);
        }
        break;

      case CreatorStates.tilePicker:
        if (this.tlPck) this.tlPck.draw(ctx);
        break;
    }
  }

  _drawGrid(ctx) {
    const s = this.level.blockSz;
    const w = this.level.getWidth(), h = this.level.getHeight();
    ctx.save();
    ctx.strokeStyle = 'rgba(200,200,200,0.2)';
    ctx.lineWidth   = 1 / this.cam.scale;
    ctx.beginPath();
    for (let x = 0; x <= w; x += s) { ctx.moveTo(x, 0); ctx.lineTo(x, h); }
    for (let y = 0; y <= h; y += s) { ctx.moveTo(0, y); ctx.lineTo(w, y); }
    ctx.stroke();
    ctx.restore();
  }

  reset() { this.finished = false; }
}
