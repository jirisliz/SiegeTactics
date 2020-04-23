class TileObject extends Object
{
  String fileName;
  PVector tilePos;
  PGraphics img;

  TileObject(String tName, PVector tPos, PVector tSz) 
  {
    fileName = tName;
    tilePos = tPos;
    size = tSz;
    orig = new PVector(tSz.x/4, tSz.y/4);
  }

  void setTileImg(PGraphics aImg) 
  {
    img = aImg;
  }

  void loadTileImg(PImage tileSet) 
  {
    PImage i = createImage((int) size.x, (int) size.y, ARGB);
    i.copy(tileSet, 
      (int) tilePos.x, (int) tilePos.y, 
      (int) size.x, (int) size.y, 
      0, 0, (int) size.x, (int) size.y);

    img = createGraphics(i.width, i.height);
    img.beginDraw();
    img.image(i, 0, 0);
    img.endDraw();
  }

  void setLocation(PVector loc) 
  {
    position = loc;
  }

  void draw() 
  {
    image(img, position.x-img.width/2, position.y-img.height/2, 
      img.width, img.height);
  }
}
