import android.view.KeyEvent;

// Debug data rendering
static boolean debug = false; 
Screen scr;

MainMenu main;

int state = 0;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  //frameRate(20);

  noSmooth();
  fill(0);

  main = new MainMenu();
}

void draw() 
{
  main.draw();
}  

void mousePressed() 
{
  main.mousePressed();
}

void mouseDragged() 
{
  main.mouseDragged();
}

void mouseReleased() 
{
  main.mouseReleased();
}

void onBackPressed() 
{
  main.onBackPressed();
}


/*

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
 */