class Grid
{
  int rows, cols;
  
  // Array of blocks (walls, buildings,...) 
  boolean[][] blocks;
  
  Grid(int aRows, int aCols) 
  {
    rows = aRows;
    cols = aCols;
    blocks = new boolean[cols][rows];
  }
}