class ScrollBar {
  float totalHeight;
  float translateY;
  float opacity;
  float barWidth;
  
  float velocity=0;
  float inertia=0.6;
  float lastPos;
  float initPos;
  boolean pressed = false;
  boolean moving = false;
  boolean loaded = false;
  
  int layoutTopSpace = 100;
  
  ArrayList<Button> btns;
  
  Button lastClickedBtn = null;
  
  void init() 
  {
    btns = new ArrayList<Button>();
    totalHeight = height;
    barWidth = 0.05 * width;
    translateY = 0;
    opacity = 0;
  }
  
  ScrollBar(float w, float h) {
    totalHeight = h;
    barWidth = w;
    translateY = 0;
    opacity = 0;
  }
  
  ScrollBar(ArrayList<Button> b) {
    btns = b;
    totalHeight = height;
    barWidth = 0.05 * width;
    translateY = 0;
    opacity = 0;
    recalcSz();
  }
  
  ScrollBar() 
  {
    init(); 
  }
  
  ScrollBar(String dir, String ext) 
  {
    // list levels
    File[] files = Storage.getFilesList(dir);
    if (files.length <= 0)
    {
      loaded = false; 
      return;
    }
    init(); 
    
    this.layoutTopSpace = height/2; // for better one hand access
    for (int i = 0; i <= files.length - 1; i++)   
    {
      String name = files[i].getName();
      if (name.contains(ext))
      {
        name = name.replace(ext, "");
        //println("scrollBar add: " + name);
        this.add(name);
      }
    }
    loaded = true; 
  }

  ScrollBar(String[] strs) 
  {
    if (strs.length == 0) 
    {
      loaded = false; 
      return;
    }
    init(); 
    this.layoutTopSpace = height/2; // for better one hand access
    for (int i = 0; i <= strs.length - 1; i++)   
    {
      this.add(strs[i]);
    }
    loaded = true; 
  }
  
  void recalcSz() 
  {
    if(btns == null) return;
    Button last = btns.get(btns.size()-1);
    int szY = (int) (last.pos.y+last.size.y) ;
    totalHeight = szY;
  }
 
 void add(Button btn) 
 {
   try
   {
     btns.add(btn);
   }
   catch(Exception e) 
   {
     println("Button add to scrollvar failed!");
     return;
   }
   recalcSz();
 }
 
 void add(String name) 
 {
   int i = btns.size();
   PVector po = new PVector(20, i * 0.08 * height + 20 + layoutTopSpace);
   PVector sz = new PVector(width-40, 0.08 * height - 20);
   Button btn = new Button(po, sz, name);
   add(btn);
 }
  
  void open() {
    opacity = 150;
    velocity = 0;
    initPos = translateY;
    pressed = true;
  }
  void close() {
    pressed = false;
    if(abs(initPos-translateY) > 20)
       velocity=constrain(lastPos-translateY, -100,100);
       
    if (!this.moving) 
    {
      for (Button btn : btns) {
        btn.mouseReleased(translateY);
      }
    }
    checkBtns();
  }
  void update(float dy) { 
    if (totalHeight + translateY + dy > height) {
      translateY += dy;
      moving = true;
      if (translateY > 0) translateY = 0;
      lastPos=translateY-dy;
    }
  }
  
  void checkBtns() 
  {
    for (Button btn : btns) {
    if(btn.pressed) 
    {
      btn.reset();
      lastClickedBtn = btn;
    }
   } 
  }
  
  void draw() {
    background(0);
    pushMatrix();
    translate(0, this.translateY);
    pushStyle();
    btns.get(0).setStyle();
    for (Button btn : btns) {
      btn.draw(translateY);
    }
    popStyle();
    popMatrix();
    
    if(velocity < -2*inertia)
    {
      velocity += inertia;
      translateY-=velocity;
      if (translateY > 0) 
      {
        translateY = 0;
        velocity = 0;
      }
    }
    else if(velocity > 2*inertia) 
    {
      velocity -= inertia;
      translateY-=velocity;
      if (totalHeight + translateY < height) 
      {
        translateY = height - totalHeight;
        velocity = 0;
      } 
    }
    if(abs(velocity) < 2*inertia && !pressed) 
    {
      opacity = 0;
      moving = false;
    }
    
    if (0 < opacity && totalHeight > height) {
      float frac = (height / totalHeight);
      float x = width - 1.5 * barWidth;
      float y = PApplet.map(translateY / totalHeight, -1, 0, height, 0);
      float w = barWidth;
      float h = frac * height;
      pushStyle();
      fill(150, opacity);
      stroke(120);
      rect(x, y, w, h, 0.2 * w);
      popStyle();
    }
  }
  
  Button getLastClickedBtn() 
  {
    return lastClickedBtn;
  }
  
}
