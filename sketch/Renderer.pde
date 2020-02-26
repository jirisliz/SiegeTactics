class Renderer
{
  ArrayList<ArrayList<Object>> objects;
  ArrayList<Object> back;
  
  Renderer() 
  {
    objects = new ArrayList<ArrayList<Object>>();
    for(int i = 0 ; i < displayHeight; i++) 
    {
      objects.add(new ArrayList<Object>());
    }
    back = new ArrayList<Object>();
  }
  
  void add(Object o) 
  {
    int pos = (int) o.getPos().y;
    if(pos < 0 || pos >= objects.size()) 
    {
      return;
    }
    if(o.active)
    {
      objects.get(pos).add(o);
    }
    else
    {
      back.add(o);
    }
  }
  
  void clear() 
  {
    for(int i = 0 ; i < objects.size() ; i++) 
    {
      ArrayList<Object> line = objects.get(i);
      line.clear();
    }
    back.clear();
  }
  
  void draw() 
  {
    for(Object o : back) 
    {
      o.draw();
    }
    for(ArrayList<Object> line : objects) 
    {
      if(line != null) 
      {
        for(Object o : line) 
        {
          o.draw();
        }
      }
    }
  }
}