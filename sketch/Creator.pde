enum CreatorStates
{
  menu, select, sizemap, creator;
}

class Creator
{
  CreatorStates state = CreatorStates.menu;
  Screen scr;

  // Main gui
  Button btnNew, btnOpen, btnBack;
  ArrayList<Button> btnsMenu;

  // Creator gui
  Button btnBck, btnWall, btnUnit;
  ArrayList<Button> btnsCreator;

  DialogTextEdit dte;

  // Used to exit creator 
  boolean finished = false;

  Screen mScr;
  LevelLoader level;
  boolean levelLoaded = false;

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
    btnBck = 
      new Button(new PVector(width/15, height*12/15), 
      new PVector(width/4, height/16), 
      "Background");

    btnWall = 
      new Button(new PVector(width/15, height*13/15), 
      new PVector(width/4, height/16), 
      "Walls");

    btnUnit = 
      new Button(new PVector(width/15, height*14/15), 
      new PVector(width/4, height/16), 
      "Units");

    PFont font = createFont("Monospaced-Bold", 30);
    btnBck.font = font;
    btnWall.font = font;
    btnUnit.font = font;

    btnsCreator = new ArrayList<Button>();
    btnsCreator.add(btnBck);
    btnsCreator.add(btnWall);
    btnsCreator.add(btnUnit);

    dte = new DialogTextEdit(sketch);
    dte.title = "Level name";
    dte.message = "Tipe name for new level.";
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
      if (!levelLoaded && dte.finished) 
      {
        levelLoaded = true;
        level.levelName = dte.txt;
        println("load file name: " + level.levelName);
        level.loadFromFile();
      }
      background(0);
      mScr.transformPush();
      level.draw();
      mScr.transformPop();

      pushStyle();
      for (Button btn : btnsCreator) 
      {
        btn.draw(0);
      }
      popStyle(); 
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
    if (btnNew.pressed)
    {
      btnNew.reset();
      levelLoaded = false;
      state = CreatorStates.creator;
      dte.showAddItemDialog("");
    }

    if (btnOpen.pressed)
    {
      btnOpen.reset();

      File[] files = Storage.getFilesList(
        Storage.createFolder(level.levelFolder));
      for (int i = 0; i <= files.length - 1; i++)   
      {
        println(files[i].getName());
      }
    }

    if (btnBack.pressed)
    {
      btnBack.reset();
      level.levelName = dte.txt;
      level.save2File();
      finished = true;
    }
  }

  void reset() 
  {
    finished = false;
  }
}
