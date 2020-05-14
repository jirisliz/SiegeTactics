enum LevelLoaderTypes
{
  map, back, obj, barr, unit;
}

class LevelLoader extends Level 
{
  Renderer r;

  ArrayList<SoldierBasic> attackers;
  ArrayList<SoldierBasic> defenders;

  LoadTile ground;
  BackParams[][] bckgs; 
  StringDict saveTypes;
  ArrayList<Barrier> barrs;
  ArrayList<TileObject> objs;

  // Selections
  PGraphics backgr;
  String unitName = Defs.units[0];

  String levelName;
  String levelFolder = Storage. levelsFolder;

  boolean viewBck = true;
  boolean viewObj = true;
  boolean viewBarr = true;
  boolean viewUnit = true;
  
  boolean moving = true;
  boolean adding = false;

  //For moving objects and units
  Object selectedObj;

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
    barrs = new ArrayList<Barrier>();
    attackers = new ArrayList<SoldierBasic>();
    defenders = new ArrayList<SoldierBasic>();
    objs = new ArrayList<TileObject>();

    // Draw grid 
    drawGrid();
  }
  
  boolean isSelected() 
  {
    return selectedObj != null; 
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

  void drawSelObj() 
  {
    if (selectedObj != null) 
    {
      pushStyle();
      noFill();
      stroke(30, 250, 30);
      int x = (int) (selectedObj.position.x - selectedObj.size.x/2);
      int y = (int) (selectedObj.position.y - selectedObj.size.y/2);
      int w = (int) selectedObj.size.x;
      int h = (int) selectedObj.size.y;

      rect(x, y, w, h);
      popStyle();
    }
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

  PVector fitGrid(PVector v, int gridSz) 
  {
    PVector ret = new PVector(v.x, v.y);
    ret.x = (int)ret.x/gridSz*gridSz;
    ret.y = (int)ret.y/gridSz*gridSz;

    return ret;
  }
  
  void deleteSelected() 
  {
    if(selectedObj != null) 
    {
      selectedObj.delete();
      checkDeleteRequests();
      selectedObj = null;
    }
  }
  
  void checkDeleteRequests() 
  { 
    // objs
    objs.remove(selectedObj);
    
    // barrs
    barrs.remove(selectedObj);
    
    // units
    attackers.remove(selectedObj);
    defenders.remove(selectedObj);
  }
  
  void setAdding() 
  {
    moving = false;
    adding = true;
  }
  
  void setMoving() 
  {
    moving = true;
    adding = false;
  }

  void update() 
  {
    r.clear(); 
    if (viewUnit) 
    {
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

    if (viewObj) 
    {
      for (TileObject t : objs) 
      {
        r.add(t);
      }
    }
  }

  void draw() 
  {
    if (viewBck)image(backgr, 0, 0);
    update();
    r.draw();
    if(viewBarr) 
    {
      for(Barrier b : barrs) 
      {
        b.draw();
      }
    } 
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

    if (screen.selFinished) 
    {
      clickBackrDrag(screen);
      return;
    }

    PVector target = screen.screen2World(new PVector(mouseX, mouseY));

    addBackgr(target);
  }

  boolean checkObjInPos(ArrayList list, PVector pos) 
  {
    for (int i = 0; i < list.size(); i++)
    {
      sketch.Object o = (sketch.Object) list.get(i);
      if (o.posInside(pos)) 
      {
        selectedObj = o;
        return true;
      }
    }
    selectedObj = null;
    return false;
  }
  
  boolean moveSelectedObj(Screen screen, PVector target) 
  {
    return moveSelectedObj(screen, target, true);
  }
  
  boolean moveSelectedObj(Screen screen, PVector target, boolean fitGrid) 
  {
    if(!moving) return false;
    // move if object selected and dragged 
    if (screen.selFinished && selectedObj != null) 
    {
      PVector start = screen.screen2World(screen.touchStart);
      PVector end = screen.screen2World(screen.touchEnd);
      
      if(fitGrid) 
      {
        start = fitGrid(start, mBlockSz/2);
        end = fitGrid(end, mBlockSz/2); 
      }
      
      if (selectedObj.posInside(start))
      {
        selectedObj.position.x += end.x - start.x;
        selectedObj.position.y += end.y - start.y;
      }
      return true;
    }

    if (selectedObj != null) 
    {
      if (!selectedObj.posInside(target)) 
      {
        // deselect object
        selectedObj = null;
        return true;
      }
    }
    return false;
  }

  void clickObjs(Screen screen, TilePicker tlPck) 
  {
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));
    int x = (int) target.x;
    int y = (int) target.y;

    // Use half of the block to move with objects
    int blockDiv = mBlockSz/2;
    x = x/blockDiv*blockDiv;
    y = y/blockDiv*blockDiv;
    
    if(moveSelectedObj(screen, target)) return;

    // select object if clicked
    if(checkObjInPos(objs, new PVector(x, y))) 
    {
      return;
    }
    
    if (screen.mTrStart || tlPck == null)return;
    if(!adding) return;
    // add new object
    TileObject t = tlPck.getSelectedTileObject();
    t.setLocation(new PVector(x, y));

    objs.add(t);
  }

  void clickBarr(Screen screen) 
  {
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));
    int x = (int) target.x;
    int y = (int) target.y;
    
    if(moveSelectedObj(screen, target)) return; 
    
    // select object if clicked
    if(checkObjInPos(barrs, new PVector(x, y))) 
    {
      return;
    }
    
    if(!adding) return;

    if (screen.selFinished) 
    {
      PVector start = screen.screen2World(screen.touchStart);
      PVector end = screen.screen2World(screen.touchEnd);

      IntHolder sx = new IntHolder((int) (start.x));
      IntHolder sy = new IntHolder((int) (start.y)) ;
      IntHolder ex = new IntHolder((int) (end.x));
      IntHolder ey = new IntHolder((int) (end.y));

      if (sx.val> ex.val) Defs.swap(sx, ex);
      if (sy.val> ey.val) Defs.swap(sy, ey);

      PVector sz = new PVector(ex.val- sx.val, ey.val - sy.val);
      PVector pos = new PVector(sx.val, sy.val);

      Barrier newBarr = new Barrier(pos, sz);

      barrs.add(newBarr);
    }
  }

  void clickUnits(Screen screen, boolean isAttacker) 
  {
    if (screen.mTrStart)return;
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));
    int x = (int) target.x;
    int y = (int) target.y;
    
    if(moveSelectedObj(screen, target, false)) return; 
    
    // select object if clicked
    if(checkObjInPos(attackers, new PVector(x, y))) 
    {
      return;
    }
    
    if(checkObjInPos(defenders, new PVector(x, y))) 
    {
      return;
    }
    
    if(!adding) return;

    SoldierBasic s1 = new SoldierBasic(
      x, y, 
      unitName);
    s1.setState(States.stand);
    s1.dir = Dirs.RD;
    if(!isAttacker)s1.teamNum = 1;
    if(isAttacker) attackers.add(s1);
    else defenders.add(s1);
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
      newRow.setInt("param3", (int)  to.size.x); 
      newRow.setInt("param4", (int)  to.size.y);
    }
    
    for (Barrier b : barrs) 
    {
      newRow = table.addRow(); 
      newRow.setInt("type", LevelLoaderTypes.barr.ordinal()); 
      newRow.setInt("x", (int)  b.position.x); 
      newRow.setInt("y", (int)  b.position.y);
      newRow.setInt("param1", (int)  b.size.x); 
      newRow.setInt("param2", (int)  b.size.y);
    }

    for (SoldierBasic s : attackers) 
    {
      newRow = table.addRow(); 
      newRow.setInt("type", LevelLoaderTypes.unit.ordinal()); 
      newRow.setInt("x", (int)  s.position.x); 
      newRow.setInt("y", (int)  s.position.y);
      newRow.setString("file", s.unitType);
      newRow.setInt("param1", 0);
    }

    for (SoldierBasic s : defenders) 
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
  
  void clearLevelData() 
  {
    bckgsClear();
    objs.clear();
    barrs.clear();
    attackers.clear();
    defenders.clear();
    selectedObj = null;
  }

  boolean loadFromFile() 
  {
    boolean ret = false;
    String path = Storage.createFolder(levelFolder);
    
    // Clear prevoius data
    clearLevelData();
    
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
          
        case barr:
          PVector bp = new PVector(x-param1/2, y-param2/2);
          PVector bs = new PVector(param1, param2);
          Barrier barrNew = new Barrier(bp, bs);
          
          barrs.add(barrNew);
          
          break;
        case unit:

          SoldierBasic s1 = new SoldierBasic(
            x, y, 
            file);
          s1.setState(States.stand);
          s1.dir = Dirs.RD;
          s1.teamNum = param1;
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
