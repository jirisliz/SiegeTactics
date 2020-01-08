class Grid
{
  int rows, cols;
  int rowSz, colSz; // in pixels
  
  int xOffset, yOffset;
  
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
    
    blocks = new boolean[cols][rows];
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
        int x1 = xOffset + j*colSz;
        int y1 = yOffset + i*rowSz;
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
        int x1 = xOffset;
        int y1 = yOffset + i*rowSz;
        int x2 = xOffset + cols*colSz;
        int y2 = yOffset + i*rowSz;
        stroke(1);
        strokeWeight(1);
        line(x1, y1, x2, y2);
      }
      
      for(int j = 0 ; j <= cols ; j++)
      {
        int x1 = xOffset + j*colSz;
        int y1 = yOffset;
        int x2 = xOffset + j*colSz;
        int y2 = yOffset + rows*rowSz;
        stroke(1);
        strokeWeight(1);
        line(x1, y1, x2, y2);
      }
      
    }
  }
}
