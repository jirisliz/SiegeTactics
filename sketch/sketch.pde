import android.view.MotionEvent;
import ketai.ui.*;

KetaiGesture gesture;

// Debug data rendering
static boolean debug = true;

// Global scale - mltiply num of pixels
static float mScale = 1;
float mScaleMin = 1;
float mScaleMax = 13;

Level level;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  gesture = new KetaiGesture(this);

  //frameRate(20);

  noSmooth();
  fill(0);

  level = new Test4();
}

void draw() 
{
  level.draw();
}

void mousePressed() 
{
  level.mouseClickedEvent();
}

void mouseDragged() 
{
}

void mouseReleased() 
{
}

void onPinch(float x, float y, float d)
{

  mScale = constrain(mScale + d/100, mScaleMin, mScaleMax);

  if (debug) 
  {
    textSize(30);
    fill(5);
    textAlign(CENTER);
    text("scale="+mScale+" x="+x+",y="+y, 
      width/2, 200);
  }
}

public boolean surfaceTouchEvent(MotionEvent event) {

  //call to keep mouseX, mouseY, etc updated
  super.surfaceTouchEvent(event);

  //forward event to class for processing
  return gesture.surfaceTouchEvent(event);
}
