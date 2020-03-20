// No walls and paths, just two groups going to target pos
class Test4 extends Level
{
  Renderer r;

  ArrayList<SoldierBasic> soldiers;
  ArrayList<SoldierBasic> soldiers2;

  LoadTile grass;
  PImage backgr;

  Test4() 
  {
    String backsDir = dataPath(Storage.dataDirBacks); 
    grass = new LoadTile(backsDir+"/" + "grass1.png",16); 
    
    r = new Renderer();
    
    createBackgr();

    reset();
  }
  
  void reset() 
  {
    soldiers = new ArrayList<SoldierBasic>();
    soldiers2 = new ArrayList<SoldierBasic>();

    int numOfAttackers = 100;
    int numOfDefenders = 100;

    for (int i = 0; i < numOfAttackers; i++) 
    {
      SoldierBasic s1 = new SoldierBasic(
        scr.mWidth*i/(2*numOfAttackers)+
        scr.mWidth/2-scr.mWidth*(numOfAttackers/2)/(2*numOfAttackers), 
        scr.mHeight, 
        "BasicSpearman");
      s1.primaryTarget = new PVector(scr.mWidth/2, scr.mHeight/4);
      s1.target = s1.primaryTarget;
      s1.setDir(Dirs.LD);
      s1.setState(States.attack);
      soldiers.add(s1);
    }

    for (int i = 0; i < numOfDefenders; i++) 
    {
      SoldierBasic s2 = new SoldierBasic(
        scr.mWidth*i/(3*numOfDefenders)+
        scr.mWidth/2-scr.mWidth*(numOfDefenders/2)/(3*numOfDefenders), 
        0, 
        "BasicArcher");
      s2.primaryTarget = new PVector(scr.mWidth/2, scr.mHeight*3/4);
      s2.target = s2.primaryTarget;
      s2.setDir(Dirs.LD);
      s2.setState(States.attack);
      soldiers2.add(s2);
    }
  }

  void update() 
  {
    r.clear();

    for (SoldierBasic s : soldiers) 
    {
      s.update(soldiers, soldiers2, null, null);
      r.add(s);
    }

    for (SoldierBasic s : soldiers2) 
    {
      s.update(soldiers2, soldiers, null, null);
      r.add(s);
    }

    boolean anyLeft = false;
    // Evaluate deads after all actions performed
    for (SoldierBasic s : soldiers) 
    {
      if(s.stillAlive()) anyLeft = true;
    }
    if(!anyLeft)reset();
    
    anyLeft = false;
    for (SoldierBasic s : soldiers2) 
    {
      if(s.stillAlive()) anyLeft = true;
    }
    if(!anyLeft)reset(); 
    
    setTargetEnemies();
  }
  
  void mouseClicked() 
  {
    setTargetMouse();
  }

  void draw() 
  {
    background(0);
    
    image(backgr, 0, 0, 
          backgr.width, backgr.height);
          
    if(debug) 
    {
      PVector target = scr.screen2World(new PVector(mouseX, mouseY));
      fill(120);
      ellipse(target.x, target.y, 20, 20);
    }
    
    update();
    r.draw();
  }
  
  void createBackgr() 
  {
    // draw grass with tiles
    int side = grass.getTileSide();
    int rs = (int) (scr.mWidth/(side)+1) ;
    int hs = (int) (scr.mHeight/(side)+1) ;
    backgr = createImage(rs*side, hs*side, ARGB);
    
    for(int i = 0 ; i <= rs ; i++) 
    {
      for(int j = 0 ; j <= hs ; j++) 
      {
        backgr.copy(
         grass.getRandTile(), 
                       0,0,side,side,
                       i*side,j*side,side,side);
          
      }
    }
  }
  
  void mouseClickedEvent() 
  {
    setTargetMouse();
  }
  
  void setTargetMouse() 
  {
    PVector target = scr.screen2World(new PVector(mouseX, mouseY));
    
    // Set targets as last mouse click
    // create little formation 4x3
    int x = 0;
    int y = 0;
    int xN = 4;
    int yN = 3;
    int r = 20;
    for (SoldierBasic s1 : soldiers)
    {
      s1.setTarget(new PVector(
       target.x-xN*r+x*r, target.y+yN*r+y*r));
      x++;
      if(x >= xN) 
      {
        x = 0;
        y++;
      }
    }
    
    x = 0;
    y = 0;
    xN = 3;
    yN = 3;
    for (SoldierBasic s2 : soldiers2)
    {
      s2.setTarget(new PVector(
      target.x-xN*r+x*r, target.y-yN*r+y*r));
      x++;
      if(x >= xN) 
      {
        x = 0;
        y++;
      }
    }
    
  }

  void setTargetEnemies() 
  {
    // Set attack targets
    for (SoldierBasic s1 : soldiers)
    {
      s1.findNearestEnemy(soldiers2);
    }
    for (SoldierBasic s2 : soldiers2)
    {
      s2.findNearestEnemy(soldiers);
    }
  }
}
