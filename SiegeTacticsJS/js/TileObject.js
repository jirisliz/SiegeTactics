// TileObject.js — A tile-sheet sprite placed in the world
// Ported from TileObject.pde

class TileObject extends GameObject {
  constructor(fileName, tilePosX, tilePosY, sizeW, sizeH) {
    super();
    this.fileName = fileName;
    this.tilePos  = { x: tilePosX, y: tilePosY };
    this.size     = { x: sizeW,    y: sizeH    };
    this.orig     = { x: sizeW/4,  y: sizeH/4  };
    this._img     = null;  // OffscreenCanvas set after tile extraction
  }

  setTileImg(oc)    { this._img = oc; }

  loadTileImg(srcImg) {
    const oc  = new OffscreenCanvas(this.size.x, this.size.y);
    const ctx = oc.getContext('2d');
    ctx.drawImage(srcImg,
      this.tilePos.x, this.tilePos.y, this.size.x, this.size.y,
      0, 0, this.size.x, this.size.y);
    this._img = oc;
  }

  setLocation(x, y) { this.position = { x, y }; }

  draw(ctx) {
    if (!this._img) return;
    ctx.drawImage(this._img,
      this.position.x - this._img.width  / 2,
      this.position.y - this._img.height / 2);
  }
}
