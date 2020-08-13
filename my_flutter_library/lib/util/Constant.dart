import 'package:flutter/material.dart';

///全局常量的存放处
class Constant {

  static bool isDebug = true;

  static double listItemHeight = 90;
  static double listItemPadding = 30;
  static Color borderSideColor = Color(0xffc4c4c4);

  static Color sheetActionColor = Color(0xff007aff);

  static int beginYear = 2000;

  static int endYear = 2100;

  //网络请求 连接与介绍超时时间, 毫秒
  static int connectTime = 5000;
  static int receiveTime = 5000;

  //请求成功返回 1
  static int succeed = 1;

  //请求失败返回 0
  static int error = 0;

  static int connectTimeout = -1;

  static int receiveTimeout = -2;


  //地图的默认缩放等级
  static double mapZoomLevel = 16;

  static String hasLogin = "hasLogin";

  static String token = "token";
}
