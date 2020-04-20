enum LevelLoaderTypes
{
  map, back, obj, unit;
}

class LevelLoader extends Level 
{
  Renderer r;

  ArrayList<SoldierBasic> attackers;
  ArrayList<SoldierBasic> defenders;

  LoadTile ground;
  BackParams[][] bckgs; 
  StringDict saveTypes;
  ArrayList<Wall> walls;
  ArrayList<TileObject> objs;

  // Selections
  PGraphics backgr;
  String unitName = Defs.units[0];

  String levelName;
  String levelFolder = "levels";

  LevelLoader() 
  {
    init();
  }

  LevelLoader(int cols, int rows) 
  {
    mGridCols = cols;
    mGridRows = rows;
    init();
  }

  LevelLoader(String tile) 
  {
    loadTile(tile, Storage.dataDirTiles);
    mBlockSz = ground.getTileSide();
    mGridCols = ground.xNum;
    mGridRows = ground.yNum;
    init();
  }

  void init() 
  {
    r = new Renderer();

    bckgs = new BackParams[mGridCols+1][mGridRows+1];
    walls = new ArrayList<Wall>();
    attackers = new ArrayList<SoldierBasic>();
    defenders = new ArrayList<SoldierBasic>();
    objs = new ArrayList<TileObject>();

    // Draw grid 
    drawGrid();
  }

  boolean loadGround(String name) 
  {
    return loadTile(name, Storage.dataDirBacks);
  }


  boolean loadTile(String name, String dir) 
  {
    boolean ret = false;
    try
    {
      String backsDir = dataPath(dir); 
      ground = new LoadTile(backsDir+"/" + name, 16); 
      ret = true;
    }
    catch(Exception ex) 
    {
      println("loadGround exception; "+ ex);
    }
    return ret;
  }
  void drawTiles() 
  {
    int side = ground.getTileSide();
    backgr.beginDraw();
    for (int i = 0; i < ground.xNum; i++) 
    {
      for (int j = 0; j < ground.yNum; j++) 
      {
        backgr.image(ground.getTile(i, j), i*side, j*side);
      }
    }
    backgr.endDraw();
  }

  void fillGround(Screen screen) 
  {
    PVector start = new PVector(0, 0);
    PVector end = new PVector(screen.mWidth, screen.mHeight);

    fillAreaBack(start, end);
  }

  void setUnit(String name)
  {
    unitName = name;
  } 

  void drawGrid() 
  {
    PVector sz = getLevelSize();
    backgr = createGraphics((int) sz.x, (int) sz.y);
    backgr.beginDraw();
    backgr.background(0);
    backgr.endDraw();
  }

  void update() 
  {
    r.clear(); 
    for (SoldierBasic s : attackers) 
    {
      s.update(null, null, null, null);
      r.add(s);
    }

    for (SoldierBasic s : defenders) 
    {
      s.update(null, null, null, null);
      r.add(s);
    }
    for (TileObject t : objs) 
    {
      r.add(t);
    }
  }

  void draw() 
  {
    image(backgr, 0, 0);
    update();
    r.draw();
  }

  void addBackgr(PVector target) 
  {
    int x = (int) target.x;
    int y = (int) target.y;
    x = x/mBlockSz*mBlockSz;
    y = y/mBlockSz*mBlockSz;
    if (x < backgr.width && y < backgr.height &&
      x >= 0 && y >= 0)
    {
      backgr.beginDraw();

      backgr.image(ground.getRandTile(), x, y);

      backgr.endDraw(); 

      x /= mBlockSz;
      y /= mBlockSz;

      // add to list for saving purposes 
      BackParams bck = new BackParams(
        new PVector(x, y), 
        ground.path, 
        new PVector(ground.xLast, ground.yLast));
      bckgs[x][y] = bck;
      //add2GrList(bck);
    }
  }

  void fillAreaBack(PVector start, PVector end) 
  {
    IntHolder sx = new IntHolder((int) (start.x / mBlockSz));
    IntHolder sy = new IntHolder((int) (start.y / mBlockSz)) ;
    IntHolder ex = new IntHolder((int) (end.x / mBlockSz));
    IntHolder ey = new IntHolder((int) (end.y / mBlockSz));

    if (sx.val> ex.val) Defs.swap(sx, ex);
    if (sy.val> ey.val) Defs.swap(sy, ey);

    for (int i = sx.val; i <= ex.val; i++) 
    {
      for (int j = sy.val; j <= ey.val; j++) 
      {
        PVector target = 
          new PVector(i*mBlockSz, j*mBlockSz);

        addBackgr(target);
      }
    }
  }

  void clickBackrDrag(Screen screen)
  {
    if (screen.mTrStart || ground == null)return;
    PVector start = screen.screen2World(screen.touchStart);
    PVector end = screen.screen2World(screen.touchEnd);

    fillAreaBack(start, end);
  } 

  void clickBackgr(Screen screen) 
  {
    if (screen.mTrStart || ground == null)return;
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));

    addBackgr(target);
  }

  void clickObjs(Screen screen, TilePicker tlPck) 
  {
    if (screen.mTrStart || tlPck == null)return;
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));
    int x = (int) target.x;
    int y = (int) target.y;
    x = x/mBlockSz*mBlockSz;
    y = y/mBlockSz*mBlockSz;

    TileObject t = tlPck.getSelectedTileObject();
    t.setLocation(new PVector(x, y));

    objs.add(t);
  }

  void clickUnits(Screen screen) 
  {
    if (screen.mTrStart)return;
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));
    int x = (int) target.x;
    int y = (int) target.y;

    SoldierBasic s1 = new SoldierBasic(
      x, y, 
      unitName);
    s1.setState(States.stand);
    s1.dir = Dirs.RD;
    attackers.add(s1);
  }

  void drawBack(BackParams bck) 
  {
  }

  boolean save2File() 
  {
    boolean ret = false;

    if (levelName.length() == 0)return ret;

    String path = Storage.createFolder(levelFolder);
    println(path);

    Table table = new Table(); 
    table.addColumn("type"); 
    table.addColumn("x"); 
    table.addColumn("y"); 
    table.addColumn("file"); 
    table.addColumn("param1");
    table.addColumn("param2");
    table.addColumn("param3");
    table.addColumn("param4");

    // Standard map size
    TableRow newRow = table.addRow(); 
    newRow.setInt("type", LevelLoaderTypes.map.ordinal()); 
    newRow.setInt("x", (int) mGridCols); 
    newRow.setInt("y", (int) mGridRows); 
    newRow.setInt("param1", (int)  mBlockSz);

    // Backs save
    //for (BackParams bp : grList) 
    for (int i = 0; i < mGridCols; i++) 
    {
      for (int j = 0; j < mGridRows; j++) 
      {
        BackParams bp = bckgs[i][j];
        newRow = table.addRow(); 
        newRow.setInt("type", LevelLoaderTypes.back.ordinal()); 
        newRow.setInt("x", (int)  bp.pos.x); 
        newRow.setInt("y", (int)  bp.pos.y); 
        newRow.setString("file", bp.tileName);
        newRow.setInt("param1", (int)  bp.tilePos.x); 
        newRow.setInt("param2", (int)  bp.tilePos.y);
      }
    }

    for (TileObject to : objs) 
    {
      newRow = table.addRow(); 
      newRow.setInt("type", LevelLoaderTypes.obj.ordinal()); 
      newRow.setInt("x", (int)  to.position.x); 
      newRow.setInt("y", (int)  to.position.y);
      newRow.setString("file", to.fileName);
      newRow.setInt("param1", (int)  to.tilePos.x); 
      newRow.setInt("param2", (int)  to.tilePos.y);
      newRow.setInt("param3", (int)  to.tileSz.x); 
      newRow.setInt("param4", (int)  to.tileSz.y);
    }
    
    for(SoldierBasic s : attackers) 
    {
      newRow = table.addRow(); 
      newRow.setInt("type", LevelLoaderTypes.unit.ordinal()); 
      newRow.setInt("x", (int)  s.position.x); 
      newRow.setInt("y", (int)  s.position.y);
      newRow.setString("file", s.unitType);
      newRow.setInt("param1", 0); 
    }
    
    for(SoldierBasic s : defenders) 
    {
      newRow = table.addRow(); 
      newRow.setInt("type", LevelLoaderTypes.unit.ordinal()); 
      newRow.setInt("x", (int)  s.position.x); 
      newRow.setInt("y", (int)  s.position.y);
      newRow.setString("file", s.unitType);
      newRow.setInt("param1", 1); 
    }

    if (path != null) 
    {
      String filePath =path+"/"+levelName+".csv";
      saveTable(table, filePath);
      println("test file saved to: "+filePath);
    } else return false;

    return ret;
  }

  void bckgsClear() 
  {
    for (int i = 0; i < mGridCols; i++) 
    {
      for (int j = 0; j < mGridRows; j++) 
      {
        BackParams bp = bckgs[i][j];
      }
    }
  }

  boolean loadFromFile() 
  {
    boolean ret = false;
    String path = Storage.createFolder(levelFolder);
    if (path != null) 
    {
      // Crear previous data
      //grList.clear();
      drawGrid();

      Table table;
      try
      {
        String filePath =path+"/"+levelName+".csv";
        table = loadTable(filePath, "header");
      }
      catch(Exception ex) 
      {
        println("exception loadFromFile: "+ex);
        return false;
      }

      // Load level
      for (int i = 0; i<table.getRowCount(); i++) 
      {
        TableRow row = table.getRow(i);
        LevelLoaderTypes type = LevelLoaderTypes.values()[row.getInt("type")];
        int x = row.getInt("x");
        int y = row.getInt("y");
        String file = row.getString("file");
        int param1 = row.getInt("param1");
        int param2 = row.getInt("param2");
        int param3 = row.getInt("param3");
        int param4 = row.getInt("param4");

        // Load data according to type
        switch(type)
        {
        case map:
          mGridCols = x;
          mGridRows = y;
          mBlockSz = param1;
          bckgs = new BackParams[mGridCols][mGridRows];
          break;
        case back:
          PVector p = new PVector(x, y);
          String tn = file;
          PVector tp = new PVector(param1, param2);
          String backsDir = dataPath(Storage.dataDirBacks); 
          ground = new LoadTile(backsDir+"/" + tn, 16); 
          backgr.beginDraw();
          backgr.image(ground.getTile((int) tp.x, (int) tp.y), 
            x*mBlockSz, y*mBlockSz);
          backgr.endDraw(); 

          BackParams b = new BackParams(p, tn, tp);
          if (x < mGridCols && y < mGridRows)
          {
            bckgs[x][y] = b;
          }

          break;
        case obj:
          PVector op = new PVector(x, y);
          String otn = file;
          PVector otp = new PVector(param1, param2);
          PVector ots = new PVector(param3, param4);
          TileObject oto = new TileObject(otn, otp, ots);

          String dir = dataPath(Storage.dataDirTiles); 
          PImage img = loadImage(dir + "/" + otn);
          oto.loadTileImg(img);
          oto.setLocation(op);
          objs.add(oto);
          break;
        case unit:

          SoldierBasic s1 = new SoldierBasic(
            x, y, 
            file);
          s1.setState(States.stand);
          s1.dir = Dirs.RD;
          if (param1 == 0)attackers.add(s1);
          if (param1 == 1)defenders.add(s1);
          break;
        }
      }
    }
    return ret;
  }
}

class BackParams
{
  PVector pos;
  String tileName;
  PVector tilePos;

  BackParams(PVector p, String tName, PVector tPos) 
  {
    pos = p;
    tileName = tName;
    tilePos = tPos;
  }
}

class TileParams
{
  PVector pos;
  String tileName;
  PVector tilePos;
  PVector tileSize;

  TileParams(PVector p, String tName, PVector tPos, PVector tSz) 
  {
    pos = p;
    tileName = tName;
    tilePos = tPos;
    tileSize = tSz;
  }
}
