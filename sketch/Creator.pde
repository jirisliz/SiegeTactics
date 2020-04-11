enum CreatorStates
{
  menu, select, sizemap, creator, newMap, tilePicker;
}

class Creator
{
  CreatorStates state = CreatorStates.menu;
  CreatorStates prevState = CreatorStates.menu;

  // Main gui
  Button btnNew, btnOpen, btnBack;
  ArrayList<Button> btnsMenu;

  // Creator gui
  Button btnBck, btnObj, btnUnit;
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

  // Tile picker
  TilePicker tlPck;

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
      new Button(new PVector(width/8, height*15/18), 
      new PVector(width/4, height/19), 
      "Background");
    btnBck.setChecked(true);

    btnObj = 
      new Button(new PVector(width/8, height*16/18), 
      new PVector(width/4, height/19), 
      "Objects");

    btnUnit = 
      new Button(new PVector(width/8, height*17/18), 
      new PVector(width/4, height/19), 
      "Units");

    PFont font = createFont("Monospaced-Bold", 30);
    btnBck.font = font;
    btnObj.font = font;
    btnUnit.font = font;

    btnsCreator = new ArrayList<Button>();
    btnsCreator.add(btnBck);
    btnsCreator.add(btnObj);
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
    mScr.selEnabled = true;
  }

  void initSelect() 
  {
    scrlbSelect = null;
  }

  void initTilePicker() 
  {
    tlPck = null;
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
        onResume(); // this will hide top bar after dialog end

        loadLevel(dte.txt);
      }
      if (levelLoaded && dte.finished) 
      {
        level.levelName = dte.txt;
        level.fillGround(mScr); 
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
    case tilePicker:
      tlPck.draw();
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
      mScr.mousePressed();
      break;
    case tilePicker:
      tlPck.mousePressed();
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
    case tilePicker:
      tlPck.mouseDragged();
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
        mScr.mouseReleased();
        if (btnBck.checked)
        {
          if (mScr.selFinished) 
          {
            level.clickBackrDrag(mScr);
          } else
          {
            level.clickBackgr(mScr);
          }
        }
        if (btnObj.checked)
        {
          level.clickObjs(mScr, tlPck);
        }
        if (btnUnit.checked)
        {
          level.clickUnits(mScr);
        }
      }

      break;
    case tilePicker:
      tlPck.mouseReleased();
      if (tlPck.finished) 
      {
        state = CreatorStates.creator;
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
    case tilePicker:
      state = CreatorStates.creator;
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
      selectTileFromDir(Storage.dataDirBacks);
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
      try
      {
        level.save2File();
      }
      catch(Exception ex) 
      {
      }

      finished = true;
    }
  }

  void selectTileFromDir(String dir) 
  {
    String backsDir = dataPath(dir);
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

  boolean checkCreatorBtns() 
  {
    boolean ret = false;
    if (btnBck.pressed)
    {
      btnBck.reset();
      btnBck.setChecked(true);
      btnObj.setChecked(false);
      btnUnit.setChecked(false); 

      selectTileFromDir(Storage.dataDirBacks);

      ret = true;
    }

    if (btnObj.pressed)
    {
      btnObj.reset();
      btnBck.setChecked(false);
      btnObj.setChecked(true);
      btnUnit.setChecked(false); 

      selectTileFromDir(Storage.dataDirTiles);

      ret = true;
    }

    if (btnUnit.pressed)
    {
      btnUnit.reset();
      btnBck.setChecked(false);
      btnObj.setChecked(false);
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
    case newMap:
      btn = scrlbSelect.getLastClickedBtn();
      if (btn != null) 
      {
        level.loadGround(btn.text+".png");
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
        if (btnObj.checked)
        {
          tlPck = new TilePicker(btn.text+".png");
          state = CreatorStates.tilePicker;
          return;
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
