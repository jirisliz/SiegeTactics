class ScrollBar {
  float totalHeight;
  float translateY;
  float opacity;
  float barWidth;
  
  float velocity=0;
  float inertia=0.8;
  float lastPos;
  float initPos;
  boolean pressed = false;
  boolean moving = false;
  
  ArrayList<Button> btns;
  
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
  
  ScrollBar() {
    btns = new ArrayList<Button>();
    totalHeight = height;
    barWidth = 0.05 * width;
    translateY = 0;
    opacity = 0;
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
  }
  void update(float dy) { 
    if (totalHeight + translateY + dy > height) {
      translateY += dy;
      moving = true;
      if (translateY > 0) translateY = 0;
      lastPos=translateY-dy;
    }
  }
  void draw() {
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
      rect(x, y, w, h, 0.2 * w);
      popStyle();
    }
  }
}
