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
  Designer dsg;


  MainMenu()
  {
    initMain();

    initSelect();

    initDesigner();
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
      "Designer");
    btnExit = 
      new Button(new PVector(width/2-width/4, height*9/10), 
      new PVector(width/2, height/12), 
      "Exit");
  }

  void initSelect()
  { 
    scrollBar = new ScrollBar();
  }

  void initDesigner()
  {
    dsg = new Designer();
  }

  void draw() 
  {
    background(255);
    switch(state)
    {
    case main:
      pushStyle();
      btnStart.draw(0);
      btnDesigner.draw(0);
      btnExit.draw(0);
      popStyle();
      break;
    case select:

      break;
    case game:

      break;
    case designer:
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

      break;
    case select:

      break;
    case game:

      break;
    case designer:
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

      break;
    case designer:
      dsg.onBackPressed();
      checkDesigner();
      break;
    }
  }

  void checkMainBtns() 
  {
    if (btnStart.pressed)
    {
      btnStart.reset();
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

  void checkDesigner() 
  {
    if (dsg.finished)
    {
      dsg.reset();
      state=MainStates.main;
    }
  }
}
