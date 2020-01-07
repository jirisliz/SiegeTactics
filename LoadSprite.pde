class LoadSprite
{
  PImage sprImg, currImg;
  int frames = 0;
  int currFrame = 0;
  int scale = 3;
  
  LoadSprite(String path) 
  {
    sprImg = loadImage(path);
    
    //sprImg.resize(sprImg.width*scale,
    //              sprImg.height*scale);
    // we suppose frames in one row
    frames = sprImg.width/sprImg.height;
    currImg = createImage(sprImg.height, 
                          sprImg.height, RGB);
    update();
  }
  
  void update() 
  {
    currFrame += 1;
    if(currFrame >= frames) 
    {
      currFrame = 0;
    }
    currImg.copy(sprImg, currFrame*sprImg.height, 
         0, sprImg.height, sprImg.height, 
         0,0,sprImg.height, sprImg.height);
  }
  
  void draw(float x, float y) 
  {
    noSmooth();
    image(currImg, x-currImg.width*scale/2, y-currImg.height*scale/2, 
          currImg.width*scale, currImg.height*scale);
    smooth(4);
  }
}