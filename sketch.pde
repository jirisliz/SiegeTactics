boolean debug = false;

ArrayList<SoldierBasic> soldiers;
ArrayList<SoldierBasic> soldiers2;

Path path;

Grid grid;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  smooth();
  fill(0);

  newPath();
  
  grid = new Grid(30,60);

  soldiers = new ArrayList<SoldierBasic>();

  for (int i = 0; i < 40; i++) 
  {
    SoldierBasic s1 = new SoldierBasic(
                       random(0, width), 
                       random(0, height));
    s1.target = new PVector(width/2, height/4);
    soldiers.add(s1);
  }

  for (int i = 0; i < 40; i++) 
  {
    SoldierBasic s2 = new SoldierBasic(
                       random(0, width), 
                       random(0, height), 
                       "SoldierBasic2-walkUp.png", 
                       "SoldierBasic2-walkDown.png", 
                       "SoldierBasic2-walkLeft.png", 
                       "SoldierBasic2-walkRight.png");
    s2.target = new PVector(width/2, height*3/4);
    soldiers.add(s2);
  }
}

void draw() 
{
  background(70, 70, 100);

  if(path != null)path.display();

  for (SoldierBasic s : soldiers) 
  {
    s.applyBehaviors(soldiers, path, false);
    s.run();
    s.update();
    s.draw();
  }
}

void newPath() {
  // A path is a series of connected points
  // A more sophisticated path might be a curve
  path = new Path(50, color(175));
  
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
  
}