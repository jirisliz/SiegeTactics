class LoadTile
{
  PImage tileImg; 
  int xNum, yNum;
  
  LoadTile(String path, int axNum, int ayNum) 
  {
    tileImg = null;
    xNum = axNum;
    yNum = ayNum;
    try
    {
      tileImg = loadImage(path);
    }
    catch(Exception e) 
    {
      println("image not loaded");
    }
  }
  
  PImage getTile(int x, int y) 
  {
    if(x >= xNum || y >= yNum || 
       x < 0 || y < 0 || tileImg == null)
       return null;
    
    int w = tileImg.width*x/xNum;
    int h = tileImg.height*y/yNum;
    PImage ret = createImage(w, h, ARGB);
    return ret;
  }
}