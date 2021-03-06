class Button
{
  PVector pos;
  PVector size;
  String text;
  PFont font;
  boolean pressed = false;
  boolean checked = false;
  boolean visible = true;
  
  int fillChecked = 210;
  int fill = 170;
  int fillIddle = 170;

  Button(PVector po, PVector sz, String tx) 
  {
    // fonts: Monospaced-BoldItalic Serif-BoldItalic SansSerif-Italic SansSerif-BoldItalic Monospaced-Bold SansSerif-Bold SansSerif Monospaced-Italic Serif-Italic Serif Monospaced Serif-Bold

    font = createFont("Monospaced-Bold", 50);
    pos=po;
    size=sz;
    text=tx;
  }

  boolean isMouseIn(float trY) 
  {
    return mouseX > pos.x && mouseX < pos.x+size.x && 
      mouseY > pos.y+trY && mouseY < pos.y+size.y+trY;
  }

  boolean isVisible(float trY) 
  {
    if(!visible) return false;
    return pos.x+size.x >= 0 && pos.x <= width &&
      pos.y+size.y+trY >= 0 && pos.y+trY <= height;
  }

  void reset() 
  {
    pressed = false;
    fill = fillIddle;
  }

  void mouseReleased(float trY)
  {
    if(!visible) return;
    if (isMouseIn(trY)) 
    {
      pressed = true;
      fill = 80;
    }
  }
  
  void setChecked(boolean state) 
  {
    checked = state;
  }

  void setStyle() 
  {
    stroke(30);
    strokeWeight(4);
    textFont(font);
    textAlign(CENTER, CENTER);
  }

  void draw(float trY) 
  {
    if (isVisible(trY)) 
    {
      setStyle();
      if(fill < fillIddle) fill++;
      if(checked) fill(fillChecked, 250);
      else fill(fill, 150);
      rect(pos.x,pos.y,size.x,size.y,30);
      fill(25);
      text(text, pos.x+size.x/2,pos.y+size.y/2);
    }
  }
}
