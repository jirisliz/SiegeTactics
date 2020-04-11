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
  
  int getWidth() 
  {
   return mBlockSz*mGridCols;
  }
  
  int getHeight() 
  {
    return mBlockSz*mGridRows;
  }
  
  int getBlockSz() 
  {
    return mBlockSz;
  }
  
  abstract void update();
  abstract void draw();
}