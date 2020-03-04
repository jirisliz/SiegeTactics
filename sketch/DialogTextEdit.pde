import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.app.AlertDialog;
import android.widget.EditText;
import android.os.Looper;

class DialogTextEdit
{
  PApplet th;
  Context ctx;
  Activity act;
  
  String title = "";
  String message = "";
  String txt = "";
  
  boolean finished = false;

  DialogTextEdit(PApplet aTh) 
  {
    th = aTh;
    act = th.getActivity();
    ctx = th.getActivity().getApplicationContext();
    Looper.prepare();
  }


  private void showAddItemDialog(String s) {
    txt = s;
    finished = false; 
    th.getActivity().runOnUiThread(new Runnable() {
      //@ Override
      public void run() {
        final EditText taskEditText = new EditText(ctx);
        taskEditText.setText(txt);
        AlertDialog dialog = new AlertDialog.Builder(act)
          .setTitle(title)
          .setMessage(message)
          .setView(taskEditText)
          .setPositiveButton("Add", new DialogInterface.OnClickListener() {
          @Override
            public void onClick(DialogInterface dialog, int which) {
            txt = String.valueOf(taskEditText.getText());
            finished = true;
          }
        }
        )
        .setNegativeButton("Cancel", null)
          .create();
        dialog.show();
      }
    }
    );
  };
}
