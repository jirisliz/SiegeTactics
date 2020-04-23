// This class handles camera movement and zooming
class Screen
{
  // Scale and translate
  boolean mScaling = false;
  float mScale = 1;
  float mScaleOld = 1;
  float mDistOld = 0;
  float mScaleMin = 0.5;
  float mScaleMax =10;
  boolean mTransl = false;
  float mTransX, mTransY;
  float mTransXOld = 0, mTransYOld = 0;
  float mTransXSt = 0, mTransYSt = 0;
  boolean mTrStart = false;
  PVector mF1Old, mF2Old;

  // Selection
  boolean selEnabled = false;
  boolean selFinished = false;
  PVector touchStart;
  PVector touchEnd;

  // Game base size
  int mWidth = 400;
  int mHeight = 800;

  int mOffX = width/2;
  int mOffY = height/2;

  boolean bordersCheck = true;

  Screen(int w, int h) 
  {
    mWidth = w;
    mHeight = h;

    init();
  }

  void init() 
  {
    // Set min zoom
    float mScaleMin1 = (float) displayWidth / (float) mWidth;
    float mScaleMin2 = (float) displayHeight / (float) mHeight;
    if (mScaleMin1 >= mScaleMin2) 
    {
      mScaleMin = mScaleMin1;
    } else
    {
      mScaleMin = mScaleMin2;
    }
    mScale = mScaleMin;

    mTransX = -mWidth/2;
    mTransY = -mHeight/2;
  }

  PVector world2Screen(PVector w) 
  {
    float sX = ((w.x + mTransX) * mScale + mOffX );
    float sY = ((w.y + mTransY) * mScale + mOffY );

    return new PVector(sX, sY);
  }

  PVector screen2World(PVector s) 
  {
    float wX = ((s.x-mOffX) / mScale) - (mTransX);
    float wY = ((s.y-mOffY)/ mScale) - (mTransY);

    return new PVector(wX, wY);
  }

  void fitWidth() 
  {
    mScaleMin = (float) displayWidth / (float) mWidth;
    mScale = mScaleMin;
  }

  void fitHeight() 
  {
    mScaleMin = (float) displayWidth / (float) mHeight;
    mScale = mScaleMin;
  }

  void addFrame(int sz) 
  {
    mHeight = mHeight+sz;
    //init();
  }

  // Call from draw before game displayed
  void transformPush() 
  {
    // move origin to screen center
    pushMatrix();
    translate(mOffX, mOffY);

    // do game scale and transtation
    pushMatrix();
    scale(mScale);
    translate(mTransX, mTransY);
  }

  // Call from draw after game displayed
  void transformPop() 
  {
    popMatrix();
    popMatrix();

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
    selFinished = false;
    if (selEnabled) 
    {
      touchStart = new PVector(mouseX, mouseY);
    }
  }


  void mouseDragged() 
  {
    // Check one finger
    if(touches.length == 1) 
    {
     if(selEnabled) 
     {
       pushStyle();
        noFill();
        stroke(30, 250, 30);
        PVector end= new PVector(mouseX-touchStart.x, 
          mouseY-touchStart.y);

        rect(touchStart.x, touchStart.y, end.x, end.y);
        popStyle();
     }
    }
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
        float scl = (PVector.dist(f1, f2)-mDistOld) / (mOffY);
        mScale = constrain(mScaleOld + scl*2, mScaleMin, mScaleMax);
      }

      if (bordersCheck) 
      {
        checkBorders();
      }
    }
  }
  
  void mouseReleased() 
  {
    if(selEnabled) 
    {
      if (touchStart.dist(new PVector(mouseX, mouseY)) > 16) 
      {
        touchEnd = new PVector(mouseX, mouseY);
        selFinished = true;
      }
      else touchEnd = null;
    }
  }

  void checkBorders() 
  {
    PVector sOrig = world2Screen(new PVector(0, 0));


    if (sOrig.x > 0)
    {
      sOrig.x -= mOffX;
      mTransX = screen2World(sOrig).x;
    }

    if (sOrig.y > 0)
    {
      sOrig.y -= mOffY;
      mTransY = screen2World(sOrig).y;
    }

    sOrig = world2Screen(new PVector(mWidth, mHeight));
    if (sOrig.x < width)
    { 
      mTransX = -mWidth+width/(2*mScale);
    }


    if (sOrig.y < height)
    {
      mTransY = -mHeight+height/(2*mScale);
    }
  }
}
