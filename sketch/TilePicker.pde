class TilePicker
{
  Screen mScr;
  LevelLoader level;
  Button btnBack;
  Button btnSelect;

  boolean finished = false;

  ArrayList<PVector> selTiles;

  PGraphics selArea;
  
  // tile definitions
  String tileName;
  PVector tilePos;
  PVector tileSz;

  TilePicker(String tile) 
  {
    finished = false;
    tileName = tile;
    level = new LevelLoader(tile);
    mScr = new Screen(level.getWidth(), level.getHeight());
    mScr.bordersCheck = false;
    mScr.fitWidth();
    mScr.mScaleMin /= 2;
    mScr.mScaleMax = mScr.mScaleMin + 20;
    mScr.mScale = mScr.mScaleMin;
    mScr.selEnabled = true;
    //scr = mScr;

    btnBack = new Button(new PVector(width*6/8, height*19/20), 
      new PVector(width*2/8, height/21), 
      "Back"); 

    btnSelect = new Button(new PVector(width/8, height*19/20), 
      new PVector(width*4/8, height/21), 
      "Select"); 

    selArea = null;

    level.drawTiles();
  }

  PGraphics getSelectedTile() 
  {
    //if (selTiles == null)return null;
    return selArea;
  }
  
  TileObject getSelectedTileObject() 
  {
    TileObject ret = new TileObject(tileName, tilePos, tileSz);
    ret.setTileImg(selArea);
    return ret;
  }

  void draw() 
  {
    background(0);
    mScr.transformPush();
    level.draw();
    if (selTiles != null) 
    {
      pushStyle();
      noFill();
      strokeWeight(1);
      stroke(30, 250, 30);

      for (PVector selTile : selTiles) 
      {
        rect(selTile.x*level.getBlockSz(), 
          selTile.y*level.getBlockSz(), 
          level.getBlockSz(), level.getBlockSz());
      }

      popStyle();
    }       
    mScr.transformPop();

    // draw selected tile
    if (selArea != null) 
    {
      image(selArea, 
        selArea.width+10, selArea.height+10);
    }


    btnBack.draw(0);
    btnSelect.draw(0);
  }

  void mousePressed() 
  {
    mScr.mousePressed();
  }

  void mouseDragged() 
  {
    mScr.mouseDragged();
  }

  void mouseReleased() 
  {
    btnBack.mouseReleased(0);
    btnSelect.mouseReleased(0);
    if (!checkBtns()) 
    {
      mScr.mouseReleased();
      selTiles = new ArrayList<PVector>();
      if (mScr.selFinished)
      {
        PVector start = mScr.touchStart;
        PVector end = mScr.touchEnd;
        markSelection(start, end);
      } else
      {
        markTile(new PVector(mouseX, mouseY));
      }
      if (selTiles != null) 
      {
        int mx = width;
        int my = height;
        int Mx = 0;
        int My = 0;
        for (PVector selTile : selTiles) 
        {
          int x = (int)selTile.x;
          int y = (int)selTile.y;
          if (mx > x) mx = x;
          if (my > y) my = y;
          if (Mx < x) Mx = x;
          if (My < y) My = y;
        } 
        if (Mx-mx < 0 || My-my < 0)
        {
          selArea = null;
          return;
        }

        int blockSz = level.getBlockSz();
        selArea = createGraphics((Mx-mx+1)*blockSz, (My-my+1)*blockSz);
        
        tileSz = new PVector(selArea.width, selArea.height);
        tilePos = new PVector(mx*blockSz, my*blockSz);
        
        selArea.beginDraw();
        for (PVector selTile : selTiles) 
        {
          selArea.image(
            level.ground.getTile((int)selTile.x, (int)selTile.y), 
            ((int)selTile.x-mx)*blockSz, ((int)selTile.y-my)*blockSz);
        }
        selArea.endDraw();
      }
    }
  }

  void markSelection(PVector start, PVector end) 
  {
    int blockSz = level.getBlockSz();
    IntHolder sx = new IntHolder((int) (start.x / blockSz));
    IntHolder sy = new IntHolder((int) (start.y / blockSz)) ;
    IntHolder ex = new IntHolder((int) (end.x / blockSz));
    IntHolder ey = new IntHolder((int) (end.y / blockSz));

    if (sx.val> ex.val) Defs.swap(sx, ex);
    if (sy.val> ey.val) Defs.swap(sy, ey);

    for (int i = sx.val; i <= ex.val; i++) 
    {
      for (int j = sy.val; j <= ey.val; j++) 
      {
        PVector target = 
          new PVector(i*blockSz, j*blockSz);
        markTile(target);
      }
    }
  } 

  void markTile(PVector pos) 
  {
    PVector selTile = mScr.screen2World(pos);
    if (selTile.x > level.getWidth() || 
      selTile.y > level.getHeight() ||
      selTile.x < 0 || selTile.y < 0) 
    {
      selTile = null;
    } else
    {
      selTile.x = (int) selTile.x / level.getBlockSz();
      selTile.y = (int) selTile.y / level.getBlockSz();
      selTiles.add(selTile);
    }
  }

  boolean checkBtns() 
  {
    if (btnBack.pressed) 
    {
      finished = true;
      return true;
    }
    if (btnSelect.pressed)
    {

      finished = true;
      return true;
    }
    return false;
  }
}
