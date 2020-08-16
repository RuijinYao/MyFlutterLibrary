package yao.my_flutter_library;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import static android.app.Activity.RESULT_OK;

/**
 * @ClassName: InstallApkPlugin
 * @Description: java类作用描述
 * @Author: yao
 * @Date: 2020/8/13 11:29
 */
class InstallApkPlugin implements ActivityAware, FlutterPlugin, MethodChannel.MethodCallHandler{

    private static  final String TAG = "InstallApkPlugin";

    private static final String CHANNEL = "my_flutter_library/plugin";

    private static final int REQUEST_MANAGE_UNKNOWN_APP_SOURCES = 101;

    //负责针对处理结果 回馈 flutter;
    private MethodChannel.Result mResult;
    private MethodCall mMethodCall;

    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Activity activity;

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityBinding = binding;

        setup(pluginBinding.getBinaryMessenger(), activityBinding.getActivity());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        tearDown();
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        pluginBinding = binding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        pluginBinding = null;
    }


    public static void registerWith(PluginRegistry.Registrar registrar) {
        InstallApkPlugin plugin = new InstallApkPlugin();
        plugin.setup(registrar.messenger(), registrar.activity());
    }

    private void setup(final BinaryMessenger messenger, final Activity activity) {
        this.activity = activity;
        MethodChannel methodChannel = new MethodChannel(messenger, CHANNEL);
        methodChannel.setMethodCallHandler(this);

        activityBinding.addActivityResultListener(new PluginRegistry.ActivityResultListener() {
            @Override
            public boolean onActivityResult(int requestCode, int resultCode, Intent data) {

                Log.e(TAG, "code=" + requestCode + ",resultCode=" + resultCode );
                Log.e(TAG, data!=null ? "is not null" : "is null");

                if (requestCode == REQUEST_MANAGE_UNKNOWN_APP_SOURCES) {
                    if (resultCode == RESULT_OK) {
                        installApp();
                    } else {
                        //用户没有打开 安装权限, 给出提醒, 重新申请权限
                        applyInstall();
                    }

                    return true;
                }

                //@return true if the new intent has been handled
                return false;
            }
        });
    }

    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        mResult = result;
        mMethodCall = methodCall;
        switch (methodCall.method) {
            case "install":
                applyInstall();
                break;
            default:
                result.notImplemented();
                break;
        }
    }


    //是否拥有安装未知apk的权限
    void applyInstall() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            boolean canRequestPackageInstalls = activity.getPackageManager().canRequestPackageInstalls();
            Log.e(TAG, canRequestPackageInstalls + "");
            if (!canRequestPackageInstalls) {
                Uri packageUri = Uri.parse("package:" + activity.getPackageName());
                Intent intent1 = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageUri);
                activity.startActivityForResult(intent1, REQUEST_MANAGE_UNKNOWN_APP_SOURCES);
            } else {
                installApp();
            }
        } else {
            installApp();
        }
    }

    //安装apk
    void installApp() {
        // 获取flutter传递过来的数据, apk 文件的路径
        Map<String, Object> args = (Map<String, Object>) mMethodCall.arguments;
        String path = (String) args.get("path");
        Intent intent = new Intent(Intent.ACTION_VIEW);
        File file = new File(path);
        Log.i(TAG, "安装路径==" + path);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Uri apkUri = FileProvider.getUriForFile(activity, "yao.my_flutter_library.flutter_downloader.provider", file);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
        } else {
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Uri uri = Uri.fromFile(file);
            intent.setDataAndType(uri, "application/vnd.android.package-archive");
        }

        //"installApk"将回复给flutter层
        mResult.success("installApk");
        activity.startActivity(intent);
    }

    private void tearDown() {
        activityBinding = null;
        mMethodCall = null;
    }
}
