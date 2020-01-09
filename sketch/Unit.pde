public enum States
{
  walk, stand, attack, defend;
}

public enum Dirs
{
  up, right, down, left;
}

abstract class Unit extends Vehicle
{
  States state = States.walk;
  Dirs dir = Dirs.up;
  int teamNum = 0;

  float viewRadius = 40;

  LoadSprite animWalkUp;
  LoadSprite animWalkRight;
  LoadSprite animWalkDown;
  LoadSprite animWalkLeft;
  
  LoadSprite animAttackUp;
  LoadSprite animAttackRight;
  LoadSprite animAttackDown;
  LoadSprite animAttackLeft;

  LoadSprite animCurr;

  int fcount = 0;
  int fmax = 10;

  Unit() 
  {
  }

  Unit(PVector l, float ms, float mf)
  {
    super(l, ms, mf);
  }

  void setState(States st) 
  {
    state = st;
    updateCurrAnim();
  }

  void setDir(Dirs d)
  {
    dir = d;
    updateCurrAnim();
  }
  
  void setWalkAnim() 
  {
    switch(dir) 
      {
      case up: 
        animCurr = animWalkUp; 
        break;
      case down: 
        animCurr = animWalkDown; 
        break;
      case left: 
        animCurr = animWalkLeft; 
        break;
      case right: 
        animCurr = animWalkRight; 
        break;
      }
  }
  
  void setAttackAnim() 
  {
    switch(dir) 
      {
      case up: 
        animCurr = animAttackUp; 
        break;
      case down: 
        animCurr = animAttackDown; 
        break;
      case left: 
        animCurr = animAttackLeft; 
        break;
      case right: 
        animCurr = animAttackRight; 
        break;
      }
  }

  void updateCurrAnim() 
  {
    if (state == States.walk) 
    {
      setWalkAnim();
    }
    
  }

  void update(ArrayList allies, 
    ArrayList enemies, Path path)
  {
    //super.update();

    // select direction quadrant 
    float a = velocity.heading();
    if (a >= PI/4 && a < PI-PI/4)dir = Dirs.down;
    if (a >= PI-PI/4 || a < -PI+PI/4)dir = Dirs.left;
    if (a >= -PI+PI/4 && a < -PI/4)dir = Dirs.up;
    if (a >= -PI/4 && a < PI/4)dir = Dirs.right;
    updateCurrAnim();

    // Animation speed (frameRate divided) 
    fcount++;
    if (fcount >= fmax) 
    {
      fcount = 0;
      if(animCurr != null)animCurr.update();
    }

    // Handle states
    switch(state) 
    {
    case walk: 
      super.update();
      applyFollow(path);
      break;
    case stand:
      break;
    case attack:
      
      if (position.dist(target) < viewRadius)
      {
       setAttackAnim(); 
      } else
      {
        super.update();
        applySeek();
        applySeparation(allies);
        applySeparation(enemies);
        setWalkAnim();
      }
      break;
    }
  }

  void draw()
  {
    if(animCurr != null) 
    {
     animCurr.draw(position.x, position.y); 
    }
    else
    {
      fill(100);
      noStroke();
      ellipse(position.x, position.y, r, r);
    }
  }
}
