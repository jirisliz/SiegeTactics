class Wall extends Object
{
  int w, h;
  
  Wall(PVector pos, int aW, int aH)
  {
    position = pos;
    orig = new PVector(aW/2, aH/2);
    w = aW;
    h = aH;
  } 
  
  void draw() 
  {
    stroke(200);
    strokeWeight(1);
    fill(120);
    rect(position.x, position.y, w, h);
  }
}