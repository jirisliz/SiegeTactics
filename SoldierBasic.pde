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
  
  SoldierBasic(float x, float y) 
  {
    super(new PVector(x, y), random(2,4), 0.4);
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