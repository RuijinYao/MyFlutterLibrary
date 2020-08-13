import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
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
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                      return new Image.network(
                          "http://via.placeholder.com/288x188",
                          fit: BoxFit.fill,
                      );
                  },
                  itemCount: 10,
                  //当前页显示比例
                  viewportFraction: 0.8,
                  //左右两页的缩放
                  scale: 0.9,
                  autoplay: true,
                  autoplayDelay: 5000,
                  pagination: SwiperPagination(),
                  onTap: (int index){
                      print("当前点击图片的索引值为: $index");
                  },
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
