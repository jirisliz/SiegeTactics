import android.os.Environment;

static class Storage
{
  static String gameFolder = "SiegeTactics";

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
