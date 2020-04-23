class Barrier extends Object
{ 
  Barrier(PVector pos, PVector sz) 
  {
    size = sz;
    position = new PVector(pos.x+sz.x/2, pos.y+sz.y/2);
    orig = new PVector(sz.x/2, sz.y/2);
  }

  void draw() 
  {
    pushStyle();
    noFill();
    stroke(250, 30, 30);
    int x = (int) (position.x - size.x/2);
    int y = (int) (position.y - size.y/2);
    int w = (int) size.x;
    int h = (int) size.y;

    rect(x, y, w, h);
    popStyle();
  }
}
