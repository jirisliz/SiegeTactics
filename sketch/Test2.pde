// Soldiers walking path
class Test2 extends Test
{
  Renderer r;

  Path path, path2;

  ArrayList<SoldierBasic> soldiers;
  ArrayList<SoldierBasic> soldiers2;

  ArrayList<Wall> walls;

  Test2() 
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
        width*i/(2*numOfAttackers)+
        width/2-width*(numOfAttackers/2)/(2*numOfAttackers), 
        height*4/5);
      s1.primaryTarget = new PVector(width/2, height/4);
      s1.setDir(Dirs.LD);
      s1.setState(States.walk);
      soldiers.add(s1);
    }

    for (int i = 0; i < numOfDefenders; i++) 
    {
      SoldierBasic s2 = new SoldierBasic(
        width*i/(3*numOfDefenders)+
        width/2-width*(numOfDefenders/2)/(3*numOfDefenders), 
        height/5, 
        "BasicSpearman2");
      s2.primaryTarget = new PVector(width/2, height*3/4);
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
      s.update(soldiers2, soldiers, path2, walls);
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
    walls.add(new Wall(new PVector(0, 500), width/3, 40));
    //walls.add(new Wall(new PVector(width/2-250,height/2), 500, 40));
    walls.add(new Wall(new PVector(width*2/3, 500), width/3, 40));
  }

  void newPath() {
    // A path is a series of connected points
    // A more sophisticated path might be a curve
    path = new Path(150, color(175));

    path.addPoint(width/2, 380);
    path.addPoint(width/2, 520);

    /*
  float offset = 150;
     //path.addPoint(offset,offset);
     path.addPoint(width-offset, offset);
     path.addPoint(width-offset, height-offset);
     
     path.addPoint(width-offset, height-offset);
     path.addPoint(offset, height-offset);
     
     path.addPoint(offset, height-offset);
     path.addPoint(offset, offset);
     
     path.addPoint(offset, offset);
     path.addPoint(width-offset, offset);
     
     //path.addPoint(width/2, offset);
     //path.addPoint(width/2, height/2);
     */

    path2 = new Path(60, color(175));

    path2.addPoint(width/3+50, 500);
    path2.addPoint(width*2/3 - 50, 500);
  }
}
