import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/login/SignInPage.dart';
import 'package:my_flutter_library/login/SignUpPage.dart';


///登录页面参考 https://juejin.im/post/6844903733730476039#heading-12
///主要使用 PageView 在注册与登录两个页面直接平滑切换
///Form 提交数据, TextFormField 验证数据数据正确性
class LoginPage extends StatefulWidget {
  @override
  createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  PageController _pageController;

  //使用 pageView 来动画切换注册与登陆界面
  PageView _pageView;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pageView = PageView(
      controller: _pageController,
      children: <Widget>[SignInPage(), SignUpPage()],
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
      //SingleChildScrollView 保证了键盘弹框出,即使是页面底部的输入框也不会被遮挡
      body: SingleChildScrollView(
        child: Container(
          //在Column 中用到Expand, 所以Container 必须要设置高度
          height: ScreenUtil.screenHeight,
          width: ScreenUtil.screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF2175E9), Color(0x7721B7E9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: Image(
                    width: 300.w, height: 190,
                    image: AssetImage("assets/login_logo.png")),
              ),
              //中间的Indicator指示器
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
                  width: 500.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Color(0x552B2B2B),
                  ),
                  child: Row(
                    children: <Widget>[
                      _indicatorItem(index: 0, indicatorName: "SignIn"),
                      _indicatorItem(index: 1, indicatorName: "SignUp")
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _pageView,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicatorItem({int index, String indicatorName}) {
    return Expanded(
      child: Container(
        decoration: _currentPage == index
            ? BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
                color: Colors.white,
              )
            : null,
        child: Center(
          child: FlatButton(
            onPressed: () {
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.decelerate);
            },
            child: Text(
              indicatorName,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
