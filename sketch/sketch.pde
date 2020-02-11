// Debug data rendering
static boolean debug = false;

Screen scr;

Level level;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  //frameRate(20);

  noSmooth();
  fill(0);
  
  scr = new Screen(400,800);

  level = new Test4();
}

void draw() 
{
  scr.transformPush();

  level.draw();

  scr.transformPop();
}

void mousePressed() 
{
}

void mouseDragged() 
{
  scr.mouseDragged();
}

void mouseReleased() 
{
  if (touches.length == 1 && !scr.mTrStart) 
  {
    level.mouseClickedEvent();
  }
}
