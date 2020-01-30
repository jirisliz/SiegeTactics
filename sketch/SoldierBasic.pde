class SoldierBasic extends Unit
{
  
  SoldierBasic() 
  {
   
  }
  
  SoldierBasic(float x, float y, String name) 
  {
    super(name, new PVector(x, y), random(1,2), 0.4);
    
    teamNum = 1;
  }
  
  SoldierBasic(float x, float y) 
  {
    super("BasicSpearman", new PVector(x, y), random(1,2), 0.4);
  }
 
}