# SiegeTactics JS

JavaScript remake of the original Processing/Android **SiegeTactics** game.

## Structure

```
SiegeTacticsJS/
├── index.html            ← Open this in a browser to play
├── js/
│   ├── main.js           ← Entry point, game loop, asset manifest
│   ├── Defs.js           ← Enums and global constants
│   ├── Storage.js        ← localStorage level persistence
│   ├── Camera.js         ← Pan/zoom camera (Screen.pde)
│   ├── Renderer.js       ← Y-sorted depth renderer
│   ├── LoadSprite.js     ← Sprite sheet animation
│   ├── LoadTile.js       ← Tileset loader
│   ├── GameObject.js     ← Abstract base object (Object.pde)
│   ├── Vehicle.js        ← Craig Reynolds steering behaviours
│   ├── Unit.js           ← Animated unit with state machine
│   ├── SoldierBasic.js   ← Concrete soldier unit
│   ├── Projectile.js     ← Arcing ranged projectile
│   ├── Path.js           ← Waypoint path for path-following
│   ├── Wall.js           ← Impassable wall obstacle
│   ├── Barrier.js        ← Editor-placed barrier
│   ├── TileObject.js     ← Tile-sheet sprite in the world
│   ├── Button.js         ← UI button
│   ├── ScrollBar.js      ← Scrollable button list
│   ├── Level.js          ← Abstract level base class
│   ├── LevelLoader.js    ← Level data + JSON save/load
│   ├── TilePicker.js     ← Tile region selector for editor
│   ├── LevelRunner.js    ← Select → Planning → Fight → Results
│   ├── Editor.js         ← Level editor (Creator.pde)
│   └── MainMenu.js       ← Top-level state machine
└── assets/
    ├── backs/            ← Background tilesets (grass1.png, …)
    ├── tiles/            ← Object tilesets
    ├── projectiles/      ← Projectile images (arrow.png)
    ├── BasicSpearman/    ← Unit sprite sheets
    ├── BasicSpearman2/
    └── BasicArcher/
```

## Running

Because the game loads image assets, you need a local HTTP server — double-clicking `index.html` will hit CORS restrictions.

**Python (quickest):**
```bash
cd SiegeTacticsJS
python3 -m http.server 8080
# open http://localhost:8080
```

**Node (http-server):**
```bash
npx http-server SiegeTacticsJS -p 8080
```

**VS Code:** Install the *Live Server* extension, right-click `index.html` → *Open with Live Server*.

## Adding assets

Copy your original Processing sprite folders directly into `assets/`:
```
assets/BasicSpearman/idleRU.png   (8-frame horizontal strip)
assets/BasicSpearman/attackRU.png (5-frame)
assets/BasicSpearman/runRU.png    (4-frame)
... etc for each of LU RU RD LD directions + deadR.png
```

Update the `ASSET_MANIFEST` in `js/main.js` to list any new tileset `.png` files so
they appear in the editor's file picker.

## Level format

Levels are stored as JSON arrays in `localStorage` under the key
`SiegeTactics/levels/<name>`.  Use **Export** (coming soon) to download as `.json`
and **Import** to load from a file — useful for sharing levels between devices.

## Key differences from the Processing version

| Original (Processing/Android) | JS Remake |
|---|---|
| `Storage.pde` — Android file I/O | `localStorage` + JSON download/upload |
| CSV level format | JSON array |
| `PGraphics` / `PImage` | `OffscreenCanvas` / `HTMLImageElement` |
| `DialogTextEdit` (Android dialog) | HTML `<input>` overlay |
| `touches[]` array | Unified Pointer Events API |
| `Screen.pde` | `Camera.js` |
| `Object.pde` | `GameObject.js` (renamed to avoid JS clash) |
| `Creator.pde` | `Editor.js` |

## Next steps

- [ ] Win/loss sound effects
- [ ] Level export / import UI buttons  
- [ ] More unit types
- [ ] Formation placement in planning phase
- [ ] Fog of war
