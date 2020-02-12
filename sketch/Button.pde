class Button
{
  PVector pos;
  PVector size;
  String text;
  boolean pressed = false;
  
  int fill = 170;
  int fillIddle = 170;

  Button(PVector po, PVector sz, String tx) 
  {
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
    return pos.x+size.x >= 0 && pos.x <= width &&
      pos.y+size.y+trY >= 0 && pos.y+trY <= height;
  }

  void reset() 
  {
    pressed = false;
  }

  void mouseReleased(float trY)
  {
    if (isMouseIn(trY)) 
    {
      pressed = true;
      fill = 80;
    }
  }

  void setStyle() 
  {
    stroke(30);
    textSize(50);
    textAlign(CENTER);
  }

  void draw(float trY) 
  {
    if (isVisible(trY)) 
    {
      setStyle();
      if(fill < fillIddle) fill++;
      fill(fill);
      rect(pos.x,pos.y,size.x,size.y,(size.x+size.y)/20);
      fill(25);
      text(text, pos.x+size.x/2,pos.y+size.y/2+25);
    }
  }
}
