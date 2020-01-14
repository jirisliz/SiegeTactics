// Debug data rendering
boolean debug = false;

// Global scale - mltiply num of pixels
static int mScale = 3;

Test test;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  smooth();
  fill(0);
  
  test = new Test2();
}

void draw() 
{
  test.update();
  test.draw();
}
