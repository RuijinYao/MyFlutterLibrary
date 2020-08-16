import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NavigationPageState();
  }
}

class NavigationPageState extends State<NavigationPage> {
  List<Widget> _pageList;
  final List<String> _appBarTitles = ['首页', '我的'];
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageList = [];
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Padding(
                  padding: const EdgeInsets.only(top: 1.5),
                  child: Text(_appBarTitles[0], key: Key(_appBarTitles[0])),
                )
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Padding(
                  padding: const EdgeInsets.only(top: 1.5),
                  child: Text(_appBarTitles[1], key: Key(_appBarTitles[1])),
                )
            )
          ],
          type: BottomNavigationBarType.fixed,
          elevation: 5.0,
          iconSize: 21.0,
          currentIndex: _currentIndex,
          selectedFontSize: 10.sp,
          unselectedFontSize: 10.sp,
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: (index) => _pageController.jumpToPage(index),
        ),
        body: PageView(
          //physics: const NeverScrollableScrollPhysics(), // 禁止滑动
          controller: _pageController,
          onPageChanged: (int index){
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pageList,
        ),
    );
  }
}
