class SoldierBasic extends Unit
{
  String animFileWalkUp = "SoldierBasic1-walkUp.png";
  String animFileWalkDown = "SoldierBasic1-walkDown.png";
  String animFileWalkLeft = "SoldierBasic1-walkLeft.png";
  String animFileWalkRight = "SoldierBasic1-walkRight.png";
  
  SoldierBasic() 
  {
    loadAnim();
  }
  
  SoldierBasic(float x, float y, String aUp, 
       String aDown, String aLeft, String aRight) 
  {
    super(new PVector(x, y), random(1,2), 0.4);
    animFileWalkUp = aUp;
    animFileWalkDown = aDown;
    animFileWalkLeft = aLeft;
    animFileWalkRight = aRight;
    
    loadAnim();
    teamNum = 1;
  }
  
  SoldierBasic(float x, float y) 
  {
    super(new PVector(x, y), random(1,2), 0.4);
    loadAnim();
  }
  
  void loadAnim() 
  {
    // load animations
    animWalkUp = new LoadSprite(animFileWalkUp);
    animWalkDown = new LoadSprite(animFileWalkDown);
    animWalkLeft = new LoadSprite(animFileWalkLeft);
    animWalkRight = new LoadSprite(animFileWalkRight);
    
    updateCurrAnim();
  }
}