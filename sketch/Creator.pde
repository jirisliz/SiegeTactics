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
  PVector touchStart;

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
      new Button(new PVector(width/8, height*14/15), 
      new PVector(width/4, height/16), 
      "Background");
    btnBck.setChecked(true);

    btnWall = 
      new Button(new PVector(width/8+width/4, height*14/15), 
      new PVector(width/4, height/16), 
      "Walls");

    btnUnit = 
      new Button(new PVector(width/8+width*2/4, height*14/15), 
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
      if (!levelLoaded && dte.finished) 
      {
        level.levelName = dte.txt;
        dte.finished = false;
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
      touchStart = new PVector(mouseX, mouseY);
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
      if (touches.length == 1) 
      {
        pushStyle();
        noFill();
        stroke(30, 250, 30);
        PVector start = touchStart;
        PVector end = new PVector(mouseX-touchStart.x, 
          mouseY-touchStart.y);

        rect(start.x, start.y, end.x, end.y);
        popStyle();
      }      
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
      if (!btnPressed)
      {
        if (btnBck.checked)
        {
          if (touchStart.dist(new PVector(mouseX, mouseY)) > 100) 
          {
            level.clickBackrDrag(mScr, touchStart);
          } else
          {
            level.clickBackgr(mScr);
          }
        }
        if (btnWall.checked)
        {
          level.clickWalls(mScr);
        }
        if (btnUnit.checked)
        {
          level.clickUnits(mScr);
        }
      }

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
    ScrollBar scrlb;
    // list levels
    File[] files = Storage.getFilesList(dir);
    if (files.length > 0)scrlb = new ScrollBar();
    else return null;
    scrlb.layoutTopSpace = height/2; // for better one hand access
    for (int i = 0; i <= files.length - 1; i++)   
    {
      String name = files[i].getName();
      if (name.contains(ext))
      {
        name = name.replace(ext, "");
        //println("scrollBar add: " + name);
        scrlb.add(name);
      }
    }
    return scrlb;
  }

  ScrollBar createStringsScrollBar(String[] strs) 
  {
    ScrollBar scrlb = new ScrollBar();
    if (strs.length == 0) return null;
    scrlb.layoutTopSpace = height/2; // for better one hand access
    for (int i = 0; i <= strs.length - 1; i++)   
    {
      scrlb.add(strs[i]);
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
      btnBck.setChecked(true);
      btnWall.setChecked(false);
      btnUnit.setChecked(false); 

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
      btnBck.setChecked(false);
      btnWall.setChecked(true);
      btnUnit.setChecked(false); 

      ret = true;
    }

    if (btnUnit.pressed)
    {
      btnUnit.reset();
      btnBck.setChecked(false);
      btnWall.setChecked(false);
      btnUnit.setChecked(true); 

      scrlbSelect = createStringsScrollBar(Defs.units);

      if (scrlbSelect != null) 
      {
        prevState = CreatorStates.creator; 
        state = CreatorStates.select;
      } 

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
        if (btnBck.checked)
        {
          level.loadGround(btn.text+".png");
        }
        if (btnWall.checked)
        {
        }
        if (btnUnit.checked)
        {
          level.setUnit(btn.text);
        }
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
