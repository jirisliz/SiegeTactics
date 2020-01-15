// No walls and paths, just two groups going to target pos
class Test3 extends Level
{
  Renderer r;

  ArrayList<SoldierBasic> soldiers;
  ArrayList<SoldierBasic> soldiers2;

  Test3() 
  {

    r = new Renderer();

    soldiers = new ArrayList<SoldierBasic>();
    soldiers2 = new ArrayList<SoldierBasic>();

    int numOfAttackers = 5;
    int numOfDefenders = 2;

    for (int i = 0; i < numOfAttackers; i++) 
    {
      SoldierBasic s1 = new SoldierBasic(
        width*i/(2*numOfAttackers)+
        width/2-width*(numOfAttackers/2)/(2*numOfAttackers), 
        height*4/5);
      s1.primaryTarget = new PVector(width/2, height/4);
      s1.target = s1.primaryTarget;
      s1.setDir(Dirs.LD);
      s1.setState(States.seek);
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
      s2.target = s2.primaryTarget;
      s2.setDir(Dirs.LD);
      s2.setState(States.seek);
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

    // Evaluate deads after all actions performed
    for (SoldierBasic s : soldiers) 
    {
      s.stillAlive();
    }
    for (SoldierBasic s : soldiers2) 
    {
      s.stillAlive();
    }

    //setTargetEnemies();
  }

  void draw() 
  {
    background(255);
    
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
}
