abstract class Object
{
  PVector position;
  PVector orig; // Local origin
  
  void setOrig(PVector o)
  {
    orig = o;
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