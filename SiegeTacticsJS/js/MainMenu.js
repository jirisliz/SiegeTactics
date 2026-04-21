// MainMenu.js — Top-level state machine: main menu / game / editor
// Ported from MainMenu.pde

class MainMenu {
  constructor(canvas) {
    this.canvas   = canvas;
    this.ctx      = canvas.getContext('2d');
    this.state    = MainStates.main;

    const cW = window.innerWidth, cH = window.innerHeight;
    const bw = Math.floor(cW / 2), bh = Math.floor(cH / 12), bx = Math.floor(cW / 4);

    this.btnStart    = new Button(bx, Math.floor(cH * 7/10), bw, bh, 'Start');
    this.btnDesigner = new Button(bx, Math.floor(cH * 8/10), bw, bh, 'Editor');
    this.btnExit     = new Button(bx, Math.floor(cH * 9/10), bw, bh, 'Exit');

    this.levelRunner = null;
    this.editor      = null;

    // Background demo level
    this._bgCam   = new Camera(16 * 16, 16 * 32);
    this._bgCam.init(cW, cH);
    this._bgLevel = null;
    this._tryLoadBgLevel();

    // Bind pointer events
    this._mx = 0; this._my = 0;
    this._pmx = 0; this._pmy = 0;
    this._drag = false;
    canvas.addEventListener('pointerdown',  e => this._onDown(e));
    canvas.addEventListener('pointermove',  e => this._onMove(e));
    canvas.addEventListener('pointerup',    e => this._onUp(e));
    canvas.addEventListener('pointercancel',e => { this._drag = false; });
    canvas.addEventListener('wheel',        e => { e.preventDefault(); this._onWheel(e); }, { passive:false });
    document.addEventListener('keydown',    e => { if (e.key === 'Escape') this.onBackPressed(); });
  }

  _tryLoadBgLevel() {
    // Try to load first saved level as background preview
    const names = Storage.listLevels();
    if (names.length > 0) {
      this._bgLevel            = new LevelLoader();
      this._bgLevel.levelName  = names[0];
      this._bgLevel.loadFromStorage();
    }
  }

  // ── Pointer event normalisation ───────────────────────────────────────────
  _pos(e) {
    const r = this.canvas.getBoundingClientRect();
    return { x: e.clientX - r.left, y: e.clientY - r.top };
  }

  _onDown(e) {
    const { x, y } = this._pos(e);
    this._mx = x; this._my = y; this._pmx = x; this._pmy = y;
    this._drag = true;
    this.onMouseDown(x, y);
  }

  _onMove(e) {
    const { x, y } = this._pos(e);
    this._pmx = this._mx; this._pmy = this._my;
    this._mx  = x;        this._my  = y;
    if (this._drag) this.onMouseMove(x, y, this._pmx, this._pmy);
  }

  _onUp(e) {
    const { x, y } = this._pos(e);
    this._drag = false;
    this.onMouseUp(x, y);
  }

  _onWheel(e) {
    switch (this.state) {
      case MainStates.main:    this._bgCam.onWheel(e.deltaY); break;
      case MainStates.game:    if (this.levelRunner?.cam) this.levelRunner.cam.onWheel(e.deltaY); break;
      case MainStates.designer:if (this.editor?.cam)     this.editor.cam.onWheel(e.deltaY); break;
    }
  }

  // ── Input ─────────────────────────────────────────────────────────────────
  onMouseDown(mx, my) {
    switch (this.state) {
      case MainStates.game:     this.levelRunner.onMouseDown(mx, my); break;
      case MainStates.designer: this.editor.onMouseDown(mx, my);      break;
    }
  }

  onMouseMove(mx, my, pmx, pmy) {
    switch (this.state) {
      case MainStates.main:
        this._bgCam.onMouseMove(mx, my, pmx, pmy, this._drag); break;
      case MainStates.game:
        this.levelRunner.onMouseMove(mx, my, pmx, pmy, this._drag); break;
      case MainStates.designer:
        this.editor.onMouseMove(mx, my, pmx, pmy, this._drag); break;
    }
  }

  onMouseUp(mx, my) {
    switch (this.state) {
      case MainStates.main:
        this.btnStart.onMouseUp(mx, my);
        this.btnDesigner.onMouseUp(mx, my);
        this.btnExit.onMouseUp(mx, my);
        this._checkMainBtns(); break;
      case MainStates.game:
        this.levelRunner.onMouseUp(mx, my);
        this._checkGame(); break;
      case MainStates.designer:
        this.editor.onMouseUp(mx, my);
        this._checkEditor(); break;
    }
  }

  onBackPressed() {
    switch (this.state) {
      case MainStates.main:     break; // nothing above main
      case MainStates.game:     this.levelRunner.onBackPressed(); this._checkGame();   break;
      case MainStates.designer: this.editor.onBackPressed();      this._checkEditor(); break;
    }
  }

  // ── State transitions ─────────────────────────────────────────────────────
  _checkMainBtns() {
    if (this.btnStart.pressed) {
      this.btnStart.reset();
      this.levelRunner = new LevelRunner();
      this.state       = MainStates.game;
    }
    if (this.btnDesigner.pressed) {
      this.btnDesigner.reset();
      this.editor = new Editor();
      this.state  = MainStates.designer;
    }
    if (this.btnExit.pressed) {
      this.btnExit.reset();
      window.close(); // Works when opened as PWA; browser tabs ignore it
    }
  }

  _checkGame() {
    if (this.levelRunner?.finished) {
      this.levelRunner = null;
      this.state       = MainStates.main;
      this._tryLoadBgLevel(); // refresh background preview
    }
  }

  _checkEditor() {
    if (this.editor?.finished) {
      this.editor.reset();
      this.editor = null;
      this.state  = MainStates.main;
      this._tryLoadBgLevel();
    }
  }

  // ── Draw ──────────────────────────────────────────────────────────────────
  draw() {
    const ctx = this.ctx;
    const cW  = window.innerWidth, cH = window.innerHeight;
    ctx.clearRect(0, 0, cW, cH);

    switch (this.state) {
      case MainStates.main:
        // Scrolling background preview
        ctx.fillStyle = '#1a1a1a';
        ctx.fillRect(0, 0, cW, cH);
        if (this._bgLevel) {
          this._bgCam.push(ctx);
          this._bgLevel.draw(ctx);
          this._bgCam.pop(ctx);
        }
        // Title
        ctx.fillStyle    = 'rgba(0,0,0,0.5)';
        ctx.fillRect(0, 0, cW, cH);
        ctx.fillStyle    = '#fff';
        ctx.font         = `bold ${Math.floor(cH * 0.07)}px monospace`;
        ctx.textAlign    = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('SIEGE TACTICS', cW/2, cH * 0.22);
        ctx.font      = `${Math.floor(cH * 0.025)}px monospace`;
        ctx.fillStyle = 'rgba(255,255,255,0.5)';
        ctx.fillText('JavaScript Edition', cW/2, cH * 0.31);

        this.btnStart.draw(ctx);
        this.btnDesigner.draw(ctx);
        this.btnExit.draw(ctx);
        break;

      case MainStates.game:
        this.levelRunner.draw(ctx); break;

      case MainStates.designer:
        this.editor.draw(ctx); break;
    }
  }
}
