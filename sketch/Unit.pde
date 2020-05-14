public enum States
{
  walk, seek, stand, attack, defend, dead;
}

public enum Dirs
{
  LU, RU, RD, LD;
  //up, right, down, left;
}

public enum UnitAnims
{
  idle, attack, attack2, run, dead;
}

abstract class Unit extends Vehicle
{
  // Standard unit animations:
  LoadSprite anim_idleRU, anim_idleLU, 
    anim_idleRD, anim_idleLD;

  LoadSprite anim_attackRU, anim_attackLU, 
    anim_attackRD, anim_attackLD;

  LoadSprite anim_attack2RU, anim_attack2LU, 
    anim_attack2RD, anim_attack2LD;

  LoadSprite anim_runRU, anim_runLU, 
    anim_runRD, anim_runLD;

  LoadSprite anim_deadR;

  LoadSprite animCurr;

  // Used for attacking
  boolean animFullCycle = false;

  // Unit vars
  String unitType;
  States state = States.walk;
  int currAttack = 0;
  Dirs dir = Dirs.RU;
  int livesMax = 20;
  int lives = livesMax;
  boolean alive = true;
  UnitAnims currAnim = UnitAnims.idle;
  
  // Ranged units params
  boolean ranged = false;
  String projectileName = "arrow.png";
  ArrayList<Projectile> projectiles; // reference to projectiles list
  
  int teamNum = 0;

  float viewRadius = 200;
  float attackRadius = 20;
  float attackRadiusRanged = 200;
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
    String folder = dataPath(unitName);

    anim_idleRU = new LoadSprite(folder+"/" +"idleRU.png", 8);
    anim_idleLU = new LoadSprite(folder+"/" +"idleLU.png", 8);
    anim_idleRD = new LoadSprite(folder+"/" +"idleRD.png", 8);
    anim_idleLD = new LoadSprite(folder+"/" +"idleLD.png", 8);    

    anim_attackRU = new LoadSprite(folder+"/" +"attackRU.png", 5);
    anim_attackLU = new LoadSprite(folder+"/" +"attackLU.png", 5);
    anim_attackRD = new LoadSprite(folder+"/" +"attackRD.png", 5);
    anim_attackLD = new LoadSprite(folder+"/" +"attackLD.png", 5);

    anim_attack2RU = new LoadSprite(folder+"/" +"attack2RU.png", 5);
    anim_attack2LU = new LoadSprite(folder+"/" +"attack2LU.png", 5);
    anim_attack2RD = new LoadSprite(folder+"/" +"attack2RD.png", 5);
    anim_attack2LD = new LoadSprite(folder+"/" +"attack2LD.png", 5);

    anim_runRU = new LoadSprite(folder+"/" +"runRU.png", 4);
    anim_runLU = new LoadSprite(folder+"/" +"runLU.png", 4);
    anim_runRD = new LoadSprite(folder+"/" +"runRD.png", 4);
    anim_runLD = new LoadSprite(folder+"/" +"runLD.png", 4);

    anim_deadR = new LoadSprite(folder+"/" +"deadR.png", 4);

    if (anim_idleRU != null) 
    {
      size = new PVector(anim_idleRU.width, anim_idleRU.height);
    } else
    {
      size = new PVector(16, 16);
    }

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

  void setRanged(boolean state, ArrayList<Projectile> p)
  {
    ranged = state;
    if(ranged) 
    {
      projectiles = p;
    }
    else
    {
      projectiles = null;
    }
  } 

  void setAnimDiv(UnitAnims anim, int div)
  {
    switch(anim) 
    {
    case idle: 
      anim_idleRU.setSpeedDiv(div);
      anim_idleLU.setSpeedDiv(div);
      anim_idleRD.setSpeedDiv(div);
      anim_idleLD.setSpeedDiv(div);
      break;
    case attack: 
      anim_attackRU.setSpeedDiv(div);
      anim_attackLU.setSpeedDiv(div);
      anim_attackRD.setSpeedDiv(div);
      anim_attackLD.setSpeedDiv(div);
      break;
    case attack2: 
      anim_attack2RU.setSpeedDiv(div);
      anim_attack2LU.setSpeedDiv(div);
      anim_attack2RD.setSpeedDiv(div);
      anim_attack2LD.setSpeedDiv(div);
      break;
    case run: 
      anim_runRU.setSpeedDiv(div);
      anim_runLU.setSpeedDiv(div);
      anim_runRD.setSpeedDiv(div);
      anim_runLD.setSpeedDiv(div);
      break;
    case dead: 
      anim_deadR.setSpeedDiv(div);
      break;
    }
  } 

  void setIddleAnim() 
  {
    switch(dir) 
    {
    case RU: 
      animCurr = anim_idleRU; 
      break;
    case RD: 
      animCurr = anim_idleRD; 
      break;
    case LD: 
      animCurr = anim_idleLD; 
      break;
    case LU: 
      animCurr = anim_idleLU; 
      break;
    }
    currAnim = UnitAnims.idle;
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
    currAnim = UnitAnims.run;
  }

  void setAttackAnim() 
  {
    if (currAttack == 0)
    {
      switch(dir) 
      {
      case RU: 
        animCurr = anim_attackRU; 
        break;
      case RD: 
        animCurr = anim_attackRD; 
        break;
      case LD: 
        animCurr = anim_attackLD; 
        break;
      case LU: 
        animCurr = anim_attackLU; 
        break;
      }
      currAnim = UnitAnims.attack;
    } else if (currAttack == 1)
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
      currAnim = UnitAnims.attack2;
    }
  }

  void setDeadAnim() 
  {
    animCurr = anim_deadR;
    currAnim = UnitAnims.dead;
  }

  boolean randomBool() {
    return random(1) > .5;
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
    } else if (state == States.dead) 
    {
      setDeadAnim();
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

  boolean stillAlive() 
  {
    if (lives <= 0)
    {
      alive = false;
      active = false; // due to compatibility with wall
      state = States.dead;
      animCurr = null;
      updateCurrAnim();
    }
    return alive;
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
        if (ranged) 
        {
          currAttack = 1; // melee attack for ranged
        } else
        {
          if (st == States.attack) 
          {
            currAttack = (int) random(1.4);
          }
          animFullCycle = false;
        }
        if (enemyAttacking != null) 
        {
          enemyAttacking.attack(1);
        }
      }
      return true;
    }
    else if(dist < attackRadiusRanged) 
    {
      selectDirQuad();
      setState(States.defend);
      currAttack = 0;
      setAttackAnim();

      if (animFullCycle && projectiles != null &&
          currAnim == UnitAnims.attack ) 
      {
        animFullCycle = false;
        String path = dataPath(Storage.dataDirProjectiles) +
                        "/" + projectileName;

        Projectile pr = new Projectile(position, path);
        pr.fire(enemyAttacking);
        
        projectiles.add(pr);
      }
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
      if (animCurr.fullCycleFinished())animFullCycle = true;
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
        if (dist < viewRadius && !ranged) 
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
      if (alive) 
      {
        stroke(30, 200, 30);
        strokeWeight(2);
        float w = 0.8*(float)r;
        float l = map(lives, 0, livesMax, 0.1, w);
        line(position.x-l, position.y-r, 
          position.x+l, position.y-r);
      }
    } else
    {
      fill(100);
      noStroke();
      ellipse(position.x, position.y, r, r);
    }
  }
}
