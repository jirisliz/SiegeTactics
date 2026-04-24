// Unit.js — Animated game unit with state machine and 8-directional sprites
// Ported from Unit.pde

class Unit extends Vehicle {
  constructor(unitName, x, y, maxSpeed = 1.5, maxForce = 0.4) {
    super(x, y, maxSpeed, maxForce);
    this.unitType   = unitName;
    this.state      = States.walk;
    this.dir        = Dirs.RD;
    this.currAnim   = UnitAnims.idle;
    this.currAttack = 0;
    this.livesMax   = 20;
    this.lives      = this.livesMax;
    this.alive      = true;
    this.teamNum    = 0;
    this.viewRadius          = 200;
    this.attackRadius        = 20;
    this.attackRadiusRanged  = 200;
    this.enemyAttacking      = null;
    this.animFullCycle       = false;
    this.ranged              = false;
    this.projectileName      = 'arrow.png';
    this.projectiles         = null;
    this.size = { x: 16, y: 16 };
    this.orig = { x: 0,  y: 0  };
    this._order   = 'attack'; // 'attack' | 'path' | 'stand'
    this._anims   = {};
    this.animCurr = null;
    if (unitName) this.loadStdAnims(unitName);
  }

  loadStdAnims(name) {
    const f  = `assets/${name}`;
    const mk = (file, spd) => new LoadSprite(`${f}/${file}`, spd);
    const A  = this._anims;
    A.idleRU   = mk('idleRU.png',    8);
    A.idleLU   = mk('idleLU.png',    8);
    A.idleRD   = mk('idleRD.png',    8);
    A.idleLD   = mk('idleLD.png',    8);
    A.attackRU = mk('attackRU.png',  5);
    A.attackLU = mk('attackLU.png',  5);
    A.attackRD = mk('attackRD.png',  5);
    A.attackLD = mk('attackLD.png',  5);
    A.atk2RU   = mk('attack2RU.png', 5);
    A.atk2LU   = mk('attack2LU.png', 5);
    A.atk2RD   = mk('attack2RD.png', 5);
    A.atk2LD   = mk('attack2LD.png', 5);
    A.runRU    = mk('runRU.png',     4);
    A.runLU    = mk('runLU.png',     4);
    A.runRD    = mk('runRD.png',     4);
    A.runLD    = mk('runLD.png',     4);
    A.deadR    = mk('deadR.png',     4);
    this.updateCurrAnim();
  }

  _idleByDir()  { return this._anims[{RU:'idleRU',LU:'idleLU',RD:'idleRD',LD:'idleLD'}[this.dir]]; }
  _runByDir()   { return this._anims[{RU:'runRU', LU:'runLU', RD:'runRD', LD:'runLD' }[this.dir]]; }
  _attackByDir(){
    const b = this.currAttack === 0 ? 'attack' : 'atk2';
    return this._anims[{RU:`${b}RU`,LU:`${b}LU`,RD:`${b}RD`,LD:`${b}LD`}[this.dir]];
  }

  updateCurrAnim() {
    const s = this.state;
    if      (s === States.walk || s === States.seek)    this.animCurr = this._runByDir();
    else if (s === States.attack)                        this.animCurr = this._attackByDir();
    else if (s === States.stand || s === States.defend)  this.animCurr = this._idleByDir();
    else if (s === States.dead)                          this.animCurr = this._anims.deadR;
  }

  setState(st) { this.state = st; this.updateCurrAnim(); }
  setDir(d)    { this.dir   = d;  this.updateCurrAnim(); }
  setTarget(t) { this.target = { ...t }; this.state = States.seek; }

  setRanged(val, arr) { this.ranged = val; this.projectiles = val ? arr : null; }

  setAnimDiv(animEnum, div) {
    const map = {
      [UnitAnims.idle]:    ['idleRU','idleLU','idleRD','idleLD'],
      [UnitAnims.attack]:  ['attackRU','attackLU','attackRD','attackLD'],
      [UnitAnims.attack2]: ['atk2RU','atk2LU','atk2RD','atk2LD'],
      [UnitAnims.run]:     ['runRU','runLU','runRD','runLD'],
      [UnitAnims.dead]:    ['deadR']
    };
    for (const k of (map[animEnum] || [])) if (this._anims[k]) this._anims[k].setSpeedDiv(div);
  }

  selectDirQuad() {
    const a = Math.atan2(this.velocity.y, this.velocity.x);
    if      (a >= 0 && a <  Math.PI / 2) this.dir = Dirs.RD;
    else if (a >= Math.PI / 2)            this.dir = Dirs.LD;
    else if (a >= -Math.PI / 2 && a < 0) this.dir = Dirs.RU;
    else                                  this.dir = Dirs.LU;
    this.updateCurrAnim();
  }

  findNearestEnemy(enemies) {
    let best = Infinity, found = false;
    for (const u of enemies) {
      if (!u.alive) continue;
      const d = this._dist(this.position, u.position);
      if (d < best) { best = d; this.target = u.position; this.enemyAttacking = u; found = true; }
    }
    if (!found && this.alive) { this.state = States.walk; this.target = this.primaryTarget; }
  }

  attack(val)  { this.lives = Math.max(0, this.lives - val); }

  stillAlive() {
    if (this.lives <= 0) {
      this.alive = false; this.active = false;
      this.state = States.dead; this.updateCurrAnim();
    }
    return this.alive;
  }

  actionIfTargetNear(onNear) {
    const dist = this.target ? this._dist(this.position, this.target) : Infinity;
    if (dist < this.attackRadius) {
      this.selectDirQuad(); this.setState(onNear);
      if (this.animFullCycle) {
        this.animFullCycle = false;
        if (!this.ranged && onNear === States.attack) this.currAttack = Math.random() < 0.5 ? 0 : 1;
        if (this.ranged) this.currAttack = 1;
        if (this.enemyAttacking) this.enemyAttacking.attack(1);
      }
      return true;
    }
    if (dist < this.attackRadiusRanged && this.ranged) {
      this.selectDirQuad(); this.setState(States.defend);
      this.currAttack = 0; this.animCurr = this._attackByDir();
      if (this.animFullCycle && this.projectiles) {
        this.animFullCycle = false;
        const pr = new Projectile({ ...this.position }, `${Storage.dataDirProjectiles}/${this.projectileName}`);
        pr.fire(this.enemyAttacking);
        this.projectiles.push(pr);
      }
      return false;
    }
    return false;
  }

  updateUnit(allies, enemies, path, walls) {
    if (this.animCurr) {
      this.animCurr.update();
      if (this.animCurr.fullCycleFinished()) this.animFullCycle = true;
    }
    switch (this.state) {
      case States.walk:
        if (!this.actionIfTargetNear(States.attack) && this.alive) {
          super.update(); this.applyFollow(path);
          this.applySeparationCirc(allies); this.applySeparationCirc(enemies); this.applySeparationRect(walls);
          this.selectDirQuad();
        } break;
      case States.seek:
        if (!this.actionIfTargetNear(States.stand) && this.alive) {
          super.update(); this.applySeek();
          this.applySeparationCirc(allies); this.applySeparationCirc(enemies); this.applySeparationRect(walls);
          this.selectDirQuad();
        } break;
      case States.stand:
        this.velocity = { x:0, y:0 }; this.animCurr = this._idleByDir(); break;
      case States.attack:
        if (!this.actionIfTargetNear(States.attack) && this.alive) {
          super.update(); this.applyFollow(path); this.applySeek();
          this.applySeparationCirc(allies); this.applySeparationCirc(enemies); this.applySeparationRect(walls);
          this.selectDirQuad(); this.animCurr = this._runByDir();
        } break;
      case States.defend:
        this.animCurr = this._idleByDir(); this.actionIfTargetNear(States.attack);
        if (this.target && this._order !== 'stand') {
          const dist = this._dist(this.position, this.target);
          const shouldMove = this.ranged ? dist > this.attackRadiusRanged : dist < this.viewRadius;
          if (shouldMove) {
            super.update(); this.applySeek();
            this.applySeparationCirc(allies); this.applySeparationCirc(enemies); this.applySeparationRect(walls);
            this.selectDirQuad();
          }
        } break;
    }
  }

  draw(ctx) {
    if (this.animCurr) {
      this.animCurr.draw(ctx, this.position.x, this.position.y);
      if (this.alive) {
        const bw   = this.r * 0.8;
        const life = (this.lives / this.livesMax) * bw;
        ctx.strokeStyle = '#22c55e'; ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(this.position.x - life, this.position.y - this.r);
        ctx.lineTo(this.position.x + life, this.position.y - this.r);
        ctx.stroke();
      }
    } else {
      ctx.fillStyle = '#646464';
      ctx.beginPath(); ctx.arc(this.position.x, this.position.y, this.r, 0, Math.PI * 2); ctx.fill();
    }
  }
}
