// Storage.js — Level persistence via localStorage
// Ported from Storage.pde (Android file I/O → browser localStorage + JSON download/upload)

const Storage = {
  gameFolder:         'SiegeTactics',
  levelsFolder:       'levels',
  dataDirBacks:       'assets/backs',
  dataDirTiles:       'assets/tiles',
  dataDirProjectiles: 'assets/projectiles',

  _key(name) {
    return `${this.gameFolder}/${this.levelsFolder}/${name}`;
  },

  saveLevel(name, data) {
    try {
      localStorage.setItem(this._key(name), JSON.stringify(data));
      return true;
    } catch (e) {
      console.error('Storage.saveLevel failed:', e);
      return false;
    }
  },

  loadLevel(name) {
    try {
      const raw = localStorage.getItem(this._key(name));
      return raw ? JSON.parse(raw) : null;
    } catch (e) {
      console.error('Storage.loadLevel failed:', e);
      return null;
    }
  },

  deleteLevel(name) {
    localStorage.removeItem(this._key(name));
  },

  listLevels() {
    const prefix = `${this.gameFolder}/${this.levelsFolder}/`;
    const names  = [];
    for (let i = 0; i < localStorage.length; i++) {
      const k = localStorage.key(i);
      if (k && k.startsWith(prefix)) names.push(k.slice(prefix.length));
    }
    return names.sort();
  },

  // Download a level as a .json file
  exportLevel(name) {
    const data = this.loadLevel(name);
    if (!data) return;
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url  = URL.createObjectURL(blob);
    const a    = Object.assign(document.createElement('a'), { href: url, download: `${name}.json` });
    a.click();
    URL.revokeObjectURL(url);
  },

  // Import a .json File object, returns Promise<levelName>
  importLevel(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload  = e => {
        try {
          const data = JSON.parse(e.target.result);
          const name = file.name.replace(/\.json$/i, '');
          this.saveLevel(name, data);
          resolve(name);
        } catch (err) { reject(err); }
      };
      reader.onerror = reject;
      reader.readAsText(file);
    });
  }
};
