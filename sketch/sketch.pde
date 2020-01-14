// Debug data rendering
boolean debug = false;

// Global scale - mltiply num of pixels
static int mScale = 3;

Level level;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  smooth();
  fill(0);
  
  level = new Test2();
}

void draw() 
{
  level.update();
  level.draw();
}
