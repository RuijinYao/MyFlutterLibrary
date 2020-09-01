import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/Constant.dart';

class CommonWidget{

  static Widget buildTextForm(
      {TextEditingController controller, String hintText, Icon icon, bool obscure = true, Icon suffixIcon, FocusNode focusNode,
          Function suffixOnPress, FormFieldValidator<String> validator, Function onEditingComplete}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: TextFormField(
            decoration: InputDecoration(
              icon: icon,
              hintText: hintText,
              border: InputBorder.none,
              suffixIcon: suffixIcon != null
                  ? IconButton(icon: suffixIcon, onPressed: suffixOnPress)
                  : null,
            ),
            focusNode: focusNode ??= null,
            //输入密码，需要用*****显示
            obscureText: obscure,
            style: TextStyle(fontSize: 16, color: Colors.black),
            validator: validator,
            onEditingComplete: onEditingComplete,
            controller: controller,
        ),
      ),
    );
  }

  static Widget buildLine(){
    return Container(
      height: 1,
      width: 250,
      color: Colors.grey[400],
    );
  }


  static Widget settingItem(String itemName, {String itemValue: "", int maxLine: 1, Function onTap, bool hasTopLine: false}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Constant.borderSideColor),
                  top: hasTopLine ? BorderSide(color: Constant.borderSideColor) : BorderSide.none)),
          height: Constant.listItemHeight.h,
          padding: EdgeInsets.symmetric(horizontal: Constant.listItemPadding.w),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(itemName, style: TextStyle(fontSize: ScreenUtil().setSp(30))),
              ),
              Row(
                children: <Widget>[
                  Offstage(
                    offstage: itemValue == "",
                    child: Container(
                      constraints: BoxConstraints(maxWidth: ScreenUtil.screenWidth * 0.6),
                      child: Text(itemValue,
                          textAlign: TextAlign.end,
                          maxLines: maxLine,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 25.sp, color: Color(0xff505050))),
                    ),
                  ),
                  Offstage(
                    offstage: onTap == null,
                    child: Icon(Icons.chevron_right, color: Color(0xff505050)),
                  )
                ],
              )
            ],
          ),
        ));
  }

  //仿微信的聊天列表项
  static Widget buildMsgItem(String itemName, String itemContent, String time, int count) {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Row(
              children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 15.w),
                      child: Hero(
                          tag: "$itemName$count",
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image(width: 70.w, height: 70.w, image: AssetImage("assets/avatar.jpg")),
                          ),
                      )
                  ),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Text(
                                      itemName,
                                      style: TextStyle(fontSize: 30.sp),
                                  ),
                              ),
                              Text(
                                  itemContent,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black.withAlpha(128)),
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
                                  style: TextStyle(color: Colors.black.withAlpha(128)),
                              ),
                          ),
                          Offstage(
                              offstage: count == 0,
                              child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                      "$count",
                                      style: TextStyle(fontSize: 8, color: Colors.white),
                                  ),
                              ),
                          )
                      ],
                  )
              ],
          ),
      );
  }
}