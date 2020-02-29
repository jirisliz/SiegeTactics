enum LevelLoaderStates
{
  grass, walls, units;
}

class LevelLoader extends Level 
{
  Renderer r;

  ArrayList<SoldierBasic> attackers;
  ArrayList<SoldierBasic> defenders;

  LoadTile ground;
  ArrayList<BackParams> grList;
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
    ground = new LoadTile("grass1.png",3,3);
    grList = new ArrayList<BackParams>();
    walls = new ArrayList<Wall>();
    attackers = new ArrayList<SoldierBasic>();
    defenders = new ArrayList<SoldierBasic>();

    // Draw grid
    PVector sz = getLevelSize();
    backgr = createGraphics((int) sz.x, (int) sz.y);
    backgr.beginDraw();
    backgr.background(50, 50,130);
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
    int xTile = (int) random(0,2.4);
    int yTile = (int) random(0,2.4);
    backgr.image(ground.getTile(xTile, yTile),x,y);
    
    backgr.endDraw(); 
    
    // add to list for saving purposes 
    grList.add(new BackParams(
                new PVector(x, y), 
                ground.path,
                new PVector(xTile, yTile)));
  }
  
  boolean save2File() 
  {
    boolean ret = false;
    levelName = "/test.csv";
    
    String path = Storage.createFolder(levelFolder);
    println(path);
    
    Table table = new Table(); 
    table.addColumn("id"); 
    table.addColumn("species"); 
    table.addColumn("name"); 
    TableRow newRow = table.addRow(); 
    newRow.setInt("id", table.getRowCount() - 1); 
    newRow.setString("species", "Panthera leo"); 
    newRow.setString("name", "Lion"); 
    
    if(path != null) 
    {
      String testPath =path+levelName;
      saveTable(table, testPath);
      println("test file saved to: "+testPath);
    }
    else return false;
    
    return ret;
  }
}

class BackParams
{
  PVector pos;
  String tileName;
  PVector tileSz;
  
  BackParams(PVector p, String tN, PVector tS) 
  {
    pos = p;
    tileName = tN;
    tileSz = tS;
  }
}
