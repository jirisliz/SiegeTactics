static class Defs
{
  static String[] units = 
  {
    "BasicSpearman", 
    "BasicSpearman2", 
    "BasicArcher" 
  };
  
  static void swap(IntHolder a, IntHolder b)
  {
    int temp = a.val;
    a.val = b.val;
    b.val = temp;
  }
}

class IntHolder { 
    public int val = 0;
    IntHolder(int v) 
    {
      val = v;
    }
  }