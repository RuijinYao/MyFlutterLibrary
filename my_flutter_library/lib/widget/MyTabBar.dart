import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///自定义TabBar, IOS风格
class MyTabBar extends StatefulWidget implements PreferredSizeWidget {

  final List<String> tabs;
  final Function handler;
  final Color primaryColor;

  MyTabBar(this.tabs, this.handler, {this.primaryColor, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyTabBarState();
  }

  ///120.h  =  vertical padding of Container * 2 + height of child Container;
  @override
  Size get preferredSize => Size.fromHeight(90);
}

class MyTabBarState extends State<MyTabBar> {
  int groupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20),
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoSegmentedControl(
                onValueChanged: changeTab,
                borderColor: widget.primaryColor,
                selectedColor: widget.primaryColor,
                pressedColor: widget.primaryColor.withOpacity(0.5),
                unselectedColor: Colors.white,
                groupValue: groupValue,
                children: _buildChild(constraints),
              ),
            ],
          );
        }));
  }

  Map<int, Widget> _buildChild(BoxConstraints constraints) {
    Map<int, Widget> children = Map();
    ///自定义第一个child的宽高, 往后的同类将沿用之前的样式
    children.putIfAbsent(
      0,
      () => Container(
        width: (constraints.maxWidth / widget.tabs.length) - 35.w,
        height: 50,
        child: Center(
          child: Text(widget.tabs[0], style: TextStyle(fontSize: 30.sp)),
        ),
      ),
    );

    for (int i = 1; i < widget.tabs.length; i++) {
      children.putIfAbsent(i, () => Text(widget.tabs[i], style: TextStyle(fontSize: 30.sp)));
    }

    return children;
  }

  void changeTab(index) {
    this.setState(() {
      groupValue = index;
    });
    widget.handler(index);
  }
}
