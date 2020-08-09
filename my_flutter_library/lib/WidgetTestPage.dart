import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/util/Utils.dart';
import 'package:my_flutter_library/widget/CommonWidget.dart';
import 'package:my_flutter_library/widget/MessageDialog.dart';

class WidgetTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetTestPageState();
  }
}

class WidgetTestPageState extends State<WidgetTestPage> {

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("常用 Widget 实例"),
      ),
      body: Column(
        children: <Widget>[
          CommonWidget.settingItem("CupertinoActionSheet", onTap: _cupertinoActionSheet),
          CommonWidget.settingItem("BottomSheet", onTap: _showBottomSheet),
          CommonWidget.settingItem("Dialog", onTap: _showDialog),
          CommonWidget.settingItem("ArrayPicker", onTap: _arrayPicker),
          CommonWidget.settingItem("DatePicker", onTap: _datePicker),
        ],
      ),
    );
  }

  void _cupertinoActionSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              "联系我们",
              style: TextStyle(fontSize: 32.sp),
            ),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("取消")),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text('400-888-888')),
              CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text('service@example.com')),
            ],
          );
        });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return Center(
            child: Text("BottomSheet"),
          );
        }).then((_) {
      print("关闭BottomSheet后的操作可在这里执行");
    });
  }

  void _showDialog() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext) {
          return MessageDialog(
              title: "软件更新",
              message: "已发现最新版本\n是否下载?",
              negativeText: "取消",
              positiveText: "确定",
              positiveTextColor: Colors.red,
              onPositivePressEvent: (){
                Navigator.pop(buildContext);
              },
              onCloseEvent: () {
                Navigator.pop(buildContext);
              });
        });
  }

  void _arrayPicker(){
    List<String> sex = ["男","女", "保密"];
    Utils.getPicker(context, "选择性别", sex, (Picker picker, List value){
      print("value: $value, picker: ${picker.getSelectedValues()}");
    });
  }

  void _datePicker(){
    Utils.showDatePicker(context, onConfirm: (Picker picker, List value){
      print("value: $value, picker: ${picker.getSelectedValues()}");
    });
  }
}
