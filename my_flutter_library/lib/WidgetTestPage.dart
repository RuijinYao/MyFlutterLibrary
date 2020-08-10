import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          return Container(
            //ModalBottomSheet 的高度为子控件高度, 如果没指定, 则为默认值
            height: 400.h,
            color: Colors.black12.withAlpha(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 60.h,
                  child: Center(
                      child: Text("分享", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp))
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildShareItem(FontAwesomeIcons.google, Colors.yellow, "Google"),
                      _buildShareItem(FontAwesomeIcons.facebook, Colors.blue, "Facebook"),
                      _buildShareItem(FontAwesomeIcons.twitter, Colors.lightBlue, "Twitter"),
                      _buildShareItem(FontAwesomeIcons.link, Colors.orange, "复制链接"),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: ScreenUtil.screenWidth,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Center(child: Text("取消", style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                )
              ],
            ),
          );
        }).then((_) {
      print("关闭BottomSheet后的操作可在这里执行");
    });
  }

  Widget _buildShareItem(IconData iconData, Color color, String itemName){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(iconData, color: color, size: 30),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Text("$itemName", style: TextStyle(fontSize: 20.sp),),
          )
        ],
      ),
    );
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
