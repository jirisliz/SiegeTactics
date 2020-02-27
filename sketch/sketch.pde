import android.view.KeyEvent;

// Debug data rendering
static boolean debug = false; 
boolean permissionWrite = false;
boolean permissionRead = false;
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

  requestPermission(
    "android.permission.WRITE_EXTERNAL_STORAGE", 
    "handlePermissionWrite");

  requestPermission(
    "android.permission.READ_EXTERNAL_STORAGE", 
    "handlePermissionRead");
    
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

void handlePermissionWrite(boolean granted)
{
  println("WRITE_EXTERNAL_STORAGE: "+granted); 
  permissionWrite = granted;
}

void handlePermissionRead(boolean granted)
{
  println("READ_EXTERNAL_STORAGE: "+granted); 
  permissionRead = granted;
}
