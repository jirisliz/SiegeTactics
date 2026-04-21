// SoldierBasic.js — Concrete soldier unit
// Ported from SoldierBasic.pde

class SoldierBasic extends Unit {
  constructor(x, y, unitName = 'BasicSpearman') {
    super(unitName, x, y, 1 + Math.random(), 0.4);
    this.teamNum = 0;
  }
}
