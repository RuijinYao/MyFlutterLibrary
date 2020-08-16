import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventChannelTestPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return EventChannelTestPageState();
  }
}

class EventChannelTestPageState extends State<EventChannelTestPage>{

  static String channelName = "my_flutter_library/event_plugin";

  EventChannel eventChannel = EventChannel(channelName);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("EventChannel"),
      ),
      body: Container(
        height: 400,
        child: Center(
          child: StreamBuilder(
            stream: eventChannel.receiveBroadcastStream(),
            initialData: "unknown",
            builder: (context, s){
              return Text("当前蓝牙状态: ${s.data}");
            },
          ),
        )
      ),
    );
  }
}
