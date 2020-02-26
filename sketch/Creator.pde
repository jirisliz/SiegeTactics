enum CreatorStates
{
  menu, select, sizemap, creator;
}

class Creator
{
  CreatorStates state = CreatorStates.menu;
  Screen scr;
  Button btnNew, btnOpen, btnBack;
  ArrayList<Button> btnsMenu;

  // Used to exit creator 
  boolean finished = false;

  Screen mScr;
  LevelLoader level;

  Creator() 
  {
    initMenu();
    initCreator();
  }

  void initMenu() 
  {
    btnNew = 
      new Button(new PVector(width/2-width/4, height*7/10), 
      new PVector(width/2, height/12), 
      "New map"); 
    btnOpen = 
      new Button(new PVector(width/2-width/4, height*8/10), 
      new PVector(width/2, height/12), 
      "Open map");
    btnBack = 
      new Button(new PVector(width/2-width/4, height*9/10), 
      new PVector(width/2, height/12), 
      "Back");

    btnsMenu = new ArrayList<Button>();
    btnsMenu.add(btnNew);
    btnsMenu.add(btnOpen);
    btnsMenu.add(btnBack);
  }

  void initCreator() 
  {
    level = new LevelLoader();
    // Create screen for creator
    mScr = new Screen((int) level.getLevelSize().x, 
      (int) level.getLevelSize().y);
    mScr.addFrame(16*4);
    mScr.fitWidth();
    mScr.checkBorders();
  }

  void draw() 
  {
    switch(state)
    {
    case menu:
      pushStyle();
      for (Button btn : btnsMenu) 
      {
        btn.draw(0);
      }
      popStyle(); 
      break;
    case select:

      break;
    case sizemap:

      break;
    case creator:
      background(0);
      mScr.transformPush();
      level.draw();
      mScr.transformPop();
      break;
    }
  }

  void mousePressed() 
  {
    switch(state)
    {
    case menu:

      break;
    case select:

      break;
    case sizemap:

      break;
    case creator:
    
      break;
    }
  }

  void mouseDragged() 
  {
    switch(state)
    {
    case menu:

      break;
    case select:

      break;
    case sizemap:

      break;
    case creator:
    mScr.mouseDragged(); 
      break;
    }
    
  }

  void mouseReleased() 
  {
    switch(state)
    {
    case menu:
    for (Button btn : btnsMenu) 
    {
      btn.mouseReleased(0);
    }
    checkBtns(); 
      break;
    case select:

      break;
    case sizemap:

      break;
    case creator:
    level.mouseReleased(mScr);
      break;
    } 
  }

  void onBackPressed() 
  {
    switch(state)
    {
    case menu:
      finished = true;
      break;
    case select:

      break;
    case sizemap:

      break;
    case creator:
      state = CreatorStates.menu;
      break;
    }
  }

  void checkBtns() 
  {
    if (btnBack.pressed)
    {
      btnBack.reset();
      finished = true;
    }

    if (btnNew.pressed)
    {
      btnNew.reset();
      state = CreatorStates.creator;
    }
  }

  void reset() 
  {
    finished = false;
  }
}
