import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_library/Application.dart';
import 'package:my_flutter_library/BezierTestPage.dart';
import 'package:my_flutter_library/DownloadPage.dart';
import 'package:my_flutter_library/EventChannelTestPage.dart';
import 'package:my_flutter_library/ListAnimationPage.dart';
import 'package:my_flutter_library/WaterRipplePage.dart';
import 'package:my_flutter_library/WebViewPage.dart';
import 'package:my_flutter_library/login/LoginPage.dart';
import 'package:my_flutter_library/route/Routes.dart';
import 'package:sp_util/sp_util.dart';

void main() async{

  //解决 ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();

  //获取路由对象
  final router = Router();
  //调用路由配置方法
  Routes.configRoutes(router);
  //将路由对象静态化, 便于之后调用
  Application.router = router;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //将路由配置到MaterialApp中
      onGenerateRoute: Application.router.generator,
      home: WebViewPage(title: "WebView练习", url: "https://github.com/RuijinYao/"),
    );
  }
}
