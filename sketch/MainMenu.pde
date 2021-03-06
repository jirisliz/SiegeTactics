enum MainStates
{
  main, select, game, designer;
}

class MainMenu
{
  MainStates state = MainStates.main;

  // main:
  Button btnStart, btnDesigner, btnExit;

  // select:
  ScrollBar scrollBar;

  // designer:
  Creator dsg;

  Screen mScr;
  Level level;
  
  LevelRunner levelRun;

  MainMenu()
  {
    initMain();

    initSelect();

    initCreator();
    
    initNew();

    mScr = new Screen(16*16, 16*32);
    scr = mScr;
    level = new Test4();
  }

  void initMain()
  {
    btnStart = 
      new Button(new PVector(width/2-width/4, height*7/10), 
      new PVector(width/2, height/12), 
      "Start"); 
    btnDesigner = 
      new Button(new PVector(width/2-width/4, height*8/10), 
      new PVector(width/2, height/12), 
      "Creator");
    btnExit = 
      new Button(new PVector(width/2-width/4, height*9/10), 
      new PVector(width/2, height/12), 
      "Exit");
  }

  void initSelect()
  { 
    scrollBar = new ScrollBar();
  }

  void initCreator()
  {
    dsg = new Creator();
  }
  
  void initNew() 
  {
    levelRun = new LevelRunner();
  }
  
  void draw() 
  {
    background(255);
    switch(state)
    {
    case main:
      mScr.transformPush();
      level.draw();
      mScr.transformPop();

      pushStyle();
      btnStart.draw(0);
      btnDesigner.draw(0);
      btnExit.draw(0);
      popStyle();
      break;
    case select:

      break;
    case game:
    levelRun.draw();
      break;
    case designer:
      if (dsg.state == CreatorStates.menu) 
      {
        mScr.transformPush();
        level.draw();
        mScr.transformPop();
      }

      dsg.draw();
      break;
    }
  }

  void mousePressed() 
  {
    switch(state)
    {
    case main:

      break;
    case select:

      break;
    case game:
    levelRun.mousePressed();
      break;
    case designer:
      dsg.mousePressed();
      break;
    }
  }

  void mouseDragged() 
  {
    switch(state)
    {
    case main:
      mScr.mouseDragged();
      break;
    case select:

      break;
    case game:
    levelRun.mouseDragged();
      break;
    case designer:
      mScr.mouseDragged(); 
      dsg.mouseDragged();
      break;
    }
  }

  void mouseReleased() 
  {
    switch(state)
    {
    case main:
      btnStart.mouseReleased(0);
      btnDesigner.mouseReleased(0);
      btnExit.mouseReleased(0);
      checkMainBtns();
      break;
    case select:

      break;
    case game:
    levelRun.mouseReleased(); 
    checkGame();
      break;
    case designer:
      dsg.mouseReleased();
      checkDesigner();
      break;
    }
  }

  void onBackPressed() 
  {
    switch(state)
    {
    case main:
      getActivity().finish();
      break;
    case select:

      break;
    case game:
    levelRun.onBackPressed(); 
    checkGame();
      break;
    case designer:
      dsg.onBackPressed();
      checkDesigner();
      break;
    }
  }
  void clearOldImgs(String dir)
  {
    File[] files = Storage.getFilesList(dir);
    for (int i = 0; i <= files.length - 1; i++)   
    {
      files[i].delete();
    }
  }
  void checkMainBtns() 
  {
    if (btnStart.pressed)
    {
      btnStart.reset();
      initNew();
      state = MainStates.game;
    }

    if (btnDesigner.pressed)
    {
      btnDesigner.reset();
      state=MainStates.designer;
    }

    if (btnExit.pressed)
    {
      btnExit.reset();
      getActivity().finish();
    }
  }
  
  void checkGame() 
  {
    if(levelRun.finished)
    {
      state=MainStates.main;
      scr = mScr;
    }
  }

  void checkDesigner() 
  {
    if(dsg.finished)
    {
      dsg.reset();
      state=MainStates.main;
      scr = mScr;
    }
  }
}
