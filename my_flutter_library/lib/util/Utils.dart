import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Constant.dart';

class Utils {

    //MD5加密
    static generateMd5(String password) {
        if (password != null) {
            var content = Utf8Encoder().convert(password);
            var digest = md5.convert(content);
            return hex.encode(digest.bytes).toString();
        }
    }

  //普通数组选择器
  static void getPicker(BuildContext context, String title, List data, Function(Picker picker, List value) onConfirm){
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: data),
        hideHeader: false,
        height: ScreenUtil().setHeight(380.0),
        itemExtent: ScreenUtil().setHeight(84.0),
        title: Text(title),
        cancelText: "取消",
        confirmText: "确认",
        onConfirm: (Picker picker, List value) {
          onConfirm(picker, value);
        }
    ).showModal(context);
  }

  //日期选择器, 默认显示年月日,  type != 1 时, 只选择 年
  static showDatePicker(BuildContext context, {int type = 1, Function onConfirm}) {
    Picker(
        adapter: DateTimePickerAdapter(
            type: type == 1 ? PickerDateTimeType.kYMD : PickerDateTimeType.kY,
            isNumberMonth: true,
            yearBegin: Constant.beginYear,
            yearEnd: Constant.endYear,
            yearSuffix: "年",
            monthSuffix: "月",
            daySuffix: "日"
        ),
        height: ScreenUtil().setHeight(380.0),
        itemExtent: ScreenUtil().setHeight(84.0),
        hideHeader: false,
        title: Text("选择日期"),
        cancelText: "取消",
        confirmText: "确认",
        onConfirm: (Picker picker, List value) {
          onConfirm(picker, value);
        }
    ).showModal(context);
  }
}