enum LevelRunnerTypes
{
  select, planning, fight, results;
}

class LevelRunner
{
  boolean finished = false;

  LevelRunnerTypes state = LevelRunnerTypes.select;
  LevelLoader level;
  Screen scr;
  Renderer r;

  // GUI select
  ScrollBar scrlbSelect;

  // GUI planning
  ArrayList<Button> btnsPlanning;
  Button btnFight;

  String levelName;

  // Fight params
  ArrayList<Projectile> projectiles; 

  LevelRunner() 
  {
    state = LevelRunnerTypes.select;
    String path = Storage.createFolder(Storage.levelsFolder);
    scrlbSelect = new ScrollBar(path, ".csv");
    initPlanning();
  }

  void initPlanning() 
  {
    int btnHDiv = 30;
    btnFight = 
      new Button(
      new PVector(width*6/8-width/16, height*(btnHDiv-1)/btnHDiv), 
      new PVector(width*2/8-2, height/(btnHDiv+1)), 
      "Fight!"); 

    btnsPlanning = new ArrayList<Button>();
    btnsPlanning.add(btnFight);
    PFont font = createFont("Monospaced-Bold", 30);
    for (Button btn : btnsPlanning) 
    {
      btn.font = font;
    }
  }

  void drawBtns(ArrayList<Button> btns) 
  {
    pushStyle();
    for (Button btn : btns) 
    {
      btn.draw(0);
    }
    popStyle();
  }

  void update() 
  {
    for (SoldierBasic u : level.attackers)
    {
      u.findNearestEnemy(level.defenders);
    }
    for (SoldierBasic u : level.defenders)
    {
      u.findNearestEnemy(level.attackers);
    }
    
    for (SoldierBasic u : level.attackers)
    {
      u.stillAlive();
    }
    for (SoldierBasic u : level.defenders)
    {
      u.stillAlive();
    }
  }

  void drawLevel() 
  {
    background(0);
    scr.transformPush();
    level.draw();
    scr.transformPop();
  }

  void draw()
  {
    switch(state)
    {
    case select:
      if (scrlbSelect != null) scrlbSelect.draw();
      break;
    case planning:
      drawLevel();
      drawBtns(btnsPlanning); 
      break;
    case fight:
      drawLevel(); 
      update();
      break;
    case results:

      break;
    }
  }

  void mousePressed() 
  {
    switch(state)
    {
    case select:
      if (scrlbSelect != null) 
      {
        scrlbSelect.open();
      }
      break;
    case planning:
      scr.mousePressed();
      break;
    case fight:
    scr.mousePressed();
      break;
    case results:

      break;
    }
  }

  void mouseDragged() 
  {
    switch(state)
    {
    case select:
      if (scrlbSelect != null) 
      {
        scrlbSelect.update(mouseY - pmouseY);
      }
      break;
    case planning:
      scr.mouseDragged();
      break;
    case fight:
scr.mouseDragged();
      break;
    case results:

      break;
    }
  }

  void mouseReleased() 
  {
    switch(state)
    {
    case select:
      if (scrlbSelect != null) 
      {
        scrlbSelect.close();
        checkSelectBtns();
      } 
      break;
    case planning:
      for (Button btn : btnsPlanning) 
      {
        btn.mouseReleased(0);
      }
      if (!checkPlanningBtns()) scr.mouseReleased(); 
      break;
    case fight:
scr.mouseReleased(); 
      break;
    case results:

      break;
    }
  }

  void onBackPressed() 
  {
    switch(state)
    {
    case select:
      finished = true;
      break;
    case planning:
      finished = true;
      break;
    case fight:
    finished = true;
      break;
    case results:
      finished = true;
      break;
    }
  }

  boolean checkPlanningBtns() 
  {
    boolean ret = false;
    if (btnFight.pressed)
    {
      btnFight.reset();
      
      // Init all units
      for (Unit u : level.attackers)
      {
        u.setState(States.attack);
        u.primaryTarget = new PVector(scr.mWidth/2, scr.mHeight/4);
        u.target = u.primaryTarget;
      }

      for (Unit u : level.defenders)
      {
        u.setState(States.attack);
        u.primaryTarget = new PVector(scr.mWidth/2, scr.mHeight*3/4);
        u.target = u.primaryTarget;
      }
      state = LevelRunnerTypes.fight;
      ret = true;
    } 
    return ret;
  }

  void checkSelectBtns() 
  {
    Button btn = scrlbSelect.getLastClickedBtn();

    if (btn != null) 
    {
      level = new LevelLoader();
      level.levelName = btn.text;
      println("load file name: " + level.levelName);
      level.loadFromFile();
      scr = new Screen((int) level.getLevelSize().x, 
        (int) level.getLevelSize().y);
      state = LevelRunnerTypes.planning;
    }
  }
}
