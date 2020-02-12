enum DesignerStates
{
  menu, select, sizemap, creator;
}

class Designer
{
  Screen scr;
  Button btnNew, btnOpen, btnBack;

  boolean finished = false;

  Designer() 
  {
    btnNew = 
      new Button(new PVector(width/2-width/4, height*7/10), 
      new PVector(width/2, height/12), 
      "New map"); 
    btnOpen = 
      new Button(new PVector(width/2-width/4, height*8/10), 
      new PVector(width/2, height/12), 
      "Open");
    btnBack = 
      new Button(new PVector(width/2-width/4, height*9/10), 
      new PVector(width/2, height/12), 
      "Back");
  }

  void draw() 
  {
    pushStyle();
    btnNew.draw(0);
    btnOpen.draw(0);
    btnBack.draw(0);
    popStyle();
  }

  void mousePressed() 
  {
  }

  void mouseDragged() 
  {
  }

  void mouseReleased() 
  {
    btnNew.mouseReleased(0);
    btnOpen.mouseReleased(0);
    btnBack.mouseReleased(0);
    checkBtns();
  }

  void onBackPressed() 
  {
    finished = true;
  }

  void checkBtns() 
  {
    if (btnBack.pressed)
    {
      btnBack.reset();
      finished = true;
    }
  }

  void reset() 
  {
    finished = false;
  }
}
