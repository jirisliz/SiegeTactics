class Grid
{
  float rows, cols;
  float rowSz, colSz; // in pixels
  
  float xOffset, yOffset;
  
  // Array of blocks (walls, buildings,...) 
  boolean[][] blocks;
  
  Grid(int aRows, int aCols, int aRowSz, int aColSz) 
  {
    rows = aRows;
    cols = aCols;
    rowSz = aRowSz*mScale;
    colSz = aColSz*mScale;
    
    xOffset = width/2 - cols*colSz/2;
    yOffset = height/2 - rows*rowSz/2;
    //xOffset = 0;
    //yOffset = 0;
    
    blocks = new boolean[(int)cols][(int)rows];
    blocks[2][2] = true;
    blocks[3][4] = true;
  }
  
  void draw()
  {
    for(int i = 0 ; i < rows ; i++)
    {
     for(int j = 0 ; j < cols ; j++)
     {
       if(blocks[j][i])
       {
        float x1 = xOffset + j*colSz;
        float y1 = yOffset + i*rowSz;
        fill(128);
        noStroke();
        rect(x1, y1, colSz, rowSz);
       }
     }
    }
    
    if(debug)
    {
      for(int i = 0 ; i <= rows ; i++)
      {
        float x1 = xOffset;
        float y1 = yOffset + i*rowSz;
        float x2 = xOffset + cols*colSz;
        float y2 = yOffset + i*rowSz;
        stroke(1);
        strokeWeight(1);
        line(x1, y1, x2, y2);
      }
      
      for(int j = 0 ; j <= cols ; j++)
      {
        float x1 = xOffset + j*colSz;
        float y1 = yOffset;
        float x2 = xOffset + j*colSz;
        float y2 = yOffset + rows*rowSz;
        stroke(1);
        strokeWeight(1);
        line(x1, y1, x2, y2);
      }
      
    }
  }
}
