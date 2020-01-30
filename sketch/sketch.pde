// Debug data rendering
static boolean debug = false;

// Global scale - mltiply num of pixels
boolean mScaling = false;
static float mScale = 1;
float mScaleOld = 1;
float mDistOld = 0;
float mScaleMin = 0.5;
float mScaleMax = 6;
boolean mTransl = false;
static float mTransX, mTransY;
float mTransXOld = 0, mTransYOld = 0;
float mTransXSt = 0, mTransYSt = 0;
boolean mTrStart = false;
PVector mF1Old, mF2Old;

// Game base size
int mWidth = 600;
int mHeight = 800;

Level level;

void setup() 
{
  orientation(PORTRAIT);
  //size( displayWidth , displayHeight , P2D);
  fullScreen();

  //frameRate(20);

  noSmooth();
  fill(0);

  level = new Test4();

  mTransX = 0;
  mTransY = 0;
}

void draw() 
{

  pushMatrix();
  scale(mScale);
  translate(mTransX, mTransY);
  level.draw();
  popMatrix();

  if (debug) 
  {
    textSize(30);
    fill(5);
    textAlign(CENTER);
    text("transX="+mTransX +" transY="+mTransY, 
      width/2, 300);
    text("transXOld="+mTransXOld +" transYOld="+mTransYOld, 
      width/2, 350);
    text("touches=" + touches.length, width/2, 400);
    text("mTrStart=" + mTrStart + 
      " mTransl="+mTransl +
      " mScaling="+mScaling+",mScale"+mScale, 
      width/2, 450);
  }


  checkTouch();
}

void checkTouch() 
{
  if (touches.length == 0) 
  {
    mTrStart = false;
    mTransl = false;
    mScaling = false;
  }
}

void mousePressed() 
{
  if (touches.length == 0) 
  {
    level.mouseClickedEvent();
  }
}

void mouseDragged() 
{
  // Check two fingers
  if (touches.length == 2) 
  {
    // Get fingers positions
    PVector f1 = new PVector(touches[0].x, touches[0].y);
    PVector f2 = new PVector(touches[1].x, touches[1].y);

    // Init start touch vars
    if (!mTrStart) 
    {
      mTrStart = true;
      mTransXSt = mouseX;
      mTransYSt = mouseY;
      mTransXOld = mTransX;
      mTransYOld = mTransY;
      mF1Old = f1.copy();
      mF2Old = f2.copy();
      mScaleOld = mScale;
      mDistOld = PVector.dist(f1, f2);
      return;
    }

    // Check distance change and transl. change
    float d1 = PVector.dist(mF1Old, f1);
    float d2 = PVector.dist(mF2Old, f2);
    if (d1 > width/10 && d2 > width/10) 
    {
      PVector sub1 = PVector.sub(mF1Old, f1);
      PVector sub2 = PVector.sub(mF2Old, f2);
      float a1 = sub1.heading();
      float a2 = sub2.heading();

      // If both fingers move same dir then translate
      if (abs(a1 - a2) < PI/8)
      {
        mTransl = true;
      } else // othervise scale
      {
        mScaling = true;
      }
      if (debug)
      {
        text("a1=" + a1 + ",a2=" + a2, width/2, 500);
        text("f1=" + f1 + ",f2=" + f2, width/2, 550);
        text("mF1Old=" + mF1Old + ",mF2Old=" + mF2Old, width/2, 600);
        text("mF1Old-f1=" + sub1 +
          ",mF2Old-f2=" + sub2, width/2, 650);
      }
    }

    if (mTransl) 
    {
      float xDif = mouseX - mTransXSt;
      float yDif = mouseY - mTransYSt;
      mTransX = mTransXOld + xDif/mScale;
      mTransY = mTransYOld + yDif/mScale;
    }

    if (mScaling) 
    {
      float scl = (PVector.dist(f1, f2)-mDistOld) / (height/2);
      mScale = constrain(mScaleOld + scl, mScaleMin, mScaleMax);
    }
  }
}

void mouseReleased() 
{
  mTrStart = false;
}