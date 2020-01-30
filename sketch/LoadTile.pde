class LoadTile
{
  PImage tileImg; 
  int xNum, yNum;
  float scale = 1;
  
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
  
  int getTileSide() 
  {
    if(tileImg != null) return tileImg.width/xNum;
    return 0;
  }
  
  PImage getTile(int x, int y) 
  {
    if(x >= xNum || y >= yNum || 
       x < 0 || y < 0 || tileImg == null)
       return null;
    
    int w = tileImg.width/xNum;
    int h = tileImg.height/yNum;
    PImage ret = createImage(w, h, ARGB);
    ret.copy(tileImg,
             w*x, w*y, w, h, 
             0, 0, w, h);
    
    return ret;
  }
}