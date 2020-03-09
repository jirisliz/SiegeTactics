enum CreatorStates
{
  menu, select, sizemap, creator;
}

class Creator
{
  CreatorStates state = CreatorStates.menu;
  CreatorStates prevState = CreatorStates.menu;
  Screen scr;

  // Main gui
  Button btnNew, btnOpen, btnBack;
  ArrayList<Button> btnsMenu;

  // Creator gui
  Button btnBck, btnWall, btnUnit;
  ArrayList<Button> btnsCreator;

  // Select gui
  ScrollBar scrlbSelect;

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
    initSelect();
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

  void initSelect() 
  {
    scrlbSelect = null;
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
      if (scrlbSelect != null) scrlbSelect.draw();
      break;
    case sizemap:

      break;
    case creator:
      if (!levelLoaded && dte.finished) 
      {
        fullScreen();
        loadLevel(dte.txt);
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

  void loadLevel(String name) 
  {
    fullScreen();
    levelLoaded = true;
    level.levelName = name;
    println("load file name: " + level.levelName);
    level.loadFromFile();
  }

  void mousePressed() 
  {
    switch(state)
    {
    case menu:

      break;
    case select:
      if (scrlbSelect != null) 
      {
        scrlbSelect.open();
      }
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
      if (scrlbSelect != null) 
      {
        scrlbSelect.update(mouseY - pmouseY);
      }
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
      checkMenuBtns(); 
      break;
    case select:
      if (scrlbSelect != null) 
      {
        scrlbSelect.close();
        checkSelectBtns();
      } 
      break;
    case sizemap:

      break;
    case creator:
      for (Button btn : btnsCreator) 
      {
        btn.mouseReleased(0);
      }
      boolean btnPressed = checkCreatorBtns(); 
      if (!btnPressed)level.mouseReleased(mScr);
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
      state = CreatorStates.menu;
      break;
    case sizemap:

      break;
    case creator:
      state = CreatorStates.menu;
      break;
    }
  }

  ScrollBar createFilesScrollBar(String dir, String ext) 
  {
    ScrollBar scrlb = new ScrollBar();
    // list levels
    File[] files = Storage.getFilesList(dir);
    if (files.length > 0)scrlb = new ScrollBar();
    else return null;
    for (int i = 0; i <= files.length - 1; i++)   
    {
      String name = files[i].getName();
      if (name.contains(ext))
      {
        name = name.replace(ext, "");
        println("scrollBar add: " + name);
        scrlb.add(name);
      }
    }
    return scrlb;
  }

  void checkMenuBtns() 
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
      String path = Storage.createFolder(level.levelFolder);
      scrlbSelect = 
        createFilesScrollBar(path, ".csv");
      if (scrlbSelect != null) 
      {
        prevState = CreatorStates.menu; 
        state = CreatorStates.select;
      } else
      {
        println("No valid level to load.");
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

  boolean checkCreatorBtns() 
  {
    boolean ret = false;
    if (btnBck.pressed)
    {
      btnBck.reset();
      ret = true;
      String backsDir = dataPath(Storage.dataDirBacks);
      println(backsDir);
      scrlbSelect = 
        createFilesScrollBar(backsDir, ".png");
      if (scrlbSelect != null) 
      {
        prevState = CreatorStates.creator; 
        state = CreatorStates.select;
      } else
      {
        println("No valid tile to load.");
      }
    }

    if (btnWall.pressed)
    {
      btnWall.reset();
      ret = true;
    }

    if (btnUnit.pressed)
    {
      btnUnit.reset();
      ret = true;
    }
    return ret;
  }

  void checkSelectBtns() 
  {
    Button btn;
    switch(prevState)
    {
    case menu:
      btn = scrlbSelect.getLastClickedBtn();

      if (btn != null) 
      {
        loadLevel(btn.text);
        state = CreatorStates.creator;
      }
      break;
    case select:

      break;
    case sizemap:

      break;
    case creator:
      btn = scrlbSelect.getLastClickedBtn();

      if (btn != null) 
      {
        level.loadGround(btn.text+".png");
        state = CreatorStates.creator;
      }
      break;
    }
  }

  void reset() 
  {
    finished = false;
  }
}
