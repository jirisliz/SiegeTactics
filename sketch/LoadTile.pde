class LoadTile
{
  PImage tileImg; 
  int xNum, yNum;
  int xLast, yLast;
  float scale = 1;
  String path;
  
  LoadTile(String p, int axNum, int ayNum) 
  {
    path = p;
    tileImg = null;
    xNum = axNum;
    yNum = ayNum;
    try
    {
      tileImg = loadImage(path);
      File fn = new File(path);
      path = fn.getName();
    }
    catch(Exception e) 
    {
      println("image not loaded");
    }
  }
  
  LoadTile(String p, int sideSz) 
  {
    path = p;
    tileImg = null;
    try
    {
      tileImg = loadImage(path);
      File fn = new File(path);
      path = fn.getName();
      xNum = tileImg.width/sideSz;
      yNum = tileImg.height/sideSz;
    }
    catch(Exception e) 
    {
      println("image not loaded");
    }
  }
  
  int getWidth() 
  {
    if(tileImg != null) return tileImg.width;
    return 0;
  }
  
  int getHeight() 
  {
    if(tileImg != null) return tileImg.height;
    return 0;
  }
  
  int getTileSide() 
  {
    if(tileImg != null) return tileImg.width/xNum;
    return 0;
  }
  
  PImage getRandTile() 
  {
    int xTile = (int) random(0, ((float) xNum)-0.6);
    int yTile = (int) random(0, ((float) yNum)-0.6);
    return getTile(xTile, yTile);
  }
  
  PImage getTile(int x, int y) 
  {
    xLast = x;
    yLast = y;
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