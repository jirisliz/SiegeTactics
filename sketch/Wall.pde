class Wall extends Object
{
  int w, h;
  int inside = 0;

  Wall(PVector pos, int aW, int aH)
  {
    position = pos;
    orig = new PVector(aW/2, aH/2);
    w = aW;
    h = aH;
  } 

  boolean intersects(Vehicle u) 
  {
    // increase border by radius of the unit
    int x1 = (int) position.x - (int) u.r;
    int y1 = (int) position.y - (int) u.r;
    int x2 = x1 + w + (int) u.r;
    int y2 = y1 + h + (int) u.r;
    int uX = (int) u.position.x;
    int uY = (int) u.position.y;

    // check intersection
    if (uX > x1 && uX < x2 &&
      uY > y1 && uY < y2) 
    {
      inside++;
      return true;
    }

    return false;
  }

  void draw() 
  {
    noStroke();
    strokeWeight(1);
    fill(170);
    rect(position.x, position.y, w, h/3);
    fill(120);
    rect(position.x, position.y + h/3, w, h*2/3);

    if (debug) 
    {
      textSize(30);
      fill(5);
      textAlign(CENTER);
      text(inside, position.x + w/2, position.y + h/2 + 10);

      inside = 0;
    }
  }
}
