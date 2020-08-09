import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index){
            return _buildMsgItem("itemName", "ListView.separated 构造列表项的分割线, 分割线使用Divider", "2020-01-01", index);
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

  //仿微信的聊天列表项
  Widget _buildMsgItem(String itemName, String itemContent, String time, int count){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image(
                  width: 70.w, height: 70.w,
                  image: AssetImage("assets/avatar.jpg")),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(itemName, style: TextStyle(fontSize: 30.sp),),
                ),
                Text(
                  itemContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withAlpha(128)
                  ),
                )
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  time,
                  style: TextStyle(
                      color: Colors.black.withAlpha(128)
                  ),
                ),
              ),

              Offstage(
                offstage: count == 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text("$count", style: TextStyle(fontSize: 8, color: Colors.white),),
                ),
              )
            ],
          )

        ],
      ),
    );
  }
}