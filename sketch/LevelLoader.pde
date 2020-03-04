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
  PGraphics backgr;

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

  void init() 
  {
    ground = new LoadTile("grass1.png", 3, 3);
    grList = new ArrayList<BackParams>();
    walls = new ArrayList<Wall>();
    attackers = new ArrayList<SoldierBasic>();
    defenders = new ArrayList<SoldierBasic>();

    // Draw grid
    PVector sz = getLevelSize();
    backgr = createGraphics((int) sz.x, (int) sz.y);
    backgr.beginDraw();
    backgr.background(50, 50, 130);
    backgr.stroke(180);
    for (int i = 0; i < mGridCols; i++) 
    {
      backgr.line(i*mBlockSz, 0, i*mBlockSz, sz.y);
    }

    for (int j = 0; j < mGridRows; j++) 
    {
      backgr.line(0, j*mBlockSz, sz.x, j*mBlockSz);
    }

    backgr.endDraw();
  }

  void update() 
  {
  }

  void draw() 
  {
    image(backgr, 0, 0);
  }

  void mouseReleased(Screen screen) 
  {
    PVector target = screen.screen2World(new PVector(mouseX, mouseY));
    int x = (int) target.x;
    int y = (int) target.y;
    x = x/mBlockSz*mBlockSz;
    y = y/mBlockSz*mBlockSz;
    backgr.beginDraw();
    int xTile = (int) random(0, 2.4);
    int yTile = (int) random(0, 2.4);
    backgr.image(ground.getTile(xTile, yTile), x, y);

    backgr.endDraw(); 

    // add to list for saving purposes 
    BackParams bck = new BackParams(
      new PVector(x, y), 
      ground.path, 
      new PVector(xTile, yTile));
    add2GrList(bck);
  }
  
  void add2GrList(BackParams bck) 
  {
    // check if same position occupied 
    ArrayList<BackParams> toRemove = new ArrayList<BackParams>();
    for (BackParams bp : grList)
    {
      PVector itemList = bp.pos;
      PVector itemNew = bck.pos;
      if(itemList.x == itemNew.x && itemList.y == itemNew.y)
      {
        // remove old one from the list
        toRemove.add(bp);
      }
    }
    
    for(BackParams re : toRemove) 
    {
      grList.remove(re);
    }
    
    // add to list
    grList.add(bck);
  }

  boolean save2File() 
  {
    boolean ret = false;
    //levelName = "test.csv";

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
