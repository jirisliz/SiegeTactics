class LoadSprite
{
  PImage sprImg, currImg;
  int frames = 0;
  int currFrame = 0;
  float scale = mScale;

  LoadSprite(String path) 
  {
    sprImg = null;
    try
    {
      sprImg = loadImage(path);

      //sprImg.resize(sprImg.width*scale,
      //              sprImg.height*scale);
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

  void update() 
  {
    if(sprImg == null) return;
    currFrame += 1;
    if (currFrame >= frames) 
    {
      currFrame = 0;
    }
    currImg.copy(sprImg, currFrame*sprImg.height, 
      0, sprImg.height, sprImg.height, 
      0, 0, sprImg.height, sprImg.height);
  }

  void draw(float x, float y) 
  {
    if(sprImg == null) 
    {
      fill(100);
      stroke(0);
      strokeWeight(2);
      rect(x-16*mScale/2, y-16*mScale/2, 
      16*mScale, 16*mScale);
    }
    else
   {
     image(currImg, x-currImg.width*mScale/2, y-currImg.height*mScale/2, 
      currImg.width*mScale, currImg.height*mScale);
   }
    
  }
}
