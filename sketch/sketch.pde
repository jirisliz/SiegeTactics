// Debug data rendering
static boolean debug = false;

// Global scale - mltiply num of pixels
static int mScale = 4;

Level level;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();
  
  //frameRate(40);

  smooth();
  fill(0);
  
  level = new Test3();
}

void draw() 
{
  level.draw();
}
