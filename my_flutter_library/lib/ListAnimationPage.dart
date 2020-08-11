import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/widget/CommonWidget.dart';
import 'package:my_flutter_library/widget/MyTabBar.dart';

import 'util/Constant.dart';

//todo 入场动画待完成 计划实现 缩放, 移动,  淡入 三种动画效果
//todo 下拉刷新, 上拉加载待完成
class ListAnimationPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return ListAnimationPageState();
  }
}

class ListAnimationPageState extends State<ListAnimationPage>{

  @override
  Widget build(BuildContext context){
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("List 入场动画"),
          bottom: MyTabBar(
              List.castFrom(["日", "月", "年"]),
              _handler,
              primaryColor: Theme.of(context).primaryColor,
          ),
          elevation: 0,
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index){
            return CommonWidget.buildMsgItem("itemName", "ListView.separated 构造列表项的分割线, 分割线使用Divider", "2020-01-01", index);
          },
          separatorBuilder: (BuildContext context, int index){
            return Divider(
              height: 0.5,
              indent: 105.w,
              color: Constant.borderSideColor,
            );
          },
          itemCount: 15),
    );
  }

  void _handler(int index) {
      print("currentIndex: $index");
  }
}