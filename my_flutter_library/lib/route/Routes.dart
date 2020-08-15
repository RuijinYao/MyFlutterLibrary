import 'package:fluro/fluro.dart';
import 'package:my_flutter_library/route/RouteHandlers.dart';

class Routes {

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

  }
}