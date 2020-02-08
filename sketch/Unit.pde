public enum States
{
  walk, seek, stand, attack, defend, dead;
}

public enum Dirs
{
  LU, RU, RD, LD;
  //up, right, down, left;
}

abstract class Unit extends Vehicle
{
  // Standard unit animations:
  LoadSprite anim_iddleRU, anim_iddleLU, 
    anim_iddleRD, anim_iddleLD;

  LoadSprite anim_attackRU, anim_attackLU, 
    anim_attackRD, anim_attackLD;

  LoadSprite anim_attack2RU, anim_attack2LU, 
    anim_attack2RD, anim_attack2LD;

  LoadSprite anim_runRU, anim_runLU, 
    anim_runRD, anim_runLD;


  LoadSprite animCurr;

  // Used for attacking
  boolean animFullCycle = false;

  // Unit vars
  String unitType;
  States state = States.walk;
  Dirs dir = Dirs.RU;
  int livesMax = 10;
  int lives = livesMax;
  boolean alive = true;

  int teamNum = 0;

  float viewRadius = 200;
  float attackRadius = 20;
  Unit enemyAttacking;

  Unit() 
  {
    orig = new PVector(0, 0);
  }

  Unit(String aName, PVector l, float ms, float mf)
  {
    super(l, ms, mf);
    orig = new PVector(0, 0);
    unitType = aName;
    loadStdAnims(aName);
  }

  void loadStdAnims(String unitName) 
  {
    anim_iddleRU = new LoadSprite(unitName+"-iddleRU.png", 8);
    anim_iddleLU = new LoadSprite(unitName+"-iddleLU.png", 8);
    anim_iddleRD = new LoadSprite(unitName+"-iddleRD.png", 8);
    anim_iddleLD = new LoadSprite(unitName+"-iddleLD.png", 8);    

    anim_attackRU = new LoadSprite(unitName+"-attackRU.png", 5);
    anim_attackLU = new LoadSprite(unitName+"-attackLU.png", 5);
    anim_attackRD = new LoadSprite(unitName+"-attackRD.png", 5);
    anim_attackLD = new LoadSprite(unitName+"-attackLD.png", 5);

    anim_attack2RU = new LoadSprite(unitName+"-attack2RU.png", 5);
    anim_attack2LU = new LoadSprite(unitName+"-attack2LU.png", 5);
    anim_attack2RD = new LoadSprite(unitName+"-attack2RD.png", 5);
    anim_attack2LD = new LoadSprite(unitName+"-attack2LD.png", 5);

    anim_runRU = new LoadSprite(unitName+"-runRU.png", 4);
    anim_runLU = new LoadSprite(unitName+"-runLU.png", 4);
    anim_runRD = new LoadSprite(unitName+"-runRD.png", 4);
    anim_runLD = new LoadSprite(unitName+"-runLD.png", 4);

    updateCurrAnim();
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

  void setTarget(PVector t) 
  {
    target = t;
    state = States.seek;
  }

  void setIddleAnim() 
  {
    switch(dir) 
    {
    case RU: 
      animCurr = anim_iddleRU; 
      break;
    case RD: 
      animCurr = anim_iddleRD; 
      break;
    case LD: 
      animCurr = anim_iddleLD; 
      break;
    case LU: 
      animCurr = anim_iddleLU; 
      break;
    }
  }

  void setWalkAnim() 
  {
    switch(dir) 
    {
    case RU: 
      animCurr = anim_runRU; 
      break;
    case RD: 
      animCurr = anim_runRD; 
      break;
    case LD: 
      animCurr = anim_runLD; 
      break;
    case LU: 
      animCurr = anim_runLU; 
      break;
    }
  }

  void setAttackAnim() 
  {
    switch(dir) 
    {
    case RU: 
      animCurr = anim_attack2RU; 
      break;
    case RD: 
      animCurr = anim_attack2RD; 
      break;
    case LD: 
      animCurr = anim_attack2LD; 
      break;
    case LU: 
      animCurr = anim_attack2LU; 
      break;
    }
  }

  void updateCurrAnim() 
  {
    if (state == States.walk || state == States.seek) 
    {
      setWalkAnim();
    } else if (state == States.attack) 
    {
      setAttackAnim();
    } else if (state == States.stand) 
    {
      setIddleAnim();
    }
  }

  void findNearestEnemy(ArrayList enemies) 
  {
    float dist = height * 2;
    boolean anyEnemyFound = false;
    for (int i = 0; i < enemies.size(); i++) {
      Unit u = (Unit) enemies.get(i);
      float d = position.dist(u.position);
      if (d < dist && u.alive)
      {
        anyEnemyFound = true;
        dist = d;
        target = u.position;
        enemyAttacking = u;
      }
    }
    if (!anyEnemyFound && alive) 
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
    }
  }

  void stillAlive() 
  {
    if (lives <= 0)
    {
      alive = false;
      active = false; // due to compatibility with wall
      state = States.dead;
      animCurr = null;
    }
  }


  boolean actionIfTargetNear(States st) 
  {
    float dist = width*height;
    if (target != null) 
    {
      dist = position.dist(target);
    }
    if (dist < attackRadius)
    {
      selectDirQuad();
      setState(st);

      if (animFullCycle) 
      {
        animFullCycle = false;
        if (enemyAttacking != null) 
        {
          enemyAttacking.attack(1);
        }
      }
      return true;
    }
    return false;
  }

  void selectDirQuad() 
  {
    // select direction quadrant 
    float a = velocity.heading();
    if (a >= 0 && a < PI/2)dir = Dirs.RD;
    if (a >= PI/2 && a < PI)dir = Dirs.LD;
    if (a >= -PI/2 && a < 0)dir = Dirs.RU;
    if (a >= -PI && a < -PI/2)dir = Dirs.LU;
    updateCurrAnim();
  }

  void update(ArrayList allies, 
    ArrayList enemies, Path path, ArrayList walls)
  {

    if (animCurr != null)
    {
      animCurr.update();
      if (animCurr.currFrame == 0)animFullCycle = true;
    }


    // Handle states
    switch(state) 
    {
    case walk: 
      if (!actionIfTargetNear(States.attack) && alive) 
      {
        super.update();
        applyFollow(path);
        applySeparationCirc(allies);
        applySeparationCirc(enemies);
        applySeparationRect(walls);
        selectDirQuad();
      }
      break;
    case seek: 

      if (!actionIfTargetNear(States.stand) && alive) 
      {
        super.update();
        applySeek();
        applySeparationCirc(allies);
        applySeparationCirc(enemies);
        applySeparationRect(walls);

        selectDirQuad();
      }

      break;
    case stand:
      velocity.x = 0;
      velocity.y = 0;
      setIddleAnim();
      break;
    case attack:
      if (!actionIfTargetNear(States.attack) && alive) 
      {
        super.update();
        applyFollow(path);
        applySeek();
        applySeparationCirc(allies);
        applySeparationCirc(enemies);
        applySeparationRect(walls);
        selectDirQuad();
        setWalkAnim();
      }
      break;
    case defend:
      setIddleAnim();
      actionIfTargetNear(States.attack);
      if (target != null) 
      {
        float dist = position.dist(target);
        if (dist < viewRadius) 
        {
          super.update();
          applySeek();
          applySeparationCirc(allies);
          applySeparationCirc(enemies);
          applySeparationRect(walls);
          selectDirQuad();
        }
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
