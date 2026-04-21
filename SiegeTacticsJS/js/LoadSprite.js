// LoadSprite.js — Sprite-sheet animation loader
// Ported from LoadSprite.pde
// Sheet format: single horizontal strip of square frames (each frame = height × height px)

class LoadSprite {
  constructor(path, speedDiv = 1) {
    this.path      = path;
    this.speedDiv  = speedDiv;
    this.frames    = 0;
    this.currFrame = 0;
    this.width     = 0;
    this.height    = 0;
    this.loaded    = false;
    this.fullCycle = false;
    this._spdCount = 0;
    this._tiles    = [];   // OffscreenCanvas per frame

    this._load();
  }

  _load() {
    const img   = new Image();
    img.src     = this.path;
    img.onload  = () => {
      this.height = img.height;
      this.width  = img.height;                           // each frame is square
      this.frames = Math.max(1, Math.floor(img.width / img.height));
      this._tiles = [];
      for (let f = 0; f < this.frames; f++) {
        const oc  = new OffscreenCanvas(this.height, this.height);
        const ctx = oc.getContext('2d');
        ctx.drawImage(img, f * this.height, 0, this.height, this.height,
                           0, 0, this.height, this.height);
        this._tiles.push(oc);
      }
      this.loaded = true;
    };
    img.onerror = () => console.warn(`LoadSprite: could not load "${this.path}"`);
  }

  setSpeedDiv(div) { this.speedDiv = div; }

  fullCycleFinished() {
    const v = this.fullCycle;
    this.fullCycle = false;
    return v;
  }

  update() {
    if (!this.loaded) return;
    this._spdCount++;
    if (this._spdCount >= this.speedDiv) {
      this._spdCount = 0;
      this.currFrame++;
      if (this.currFrame >= this.frames) {
        this.currFrame = 0;
        this.fullCycle = true;
      }
    }
  }

  // Draw centred on (x, y)
  draw(ctx, x, y) {
    if (!this.loaded || this._tiles.length === 0) {
      ctx.fillStyle   = '#646464';
      ctx.strokeStyle = '#000';
      ctx.lineWidth   = 2;
      ctx.fillRect  (x - 8, y - 8, 16, 16);
      ctx.strokeRect(x - 8, y - 8, 16, 16);
      return;
    }
    const tile = this._tiles[this.currFrame];
    ctx.drawImage(tile, x - tile.width / 2, y - tile.height / 2);
  }
}
