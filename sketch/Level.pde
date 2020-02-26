abstract class Level
{
  // Grid size 
  int mBlockSz = 16; 
  int mGridCols = 16;
  int mGridRows = 32;
 
  void mouseClickedEvent() 
  {
    
  }
  
  PVector getLevelSize() 
  {
    return new PVector(mBlockSz*mGridCols, mBlockSz*mGridRows);
  }
  
  abstract void update();
  abstract void draw();
}