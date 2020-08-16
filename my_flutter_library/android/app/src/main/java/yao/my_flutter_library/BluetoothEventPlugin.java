package yao.my_flutter_library;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

class BluetoothEventPlugin implements FlutterPlugin, EventChannel.StreamHandler {

    private static final String TAG = "BatteryEventPlugin";

    public static String CHANNEL = "my_flutter_library/event_plugin";

    private EventChannel channel;
    private Context context;

    private EventChannel.EventSink sink;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Log.e(TAG, "onAttachedToEngine");
        setup(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        tearDown();
    }

    public static void registerWith(final BinaryMessenger messenger, final Activity activity){

        BluetoothEventPlugin plugin = new BluetoothEventPlugin();

        plugin.setup(messenger, activity);
    }

    private void setup(final BinaryMessenger messenger, final Context context) {
        this.context = context;
        channel = new EventChannel(messenger, CHANNEL);
        channel.setStreamHandler(this);
    }


    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {

        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();

            if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
                final int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE,
                        BluetoothAdapter.ERROR);
                switch (state) {
                    case BluetoothAdapter.STATE_OFF:
                        Log.e(TAG, "STATE_OFF");
                        sink.success("STATE_OFF");
                        break;
                    case BluetoothAdapter.STATE_TURNING_OFF:
                        Log.e(TAG, "STATE_TURNING_OFF");
                        sink.success("STATE_TURNING_OFF");
                        break;
                    case BluetoothAdapter.STATE_ON:
                        Log.e(TAG, "STATE_ON");
                        sink.success("STATE_ON");
                        break;
                    case BluetoothAdapter.STATE_TURNING_ON:
                        Log.e(TAG, "STATE_TURNING_ON");
                        sink.success("STATE_TURNING_ON");
                        break;
                }
            }
        }
    };

    //flutter 端监听时触发
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        sink = events;
        IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
        context.registerReceiver(mReceiver, filter);
    }

    //flutter 端取消监听时触发
    @Override
    public void onCancel(Object arguments) {
        sink = null;
        context.unregisterReceiver(mReceiver);
    }

    private void tearDown() {
        channel.setStreamHandler(null);
        channel = null;
        sink = null;
        context = null;
    }
}
