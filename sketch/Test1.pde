// Soldiers walking path
class Test1 extends Level
{
  Renderer r;

  Path path, path2;

  ArrayList<SoldierBasic> soldiers;
  ArrayList<SoldierBasic> soldiers2;

  ArrayList<Wall> walls;

  Test1() 
  {

    r = new Renderer();

    newWalls();

    newPath();

    soldiers = new ArrayList<SoldierBasic>();
    soldiers2 = new ArrayList<SoldierBasic>();

    int numOfAttackers = 20;
    int numOfDefenders = 20;

    for (int i = 0; i < numOfAttackers; i++) 
    {
      SoldierBasic s1 = new SoldierBasic(
        scr.mWidth*i/(2*numOfAttackers)+
        scr.mWidth/2-scr.mWidth*(numOfAttackers/2)/(2*numOfAttackers), 
        scr.mHeight*4/5);
      s1.primaryTarget = new PVector(scr.mWidth/2, scr.mHeight/4);
      s1.setDir(Dirs.LD);
      s1.setState(States.walk);
      soldiers.add(s1);
    }

    for (int i = 0; i < numOfDefenders; i++) 
    {
      SoldierBasic s2 = new SoldierBasic(
        scr.mWidth*i/(3*numOfDefenders)+
        scr.mWidth/2-scr.mWidth*(numOfDefenders/2)/(3*numOfDefenders), 
        scr.mHeight/5, 
        "BasicSpearman2");
      s2.primaryTarget = new PVector(scr.mWidth/2, scr.mHeight*3/4);
      s2.setDir(Dirs.LD);
      s2.setState(States.walk);
      soldiers2.add(s2);
    }
  }

  void update() 
  {
    r.clear();

    for (SoldierBasic s : soldiers) 
    {
      s.update(soldiers, soldiers2, path, walls);
      r.add(s);
    }

    for (SoldierBasic s : soldiers2) 
    {
      s.update(soldiers2, soldiers, path, walls);
      r.add(s);
    }

    for (Wall wall : walls) 
    {
      r.add(wall);
    }

    // Evaluate deads after all actions performed
    for (SoldierBasic s : soldiers) 
    {
      s.stillAlive();
    }
    for (SoldierBasic s : soldiers2) 
    {
      s.stillAlive();
    }

    setTargetEnemies();
  }

  void draw() 
  {
    background(255);
    if (path != null)path.display();
    if (path2 != null)path2.display();
    update();
    r.draw();
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

  void newWalls() 
  {
    walls = new ArrayList<Wall>();
    walls.add(new Wall(new PVector(20, scr.mHeight/3), 50, 40));
    walls.add(new Wall(new PVector(scr.mWidth-27, scr.mHeight/3), 50, 40));
  }

  void newPath() {
    // A path is a series of connected points
    // A more sophisticated path might be a curve
    path = new Path(20, color(175));

    float offset = 20;
    //path.addPoint(offset,offset);
    path.addPoint(scr.mWidth-offset, offset);
    path.addPoint(scr.mWidth-offset, scr.mHeight-offset);

    path.addPoint(scr.mWidth-offset, scr.mHeight-offset);
    path.addPoint(offset, scr.mHeight-offset);

    path.addPoint(offset, scr.mHeight-offset);
    path.addPoint(offset, offset);

    path.addPoint(offset, offset);
    path.addPoint(scr.mWidth-offset, offset);
  }
}
