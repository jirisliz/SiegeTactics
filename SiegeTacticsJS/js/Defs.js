// Defs.js — Global constants, enums and small utilities
// Ported from Defs.pde

const Defs = {
  units: ['BasicSpearman', 'BasicSpearman2', 'BasicArcher'],

  swap(a, b) {
    const tmp = a.val;
    a.val = b.val;
    b.val = tmp;
  }
};

class IntHolder {
  constructor(v) { this.val = v; }
}

// ── Enums (frozen plain objects) ────────────────────────────────────────────
const MainStates       = Object.freeze({ main:'main', select:'select', game:'game', designer:'designer' });
const CreatorStates    = Object.freeze({ menu:'menu', select:'select', sizemap:'sizemap', creator:'creator', newMap:'newMap', tilePicker:'tilePicker' });
const LevelRunnerTypes = Object.freeze({ select:'select', planning:'planning', fight:'fight', results:'results' });
const LevelLoaderTypes = Object.freeze({ map:0, back:1, obj:2, barr:3, unit:4 });
const States           = Object.freeze({ walk:'walk', seek:'seek', stand:'stand', attack:'attack', defend:'defend', dead:'dead' });
const Dirs             = Object.freeze({ LU:'LU', RU:'RU', RD:'RD', LD:'LD' });
const UnitAnims        = Object.freeze({ idle:'idle', attack:'attack', attack2:'attack2', run:'run', dead:'dead' });
