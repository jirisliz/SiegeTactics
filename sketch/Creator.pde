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
  Button btnBck, btnObj, btnBarr, btnUnit, 
    btnBckChck, btnObjChck, btnBarrChck, btnUnitChck; 
  Button btnLoad, btnDel, btnMove, btnAdd;
  Button btnAttacker, btnDefender;
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
    int btnHDiv = 30;
    btnBck = 
      new Button(new PVector(width/8, height*(btnHDiv-4)/btnHDiv), 
      new PVector(width*3/8, height/(btnHDiv+1)), 
      "Background");
    btnBck.setChecked(true);

    btnObj = 
      new Button(new PVector(width/8, height*(btnHDiv-3)/btnHDiv), 
      new PVector(width*3/8, height/(btnHDiv+1)), 
      "Objects");

    btnBarr = 
      new Button(new PVector(width/8, height*(btnHDiv-2)/btnHDiv), 
      new PVector(width*3/8, height/(btnHDiv+1)), 
      "Barriers");  

    btnUnit = 
      new Button(new PVector(width/8, height*(btnHDiv-1)/btnHDiv), 
      new PVector(width*3/8, height/(btnHDiv+1)), 
      "Units");

    btnBckChck = 
      new Button(new PVector(2, height*(btnHDiv-4)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Hide");
    btnBck.setChecked(true);

    btnObjChck = 
      new Button(new PVector(2, height*(btnHDiv-3)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Hide");

    btnBarrChck = 
      new Button(new PVector(2, height*(btnHDiv-2)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Hide");  

    btnUnitChck = 
      new Button(new PVector(2, height*(btnHDiv-1)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Hide");

    btnLoad = 
      new Button(new PVector(width*7/8-width/16, height*(btnHDiv-3)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Load");
    btnAdd = 
      new Button(new PVector(width*7/8-width/16, height*(btnHDiv-2)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Add"); 
    btnDel = 
      new Button(new PVector(width*5/8 -width/16, height*(btnHDiv-3)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Delete");
    btnMove = 
      new Button(new PVector(width*5/8 -width/16, height*(btnHDiv-2)/btnHDiv), 
      new PVector(width/8-2, height/(btnHDiv+1)), 
      "Move");

    btnAttacker = 
      new Button(new PVector(width*7/8-width/16, height*(btnHDiv-1)/btnHDiv), 
      new PVector(width/6-2, height/(btnHDiv+1)), 
      "Attacker");
    btnDefender = 
      new Button(new PVector(width*5/8-width/16, height*(btnHDiv-1)/btnHDiv), 
      new PVector(width/6-2, height/(btnHDiv+1)), 
      "Defender");

    btnBckChck.setChecked(true);
    btnObjChck.setChecked(true);
    btnBarrChck.setChecked(true);
    btnUnitChck.setChecked(true);
    btnMove.setChecked(true);

    btnAttacker.setChecked(true);
    showObjBtns(false); 

    btnsCreator = new ArrayList<Button>();
    btnsCreator.add(btnBck);
    btnsCreator.add(btnObj);
    btnsCreator.add(btnBarr);
    btnsCreator.add(btnUnit);
    btnsCreator.add(btnBckChck);
    btnsCreator.add(btnObjChck);
    btnsCreator.add(btnBarrChck);
    btnsCreator.add(btnUnitChck);
    btnsCreator.add(btnLoad);
    btnsCreator.add(btnAdd);
    btnsCreator.add(btnDel);
    btnsCreator.add(btnMove);

    btnsCreator.add(btnAttacker);
    btnsCreator.add(btnDefender);

    PFont font = createFont("Monospaced-Bold", 30);
    for (Button btn : btnsCreator) 
    {
      btn.font = font;
    }

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
      level.drawSelObj();
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
          level.clickBackgr(mScr);
        }
        if (btnObj.checked)
        {
          level.clickObjs(mScr, tlPck);
        }
        if (btnBarr.checked)
        {
          level.clickBarr(mScr);
        }
        if (btnUnit.checked)
        {
          level.clickUnits(mScr, btnAttacker.checked);
          if (level.isSelected())
          {
            try
            {
              Unit u = (Unit) level.selectedObj;
              if (u.teamNum == 0)
              {
                btnAttacker.setChecked(true);
                btnDefender.setChecked(false);
              } else
              {
                btnAttacker.setChecked(false);
                btnDefender.setChecked(true);
              }
            }
            catch(Exception e) 
            {
            }
          }
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

  void checkMenuBtns() 
  {
    if (btnNew.pressed)
    {
      btnNew.reset();
      levelLoaded = false;
      level = new LevelLoader();
      state = CreatorStates.creator;
      dte.showAddItemDialog("");
      selectTileFromDir(Storage.dataDirBacks);
    }

    if (btnOpen.pressed)
    {
      btnOpen.reset();
      String path = Storage.createFolder(level.levelFolder);
      scrlbSelect = 
        new ScrollBar(path, ".csv");
      if (scrlbSelect.loaded) 
      {
        prevState = CreatorStates.menu; 
        state = CreatorStates.select;
      } else
      {
        scrlbSelect = null;
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
      new ScrollBar(backsDir, ".png");
    if (scrlbSelect.loaded) 
    {
      prevState = CreatorStates.creator; 
      state = CreatorStates.select;
    } else
    {
      scrlbSelect = null;
      println("No valid tile to load.");
    }
  }

  void showObjBtns(boolean show) 
  {
    btnAttacker.visible = show;
    btnDefender.visible = show;
  }

  boolean checkCreatorBtns() 
  {
    boolean ret = false;
    if (btnBck.pressed)
    {
      btnBck.reset();
      btnBck.setChecked(true);
      btnObj.setChecked(false);
      btnBarr.setChecked(false); 
      btnUnit.setChecked(false); 
      showObjBtns(false); 
      ret = true;
    }

    if (btnObj.pressed)
    {
      btnObj.reset();
      btnBck.setChecked(false);
      btnObj.setChecked(true);
      btnBarr.setChecked(false); 
      btnUnit.setChecked(false); 
      showObjBtns(false); 
      ret = true;
    }

    if (btnBarr.pressed)
    {
      btnBarr.reset();
      btnBck.setChecked(false);
      btnObj.setChecked(false);
      btnBarr.setChecked(true); 
      btnUnit.setChecked(false);
      showObjBtns(false); 
      ret = true;
    }

    if (btnUnit.pressed)
    {
      btnUnit.reset();
      btnBck.setChecked(false);
      btnObj.setChecked(false);
      btnBarr.setChecked(false); 
      btnUnit.setChecked(true); 
      showObjBtns(true); 
      ret = true;
    }

    if (btnLoad.pressed)
    {
      btnLoad.reset();

      if (btnBck.checked)
      {
        selectTileFromDir(Storage.dataDirBacks);
      } else if (btnObj.checked)
      {
        selectTileFromDir(Storage.dataDirTiles);
      } else if (btnUnit.checked)
      {
        scrlbSelect = new ScrollBar(Defs.units);

        if (scrlbSelect.loaded) 
        {
          prevState = CreatorStates.creator; 
          state = CreatorStates.select;
        } else scrlbSelect = null;
      }

      ret = true;
    }

    if (btnDel.pressed)
    {
      btnDel.reset();
      level.deleteSelected();
      ret = true;
    } 

    if (btnMove.pressed)
    {
      btnMove.reset();
      btnMove.setChecked(true);
      btnAdd.setChecked(false);
      level.setMoving();
      ret = true;
    } 

    if (btnAdd.pressed)
    {
      btnAdd.reset();
      btnMove.setChecked(false);
      btnAdd.setChecked(true);
      level.setAdding();
      ret = true;
    } 

    if (btnAttacker.pressed)
    {
      btnAttacker.reset();
      btnAttacker.setChecked(true);
      btnDefender.setChecked(false);
      if (level.isSelected())
      {
        try
        {
          Unit u = (Unit) level.selectedObj;
          u.teamNum = 0;
        } 
        catch(Exception e) 
        {
        }
      }
      ret = true;
    }

    if (btnDefender.pressed)
    {
      btnDefender.reset();
      btnAttacker.setChecked(false);
      btnDefender.setChecked(true);
      if (level.isSelected())
      {
        try
        {
          Unit u = (Unit) level.selectedObj;
          u.teamNum = 1;
        } 
        catch(Exception e) 
        {
        }
      }
      ret = true;
    }

    ret |= checkedLayerTest(btnBckChck);
    ret |= checkedLayerTest(btnObjChck);
    ret |= checkedLayerTest(btnBarrChck);
    ret |= checkedLayerTest(btnUnitChck);

    if (ret) 
    {
      level.viewBck = btnBckChck.checked;
      level.viewObj = btnObjChck.checked;
      level.viewBarr = btnBarrChck.checked;
      level.viewUnit = btnUnitChck.checked;
    }
    return ret;
  }

  boolean checkedLayerTest(Button btn) 
  {
    if (btn.pressed)
    {
      btn.reset();
      btn.setChecked(!btn.checked);

      if (btn.checked) btn.text = "Hide";
      else btn.text = "Show";

      return true;
    } 
    return false;
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
