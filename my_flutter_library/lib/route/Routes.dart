import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_library/route/RouteHandlers.dart';

class Routes {
  static Router router;

  static String home = '/home';
  static String login = '/login';
  static String customerFont = '/customerFont';
  static String stickHead = '/stickHead';
  static String staggeredGrid = '/staggeredGrid';
  static String pagerGrid = '/pagerGrid';
  static String download = '/download';
  static String listAnimation = '/listAnimation';
  static String combineAnimation = '/combineAnimation';
  static String vote = '/vote';
  static String webView = '/webView';

  //创建一个 configRoutes , 用于路由配置
  static void configRoutes(Router router){

    router.define(login, handler: loginHandler);

    router.define(customerFont, handler: customerFontHandler);

    router.define(stickHead, handler: stickHeadHandler);

    router.define(staggeredGrid, handler: staggeredGridHandler);

    router.define(pagerGrid, handler: pagerGridHandler);

    router.define(download, handler: downloadHandler);

    router.define(listAnimation, handler: listAnimationHandler);

    router.define(combineAnimation, handler: combineAnimationHandler);

    router.define(vote, handler: voteHandler);

    router.define(webView, handler: webViewHandler);
  }

  // 对参数进行encode，解决参数中有特殊字符，影响fluro路由匹配
  static Future navigateTo(BuildContext context, String path,
      {Map<String, dynamic> params, bool replace = false, bool clearStack = false, TransitionType transition = TransitionType.native}) {
      String query = "";
      if (params != null) {
          int index = 0;
          for (var key in params.keys) {
              var value = Uri.encodeComponent("${params[key]}");
              if (index == 0) {
                  query = "?";
              } else {
                  query = query + "\&";
              }
              query += "$key=$value";
              index++;
          }
      }
      //print('我是navigateTo传递的参数：$query');

      path = path + query;
      return router.navigateTo(context, path, replace: replace, clearStack: clearStack, transition: transition);
  }

  /// fluro 传递中文参数前，先转换，fluro 不支持中文传递
  static String fluroCnParamsEncode(String originalCn) {
      return jsonEncode(Utf8Encoder().convert(originalCn));
  }

  /// fluro 传递后取出参数，解析
  static String fluroCnParamsDecode(String encodeCn) {
      var list = List<int>();
      ///字符串解码
      jsonDecode(encodeCn).forEach(list.add);
      return Utf8Decoder().convert(list);
  }
}