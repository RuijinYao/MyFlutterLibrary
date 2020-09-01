import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/StickHeadPage.dart';
import 'package:my_flutter_library/widget/ExpandableText.dart';

class DetailPage extends StatefulWidget {
  final String itemName;
  final int index;

  DetailPage(this.itemName, this.index);

  @override
  State<StatefulWidget> createState() {
    return DetailPageState();
  }
}

class DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController = ScrollController();

  Color tabBarColor = Colors.transparent;
  String tabBarTitle = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    //滚动监听, 当滚动距离大于330.h时,改变状态栏的颜色
    _scrollController.addListener(() {
      if (_scrollController.offset >= 330.h) {
        setState(() {
          tabBarColor = Color(0xff66B6EB);
          tabBarTitle = widget.itemName;
        });
      } else {
        setState(() {
          tabBarColor = Colors.transparent;
          tabBarTitle = "";
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff66B6EB),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              //是否固定AppBar
              pinned: true,
              //是否随着滑动隐藏标题
              floating: true,
              //配合floating使用
              snap: true,
              shadowColor: Colors.transparent,
              backgroundColor: tabBarColor,
              title: Text(tabBarTitle),
              actions: [
                IconButton(onPressed: null, icon: Icon(Icons.search, color: Colors.white)),
                IconButton(onPressed: null, icon: Icon(Icons.file_download, color: Colors.white)),
              ],
            ),
            SliverAppBar(
              expandedHeight: 330.h,
              leading: Container(),
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Hero(
                      tag: "${widget.itemName}${widget.index}",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image(width: 120.w, height: 120.w, image: AssetImage("assets/avatar.jpg")),
                      ),
                    ),
                    Text(
                      "${widget.itemName}",
                      style: TextStyle(color: Color(0xff66B6EB)),
                    ),
                  ],
                ),
                centerTitle: true,
                background: Image.asset(
                  'assets/zhihu.jpg',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: StickyTabBarDelegate(
                  child: PreferredSize(
                      preferredSize: Size.fromHeight(48),
                      child: Material(
                        //单独 设置 TabBar 的背景色
                        color: Color(0xff66B6EB),
                        child: TabBar(
                          indicatorColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.label,
                          controller: _tabController,
                          tabs: <Widget>[Tab(text: "详情"), Tab(text: "评论")],
                        ),
                      ))),
            )
          ];
        },
        body: TabBarView(controller: _tabController, children: <Widget>[
          Container(
              height: 400.h,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                          4,
                          (index) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Image.network(
                                  "http://via.placeholder.com/128x288",
                                  fit: BoxFit.fill,
                                ),
                              )),
                    ),
                  ),
                ],
              )),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
            child: ExpandableText(
              "         Semantics组件用于屏幕阅读器、搜索引擎、或者其他语义分析工具，比如视力有障碍的人士需要借助屏幕阅读器，屏幕阅读器可以对Semantics进行解析，比如语音。"
              "很多组件有semantics属性，都是此功能。Semantics提供了50多种属性，可以查看源代码进行查看。",
              expandText: "展开",
              collapseText: "收起",
              style: TextStyle(color: Colors.white, fontSize: 30.sp),
              maxLines: 3,
            ),
          ),
        ]),
      ),
    );
  }
}
