package yao.my_flutter_library;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static  final String TAG = "MainActivity";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        //GeneratedPluginRegistrant.registerWith(flutterEngine);


        InstallApkPlugin.registerWith(flutterEngine.getDartExecutor().getBinaryMessenger(), this);
    }
}
