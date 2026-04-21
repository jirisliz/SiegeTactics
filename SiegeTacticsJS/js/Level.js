// Level.js — Abstract base class for all levels
// Ported from Level.pde

class Level {
  constructor() {
    this.blockSz  = 16;
    this.gridCols = 16;
    this.gridRows = 32;
  }

  getWidth()    { return this.blockSz * this.gridCols; }
  getHeight()   { return this.blockSz * this.gridRows; }
  getBlockSz()  { return this.blockSz; }
  getLevelSize(){ return { w: this.getWidth(), h: this.getHeight() }; }

  update()      { /* override */ }
  draw(ctx)     { /* override */ }
  onMouseClick(wx, wy) { /* override */ }
}
