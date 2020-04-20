import android.os.Environment;

static class Storage
{
  // Data folders
  static String dataDirBacks = "backs";
  static String dataDirTiles = "tiles";
  
  // Game folders
  static String gameFolder = "SiegeTactics";
  static String levelsFolder = "levels";

  static String getPath() 
  {
    File externalDir = new File(Environment.getExternalStorageDirectory(), gameFolder); 

    boolean success = true;
    if (!externalDir.exists()) {
      success = externalDir.mkdirs();
    }
    if ( externalDir == null ) 
    {
      return null;
    }
    return externalDir.getAbsolutePath();
  }
  
  static File[] getFilesList(String path) 
  {
    File dir = new File(path);
    File[] files = dir.listFiles();
    
    return files;
  }
  
  static String createFolder(String fn)
  {
    File f = new File(getPath(), fn);
    boolean success = true;
    if (!f.exists()) {
      success = f.mkdirs();
    }
    if ( f == null ) 
    {
      return null;
    }
    return f.getAbsolutePath();
  } 
  
  static boolean fileExists(String fn) 
  {
    File f = new File(fn);
    return f.exists();
  }
}
