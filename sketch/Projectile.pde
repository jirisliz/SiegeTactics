class Projectile extends Object
{
  PImage img;
  float angle;
  boolean finished = false;
  boolean started = false;
  boolean attackHeight = false;
  
  float maxSpeed = 3;
  PVector v;
  PVector a;
  
  PVector curvePos;
  PVector curveV;
  PVector curveA;
  float dist2Target = 0;
  
  PVector target;

  Projectile(PVector pos, String imgPath) 
  {
    finished = false;
    started = false;
    position = pos.copy();

    img = null;
    try
    {
      img = loadImage(imgPath);
    }
    catch(Exception e) 
    {
      println("Projectile: image not loaded");
      return;
    }
    size = new PVector(img.width, img.height);
    orig = new PVector(img.width/2, img.height/2);
  }

  void fire(Unit targ) 
  {
    target = targ.position.copy();
    // Evaluate target position based on current movement
    v = PVector.sub(target, position);
    v.normalize();
    curveV = v.copy();
    v.mult(maxSpeed);
    
    if(target.x > position.x)curveV.rotate(-HALF_PI);
    else curveV.rotate(HALF_PI);
    
    curveA = curveV.copy();
    curveA.rotate(PI);

    // Setup start params
    dist2Target = target.dist(position);
    curveV.mult(dist2Target/150);
    curveA.mult(7.5/dist2Target);
    
    curvePos = new PVector(0,0);

    // Release projectile
    started = true;
  }
  
  boolean checkScreenBorders(Screen scr) 
  { 
    if(target.dist(position) < 2)return true;
       
    return false;
  }

  void update(Screen scr) 
  {
    if(started) 
    {
      curveV.add(curveA);
      curvePos.add(curveV);
      position.add(v);
      float currDist = target.dist(position);
      if(currDist < dist2Target/4)attackHeight = true;
      else attackHeight = false;
      if(checkScreenBorders(scr))
      {
        finished = true;
      }
    }   
  }
  
  void attack(ArrayList units) 
  {
    if(!attackHeight) return; 
    for (int i = 0; i < units.size(); i++) {
      Unit unit = (Unit) units.get(i);
      if(unit.position.dist(position) < 4)
      {
        unit.attack(1);
        finished = true;
      }
     } 
  }
  
  void draw() 
  {
    if(started) 
    {
      float a = PVector.add(v, curveV).heading() + PI/2;
      pushMatrix();
      translate(position.x+curvePos.x-img.width/2, 
                position.y+curvePos.y-img.height/2);
      rotate(a);
      image(img, 0, 0, img.width, img.height);
      popMatrix();
    }
  }
}
