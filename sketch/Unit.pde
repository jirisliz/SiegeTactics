public enum States
{
  walk, stand, attack, defend, dead;
}

public enum Dirs
{
  up, right, down, left;
}

abstract class Unit extends Vehicle
{
  // Animation vars
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
  boolean animFullCycle = false;

  // Unit vars
  States state = States.walk;
  Dirs dir = Dirs.up;
  int livesMax = 10;
  int lives = livesMax;
  int teamNum = 0;

  float viewRadius = 40;
  Unit enemyAttacking;

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

  void findNearestEnemy(ArrayList enemies) 
  {
    float dist = height * 2;
    boolean anyEnemyFound = false;
    for (int i = 0; i < enemies.size(); i++) {
      Unit u = (Unit) enemies.get(i);
      float d = position.dist(u.position);
      if (d < dist && u.lives > 0)
      {
        anyEnemyFound = true;
        dist = d;
        target = u.position;
        enemyAttacking = u;
      }
    }
    if(!anyEnemyFound) 
    {
      state = States.walk;
      target = primaryTarget;
    }
  }

  void attack(int val) 
  {
    lives -= val;
    if (lives <= 0)
    {
      lives = 0;
      state = States.dead;
      animCurr = null;
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
      if (animCurr != null)
      {
        animCurr.update();
        if(animCurr.currFrame == 0)animFullCycle = true;
      }
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
      float dist = width*height;
      if(target != null) 
      {
        dist = position.dist(target);
      }
      if (dist < viewRadius)
      {
        setAttackAnim();
        if (animFullCycle) 
        {
          animFullCycle = false;
          if (enemyAttacking != null) 
          {
            enemyAttacking.attack(1);
          }
        }
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
    if (animCurr != null) 
    {
      animCurr.draw(position.x, position.y);
      // Draw lives
      stroke(30, 200, 30);
      strokeWeight(3);
      int l = (int) map(lives, 0, livesMax, 1, r);
      line(position.x-l, position.y-r, 
        position.x+l, position.y-r);
    } else
    {
      fill(100);
      noStroke();
      ellipse(position.x, position.y, r, r);
    }
  }
}
