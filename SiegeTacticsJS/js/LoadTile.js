// LoadTile.js — Tileset loader
// Ported from LoadTile.pde
// Supports: LoadTile(path, sidePx)  and  LoadTile(path, xCount, yCount)

class LoadTile {
  constructor(path, sideSzOrX, yNum) {
    this.path   = path;
    this.xNum   = 0;
    this.yNum   = 0;
    this.xLast  = 0;
    this.yLast  = 0;
    this.loaded = false;
    this._side  = 0;
    this._img   = null;
    this._args  = { sideSzOrX, yNum };
    this._load();
  }

  _load() {
    const img   = new Image();
    img.src     = this.path;
    img.onload  = () => {
      this._img = img;
      const { sideSzOrX, yNum } = this._args;
      if (yNum !== undefined) {
        this.xNum  = sideSzOrX;
        this.yNum  = yNum;
        this._side = Math.floor(img.width / this.xNum);
      } else {
        this._side = sideSzOrX;
        this.xNum  = Math.floor(img.width  / this._side);
        this.yNum  = Math.floor(img.height / this._side);
      }
      this.loaded = true;
    };
    img.onerror = () => console.warn(`LoadTile: could not load "${this.path}"`);
  }

  getWidth()    { return this._img ? this._img.width  : 0; }
  getHeight()   { return this._img ? this._img.height : 0; }
  getTileSide() { return this._side; }

  getTile(x, y) {
    if (!this.loaded || x < 0 || y < 0 || x >= this.xNum || y >= this.yNum) return null;
    this.xLast = x;
    this.yLast = y;
    const s   = this._side;
    const oc  = new OffscreenCanvas(s, s);
    oc.getContext('2d').drawImage(this._img, x * s, y * s, s, s, 0, 0, s, s);
    return oc;
  }

  getRandTile() {
    const x = Math.floor(Math.random() * (this.xNum - 0.01));
    const y = Math.floor(Math.random() * (this.yNum - 0.01));
    return this.getTile(x, y);
  }
}
