abstract class Object
{
  PVector position;
  PVector size;
  PVector orig; // Local origin
  boolean active = true; // Used for collisions and separations
  boolean reqDelete = false;
  
  void setOrig(PVector o)
  {
    orig = o;
  } 
  
  void delete() 
  {
    reqDelete = true;
  }
  
  boolean posInside(PVector pos) 
  {
    if (pos.x > (position.x - size.x/2) && 
      pos.x < (position.x + size.x/2) && 
      pos.y > (position.y - size.y/2) && 
      pos.y < (position.y + size.y/2))  
      return true;
    return false;
  }
  
  boolean intersects(Object obj) 
  {
    PVector p1 = position;
    PVector s1 = size;
    PVector p2 = obj.position;
    PVector s2 = obj.size;

    if ((p1.x < p2.x+s2.x) && (p1.x+s1.x > p2.x) &&
      (p1.y < p2.y+s2.y) && (p1.y+s1.y > p2.y))
    {
      return true;
    }
    return false;
  }
  
  PVector getPos() 
  {
    if(position == null || orig == null) 
    {
      return null;
    }
    return new PVector(position.x+orig.x, 
                       position.y+orig.y);
  }
  
  abstract void draw();
}