class LoadSprite
{
  PImage sprImg, currImg;
  int frames = 0;
  int currFrame = 0;
  float scale = mScale;

  // Real framerate divided by
  int animSpdCount = 0;
  int animSpdDiv = 1; 

  LoadSprite(String path) 
  {
    init(path);
  }

  LoadSprite(String path, int speedDiv) 
  {
    init(path);
    setSpeedDiv(speedDiv);
  } 

  void init(String path)
  {
    sprImg = null;
    try
    {
      sprImg = loadImage(path);

      // we suppose frames in one row
      frames = sprImg.width/sprImg.height;
      currImg = createImage(sprImg.height, 
        sprImg.height, ARGB);
      update();
    }
    catch(Exception e) 
    {
      println("image not loaded");
    }
  }

  void setSpeedDiv(int aDiv)
  {
    animSpdDiv = aDiv;
  }

  void update() 
  {
    if (sprImg == null) return;
    animSpdCount++;
    if (animSpdCount >= animSpdDiv)
    {
      animSpdCount = 0; 
      currFrame += 1;
      if (currFrame >= frames) 
      {
        currFrame = 0;
      }
      currImg.copy(sprImg, currFrame*sprImg.height, 
        0, sprImg.height, sprImg.height, 
        0, 0, sprImg.height, sprImg.height);
    }
  }

  void draw(float x, float y) 
  {
    if (sprImg == null) 
    {
      fill(100);
      stroke(0);
      strokeWeight(2);
      rect(x-16/2, y-16/2, 
        16, 16);
    } else
    {
      image(currImg, x-currImg.width/2, y-currImg.height/2, 
        currImg.width, currImg.height);
    }
  }
}
