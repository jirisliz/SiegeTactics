enum LevelLoaderTypes
{
  map, back, wall, unit;
}

class LevelLoader extends Level 
{
  Renderer r;

  ArrayList<SoldierBasic> attackers;
  ArrayList<SoldierBasic> defenders;

  LoadTile ground;
  ArrayList<BackParams> grList;
  StringDict saveTypes;
  ArrayList<Wall> walls;

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

    grList = new ArrayList<BackParams>();
    walls = new ArrayList<Wall>();
    attackers = new ArrayList<SoldierBasic>();
    defenders = new ArrayList<SoldierBasic>();

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
    /*
    backgr.stroke(180);
    for (int i = 0; i < mGridCols; i++) 
    {
      backgr.line(i*mBlockSz, 0, i*mBlockSz, sz.y);
    }

    for (int j = 0; j < mGridRows; j++) 
    {
      backgr.line(0, j*mBlockSz, sz.x, j*mBlockSz);
    }
    */
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
    backgr.beginDraw();

    backgr.image(ground.getRandTile(), x, y);

    backgr.endDraw(); 

    // add to list for saving purposes 
    BackParams bck = new BackParams(
      new PVector(x, y), 
      ground.path, 
      new PVector(ground.xLast, ground.yLast));
    add2GrList(bck);
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
    if (screen.mTrStart)return;
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));
    int x = (int) target.x;
    int y = (int) target.y;
    x = x/mBlockSz*mBlockSz;
    y = y/mBlockSz*mBlockSz;
    
    backgr.beginDraw();
    PGraphics tile = tlPck.getSelectedTile();
    if(tile != null) 
      backgr.image(tile, x, y);

    backgr.endDraw(); 
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

  void add2GrList(BackParams bck) 
  {
    // check if same position occupied 
    ArrayList<BackParams> toRemove = new ArrayList<BackParams>();
    for (BackParams bp : grList)
    {
      PVector itemList = bp.pos;
      PVector itemNew = bck.pos;
      if (itemList.x == itemNew.x && itemList.y == itemNew.y)
      {
        // remove old one from the list
        toRemove.add(bp);
      }
    }

    for (BackParams re : toRemove) 
    {
      grList.remove(re);
    }

    // add to list
    grList.add(bck);
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

    // Standard map size
    TableRow newRow = table.addRow(); 
    newRow.setInt("type", LevelLoaderTypes.map.ordinal()); 
    newRow.setInt("x", (int) mGridCols); 
    newRow.setInt("y", (int) mGridRows); 
    newRow.setInt("param1", (int)  mBlockSz);

    // Backs save
    for (BackParams bp : grList) 
    {
      newRow = table.addRow(); 
      newRow.setInt("type", LevelLoaderTypes.back.ordinal()); 
      newRow.setInt("x", (int)  bp.pos.x); 
      newRow.setInt("y", (int)  bp.pos.y); 
      newRow.setString("file", bp.tileName);
      newRow.setInt("param1", (int)  bp.tilePos.x); 
      newRow.setInt("param2", (int)  bp.tilePos.y);
    }

    if (path != null) 
    {
      String filePath =path+"/"+levelName+".csv";
      saveTable(table, filePath);
      println("test file saved to: "+filePath);
    } else return false;

    return ret;
  }

  boolean loadFromFile() 
  {
    boolean ret = false;
    String path = Storage.createFolder(levelFolder);
    if (path != null) 
    {
      // Crear previous data
      grList.clear();
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

        // Load data according to type
        switch(type)
        {
        case map:
          mGridCols = x;
          mGridRows = y;
          mBlockSz = param1;
          break;
        case back:
          PVector p = new PVector(x, y);
          String tn = file;
          PVector tp = new PVector(param1, param2);
          String backsDir = dataPath(Storage.dataDirBacks); 
          ground = new LoadTile(backsDir+"/" + tn, 16); 
          backgr.beginDraw();
          backgr.image(ground.getTile((int) tp.x, (int) tp.y), x, y);
          backgr.endDraw(); 

          BackParams b = new BackParams(p, tn, tp);
          grList.add(b);
          break;
        case wall:
          break;
        case unit:
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
