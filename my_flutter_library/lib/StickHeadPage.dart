import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/widget/CommonWidget.dart';
import 'package:my_flutter_library/widget/MyTabBar.dart';

class StickHeadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StickHeadPageState();
  }
}

class StickHeadPageState extends State<StickHeadPage> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("吸顶TabBar"),
        ),
        body: CustomScrollView(slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: 400.h,
              child: Center(
                  child: Text("任意内容"),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(child: MyTabBar(List.castFrom(["待处理消息", "历史消息"]), _handler, primaryColor: Theme.of(context).primaryColor)),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              return CommonWidget.buildMsgItem("itemName", "ListView.separated 构造列表项的分割线, 分割线使用Divider", "2020-01-01", index);
            }, childCount: 20),
          ),
        ]));
  }

  void _handler(int index) {
    print("currentIndex: $index");
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final MyTabBar child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
