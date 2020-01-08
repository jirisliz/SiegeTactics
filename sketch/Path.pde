// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Path Following

class Path {

  // A Path is an arraylist of points (PVector objects)
  ArrayList<PVector> points;
  // A path has a radius, i.e how far is it ok for the boid to wander off
  float radius;
  
  color c;

  Path(int aR, color aC) {
    // Arbitrary radius of 20
    radius = aR;
    points = new ArrayList<PVector>();
    
    c = aC;
  }

  // Add a point to the path
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }

  // Draw the path
  void display() {

    stroke(c);
    strokeWeight(radius*2);
    noFill();
    for (int i = 0; i < points.size()-1; i += 2) 
    {
      PVector p1 = points.get(i);
      PVector p2 = points.get(i+1);
      line(p1.x, p1.y, p2.x, p2.y);
    }

    if (debug) 
    {
      stroke(0);
      strokeWeight(1);
      noFill();
      for (int i = 0; i < points.size()-1; i += 2) 
      {
        PVector p1 = points.get(i);
        PVector p2 = points.get(i+1);
        line(p1.x, p1.y, p2.x, p2.y);
      }
    } 
  }
}
