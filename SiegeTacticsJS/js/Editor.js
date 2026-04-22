// Editor.js — Level editor (tile painting, unit/object/barrier placement)
// Ported from Creator.pde

class Editor {
  constructor() {
    this.finished  = false;
    this.state     = CreatorStates.menu;
    this._prevState = CreatorStates.menu;

    const cW = window.innerWidth, cH = window.innerHeight;
    UI.init();
    const bH  = UI.btnH, pad = UI.pad;
    const acW = UI.colAct, visW = UI.colVis;

    // ── Menu buttons ──
    const menuTop = Math.floor(cH * 0.58);
    this.btnNew  = new Button(UI.menuX, menuTop,                    UI.menuW, bH, 'New map');
    this.btnOpen = new Button(UI.menuX, menuTop + bH + UI.menuGap,  UI.menuW, bH, 'Open map');
    this.btnBack = new Button(UI.menuX, menuTop + 2*(bH+UI.menuGap),UI.menuW, bH, 'Back');

    // ── Creator toolbar (4 rows from bottom) ──
    // Visibility toggles at left edge; layer-select buttons beside them;
    // action buttons anchored to right edge.
    const visX = pad;
    const layX = visX + visW + pad;
    const layW = Math.max(90, Math.min(260, Math.round(cW * 0.28)));

    const y3 = UI.toolbarY(3);  // background row (top of toolbar)
    const y2 = UI.toolbarY(2);  // objects row
    const y1 = UI.toolbarY(1);  // barriers row
    const y0 = UI.toolbarY(0);  // units row (bottom)

    // Layer-select buttons
    this.btnBck  = new Button(layX, y3, layW, bH, 'Background'); this.btnBck.setChecked(true);
    this.btnObj  = new Button(layX, y2, layW, bH, 'Objects');
    this.btnBarr = new Button(layX, y1, layW, bH, 'Barriers');
    this.btnUnit = new Button(layX, y0, layW, bH, 'Units');

    // Visibility toggles
    this.btnBckV  = new Button(visX, y3, visW, bH, 'Hide'); this.btnBckV.setChecked(true);
    this.btnObjV  = new Button(visX, y2, visW, bH, 'Hide'); this.btnObjV.setChecked(true);
    this.btnBarrV = new Button(visX, y1, visW, bH, 'Hide'); this.btnBarrV.setChecked(true);
    this.btnUnitV = new Button(visX, y0, visW, bH, 'Hide'); this.btnUnitV.setChecked(true);

    // Action buttons — right-anchored
    // Row 3: Save (col 0), Grid (col 1)
    this.btnSave = new Button(UI.rightCol(0), y3, acW, bH, 'Save', 'primary');
    this.btnGrid = new Button(UI.rightCol(1), y3, acW, bH, 'Grid');

    // Row 2: Del (col 0), Copy (col 1), Load (col 2)
    this.btnDel  = new Button(UI.rightCol(0), y2, acW, bH, 'Del',  'danger');
    this.btnCopy = new Button(UI.rightCol(1), y2, acW, bH, 'Copy');
    this.btnLoad = new Button(UI.rightCol(2), y2, acW, bH, 'Load');

    // Row 1: Add (col 0), Move (col 1)
    this.btnAdd  = new Button(UI.rightCol(0), y1, acW, bH, 'Add');
    this.btnMove = new Button(UI.rightCol(1), y1, acW, bH, 'Move'); this.btnMove.setChecked(true);

    // Row 0: Attacker/Defender (hidden until Units layer active)
    this.btnAttacker = new Button(UI.rightCol(1), y0, acW, bH, 'Atk');
    this.btnDefender = new Button(UI.rightCol(0), y0, acW, bH, 'Def');
    this.btnAttacker.setChecked(true);
    this.btnAttacker.visible = false;
    this.btnDefender.visible = false;

    // Top-left buttons
    const topW = Math.max(80, Math.round(cW * 0.13));
    this.btnCreatorBack = new Button(pad,               pad, topW, bH, '← Back');
    this.btnEditorSel   = new Button(pad + topW + pad,  pad, topW, bH, 'Select');

    // Select-back button (shown in scrollable list sub-state)
    const selBkW = Math.max(100, Math.round(cW * 0.25));
    this.btnSelectBack = new Button(Math.round((cW - selBkW) / 2), y0, selBkW, bH, '← Back');

    // Store for draw-time use
    this._topW  = topW;
    this._bH    = bH;
    this._pad   = pad;

    this._creatorBtns = [this.btnBck, this.btnObj, this.btnBarr, this.btnUnit,
                         this.btnBckV,this.btnObjV,this.btnBarrV,this.btnUnitV,
                         this.btnLoad,this.btnAdd, this.btnDel,  this.btnMove,
                         this.btnCopy,
                         this.btnAttacker, this.btnDefender,
                         this.btnSave, this.btnGrid, this.btnCreatorBack, this.btnEditorSel];

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

    // ── Multi-selection state ──
    this._editorSelMode  = false;
    this._editorSelected = [];
    this._selRectStart   = null;
    this._selRectCurr    = null;
    this._midDrag        = false;   // middle-button pan active

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
  onMouseDown(mx, my, button = 0) {
    switch (this.state) {
      case CreatorStates.select:
        this.scrollSelect.open(my); break;
      case CreatorStates.creator:
        if (button === 1) {
          this._midDrag = true;
        } else if (this._editorSelMode) {
          this._selRectStart = { x: mx, y: my };
          this._selRectCurr  = { x: mx, y: my };
        } else {
          this.cam.onMouseDown(mx, my);
        }
        break;
      case CreatorStates.tilePicker:
        this.tlPck.onMouseDown(mx, my); break;
    }
  }

  onMouseMove(mx, my, px, py, drag) {
    switch (this.state) {
      case CreatorStates.select:
        if (drag) this.scrollSelect.update(my - py); break;
      case CreatorStates.creator:
        if (this._midDrag) {
          this.cam.onMouseMove(mx, my, px, py, drag);
        } else if (this._editorSelMode) {
          this._selRectCurr = { x: mx, y: my };
        } else {
          this.cam.onMouseMove(mx, my, px, py, drag);
        }
        break;
      case CreatorStates.tilePicker:
        this.tlPck.onMouseMove(mx, my, px, py, drag); break;
    }
  }

  onMouseUp(mx, my, button = 0) {
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
        if (button === 1) { this._midDrag = false; break; }
        for (const b of this._creatorBtns) b.onMouseUp(mx, my);
        const consumed = this._checkCreatorBtns();
        if (!consumed) {
          if (this._editorSelMode && this._selRectStart) {
            // Rubber-band: add all visible objects inside the rect to the selection
            const x1 = Math.min(this._selRectStart.x, mx);
            const y1 = Math.min(this._selRectStart.y, my);
            const x2 = Math.max(this._selRectStart.x, mx);
            const y2 = Math.max(this._selRectStart.y, my);
            const wMin = this.cam.screen2World(x1, y1);
            const wMax = this.cam.screen2World(x2, y2);
            const candidates = [];
            if (this.level.viewObj)  candidates.push(...this.level.objs);
            if (this.level.viewBarr) candidates.push(...this.level.barrs);
            if (this.level.viewUnit) {
              candidates.push(...this.level.attackers);
              candidates.push(...this.level.defenders);
            }
            for (const o of candidates) {
              if (o.position.x >= wMin.x && o.position.x <= wMax.x &&
                  o.position.y >= wMin.y && o.position.y <= wMax.y &&
                  !this._editorSelected.includes(o)) {
                this._editorSelected.push(o);
              }
            }
            this._selRectStart = null;
            this._selRectCurr  = null;
          } else if (!this._editorSelMode) {
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
      active.setChecked(true);
      for (const b of others) b.setChecked(false);
    };

    if (this.btnEditorSel.pressed) {
      this.btnEditorSel.reset();
      this._editorSelMode = !this._editorSelMode;
      this.btnEditorSel.setChecked(this._editorSelMode);
      if (!this._editorSelMode) {
        this._editorSelected = [];
        this._selRectStart   = null;
        this._selRectCurr    = null;
      }
      hit = true;
    }

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

    if (this.btnDel.pressed) {
      this.btnDel.reset();
      if (this._editorSelected.length > 0) {
        this.level.deleteObjects(this._editorSelected);
        this._editorSelected = [];
      } else {
        this.level.deleteSelected();
      }
      hit = true;
    }
    if (this.btnCopy.pressed) {
      this.btnCopy.reset();
      if (this._editorSelected.length > 0)
        this._editorSelected = this.level.copyObjects(this._editorSelected);
      hit = true;
    }
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
        this._drawEditorSelection(ctx);
        if (this._showGrid) this._drawGrid(ctx);
        this.cam.pop(ctx);
        this._drawEditorSelRect(ctx);
        for (const b of this._creatorBtns) b.draw(ctx);
        if (this.level.levelName) {
          ctx.fillStyle    = 'rgba(255,255,255,0.7)';
          ctx.font         = `${Math.max(12, Math.round(this._bH * 0.32))}px monospace`;
          ctx.textAlign    = 'left';
          ctx.textBaseline = 'middle';
          ctx.fillText(`Level: ${this.level.levelName}`,
            this._pad + this._topW + this._pad + this._topW + this._pad * 2,
            this._pad + this._bH / 2);
        }
        break;

      case CreatorStates.tilePicker:
        if (this.tlPck) this.tlPck.draw(ctx);
        break;
    }
  }

  // Green outlines around each editor-selected object (world space, inside cam.push/pop)
  _drawEditorSelection(ctx) {
    if (this._editorSelected.length === 0) return;
    ctx.save();
    ctx.strokeStyle = '#22c55e';
    ctx.lineWidth   = 2;
    ctx.globalAlpha = 0.9;
    ctx.setLineDash([4, 4]);
    for (const o of this._editorSelected) {
      const hw = o.size.x / 2, hh = o.size.y / 2;
      ctx.strokeRect(o.position.x - hw, o.position.y - hh, o.size.x, o.size.y);
    }
    ctx.restore();
  }

  // Yellow rubber-band rectangle (screen space, drawn after cam.pop)
  _drawEditorSelRect(ctx) {
    if (!this._editorSelMode || !this._selRectStart || !this._selRectCurr) return;
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
