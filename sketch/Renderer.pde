class Renderer
{
  ArrayList<ArrayList<Object>> objects;
  
  Renderer() 
  {
    objects = new ArrayList<ArrayList<Object>>();
    for(int i = 0 ; i < displayHeight; i++) 
    {
      objects.add(new ArrayList<Object>());
    }
  }
  
  void add(Object o) 
  {
    int pos = (int) o.getPos().y;
    if(pos < 0 || pos >= objects.size()) 
    {
      return;
    }
    
    objects.get(pos).add(o);
  }
  
  void clear() 
  {
    for(int i = 0 ; i < objects.size() ; i++) 
    {
      ArrayList<Object> line = objects.get(i);
      line.clear();
    }
  }
  
  void draw() 
  {
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