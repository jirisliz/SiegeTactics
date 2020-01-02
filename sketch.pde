boolean debug = false;

ArrayList<SoldierBasic> soldiers;

Path path;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  smooth();
  fill(0);

  newPath();

  soldiers = new ArrayList<SoldierBasic>();

  for (int i = 0; i < 40; i++) 
  {
    soldiers.add(
      new SoldierBasic(random(0, width), random(0, height)));
  }
}

void draw() 
{
  background(70, 70, 100);

  path.display();

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
  path = new Path();
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
