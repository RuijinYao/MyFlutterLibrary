import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_library/CombinationAnimation.dart';
import 'package:my_flutter_library/CustomerFontPage.dart';
import 'package:my_flutter_library/DownloadPage.dart';
import 'package:my_flutter_library/ListAnimationPage.dart';
import 'package:my_flutter_library/PagerGridPage.dart';
import 'package:my_flutter_library/StaggeredGridPage.dart';
import 'package:my_flutter_library/StickHeadPage.dart';
import 'package:my_flutter_library/VotePage.dart';
import 'package:my_flutter_library/WebViewPage.dart';
import 'package:my_flutter_library/login/LoginPage.dart';

Handler loginHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return LoginPage();
});

Handler customerFontHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return CustomerFontPage();
});

Handler stickHeadHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return StickHeadPage();
});

Handler staggeredGridHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return StaggeredGridPage();
});

Handler pagerGridHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return PagerGridPage();
});

Handler downloadHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return DownloadPage();
});

Handler listAnimationHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return ListAnimationPage();
});

Handler combineAnimationHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return CombineAnimationPage();
});

Handler voteHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return VotePage();
});

Handler webViewHandler = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  String title = parameters['title']?.first;
  String url = parameters['url']?.first;
  return WebViewPage(title: title, url: url);
});
