class SoldierBasic extends Unit
{
  String animFileWalkUp = "SoldierBasic1-walkUp.png";
  String animFileWalkDown = "SoldierBasic1-walkDown.png";
  String animFileWalkLeft = "SoldierBasic1-walkLeft.png";
  String animFileWalkRight = "SoldierBasic1-walkRight.png";
  
  String animFileAttackUp = "SoldierBasic1-attackUp.png";
  String animFileAttackDown = "SoldierBasic1-attackDown.png";
  String animFileAttackLeft = "SoldierBasic1-attackLeft.png";
  String animFileAttackRight = "SoldierBasic1-attackRight.png";
  
  
  SoldierBasic() 
  {
    loadAnim();
  }
  
  SoldierBasic(float x, float y, String aUp, 
       String aDown, String aLeft, String aRight, 
       String aAUp, 
       String aADown, String aALeft, String aARight) 
  {
    super(new PVector(x, y), random(1,2), 0.4);
    animFileWalkUp = aUp;
    animFileWalkDown = aDown;
    animFileWalkLeft = aLeft;
    animFileWalkRight = aRight;
    
    animFileAttackUp = aAUp;
    animFileAttackDown = aADown;
    animFileAttackLeft = aALeft;
    animFileAttackRight = aARight;
    
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
    
    animAttackUp = new LoadSprite(animFileAttackUp);
    animAttackDown = new LoadSprite(animFileAttackDown);
    animAttackLeft = new LoadSprite(animFileAttackLeft);
    animAttackRight = new LoadSprite(animFileAttackRight);
    
    updateCurrAnim();
  }
}