import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CombineAnimationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CombineAnimationPageState();
  }
}

class CombineAnimationPageState extends State<CombineAnimationPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  // 卡片列表
  final List<Widget> _cards = [];

  final List<String> _photos = ['assets/photo_1.png', 'assets/photo_2.png', 'assets/photo_3.png', 'assets/photo_4.png', 'assets/photo_5.png'];

  // 保存最前面卡片的定位
  Alignment _frontCardAlignment = Alignment(0.0, -0.5);

  // 保存最前面卡片的旋转角度
  double _frontCardRotation = 0.0;

  // 卡片横轴距离限制
  final double limit = 5.0;

  // 卡片回弹动画
  Animation<Alignment> _reboundAnimation;

  // 卡片回弹动画控制器
  AnimationController _reboundController;

  // 卡片位置变换动画控制器
  AnimationController _cardChangeController;

  //  前面的卡片，使用 Align 定位
  Widget _frontCard(BoxConstraints constraints) {
    // 判断是否还有卡片
    Widget card = _cards[0];

    // 判断动画是否在运行
    bool forward = _cardChangeController.status == AnimationStatus.forward;
    Widget rotate = Transform.rotate(
      angle: (pi / 180.0) * _frontCardRotation,
      // 使用 SizedBox 确定卡片尺寸
      child: SizedBox.fromSize(
        // 计算卡片尺寸，相对于父容器
        size: CardSizes.front(constraints),
        child: card,
      ),
    );

    // 在动画运行时使用动画值
    if (forward) {
      return Align(
        alignment: CardAnimations.frontCardDisappearAnimation(
          _cardChangeController,
          _frontCardAlignment,
        ).value,
        child: rotate,
      );
    }

    // 否则使用默认值
    return Align(
      alignment: _frontCardAlignment,
      child: rotate,
    );
  }

  // 中间的卡片，使用 Align 定位
  Widget _middleCard(BoxConstraints constraints) {
    // 判断是否还有两张卡片
    Widget card = _cards[1];
    // 判断动画是否在运行
    bool forward = _cardChangeController.status == AnimationStatus.forward;

    // 在动画运行时使用动画值
    if (forward) {
      return Align(
        alignment: CardAnimations.middleCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.middleCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: card,
        ),
      );
    }

    // 否则使用默认值
    return Align(
      alignment: CardAlignments.middle,
      child: SizedBox.fromSize(
        size: CardSizes.middle(constraints),
        child: card,
      ),
    );
  }

  // 后面的卡片，使用 Align 定位
  Widget _backCard(BoxConstraints constraints) {
    // 判断数组中是否还有三张卡片
    Widget card = _cards[2];
    // 判断动画是否在运行
    bool forward = _cardChangeController.status == AnimationStatus.forward;

    // 在动画运行时使用动画值
    if (forward) {
      return Align(
        alignment: CardAnimations.backCardAlignmentAnimation(
          _cardChangeController,
        ).value,
        child: SizedBox.fromSize(
          size: CardAnimations.backCardSizeAnimation(
            _cardChangeController,
            constraints,
          ).value,
          child: card,
        ),
      );
    }

    // 否则使用默认值
    return Align(
      alignment: CardAlignments.back,
      child: SizedBox.fromSize(
        size: CardSizes.back(constraints),
        child: card,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // 初始化回弹的动画控制器
    _reboundController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          // 动画运行时更新最前面卡片的 alignment 属性
          _frontCardAlignment = _reboundAnimation.value;
        });
      });

    // 初始化卡片换位动画控制器
    _cardChangeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 动画结束后将将第一位移到最后一位, 以实现循环播放
          _cards.add(_cards.removeAt(0));

          // 动画运行结束后重置位置和旋转
          _frontCardRotation = 0.0;
          _frontCardAlignment = CardAlignments.front;
          setState(() {});
        }
      });

    _cards.addAll(List.generate(
        5,
        (index) => Card(
              color: Colors.white,
              child: Image.asset(_photos[index])
            )));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("组合动画"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 使用 LayoutBuilder 获取容器的尺寸，传个子项计算卡片尺寸
          Size size = MediaQuery.of(context).size;
          double speed = 10.0;

          return Stack(
            children: <Widget>[
              _cards.length > 2 ? _backCard(constraints) : Container(),
              _cards.length > 1 ? _middleCard(constraints) : Container(),
              _cards.length > 0 ? _frontCard(constraints) : _emptyView(),

              // 使用一个占满父元素的 GestureDetector 监听手指移动
              // 如果动画在运行中就不在响应手势
              // 设备数大于1才响应手势
              _cardChangeController.status != AnimationStatus.forward && _cards.length > 1
                  ? SizedBox.expand(
                      child: GestureDetector(
                        onPanDown: (DragDownDetails details) {},
                        onPanUpdate: (DragUpdateDetails details) {
                          // 手指移动就更新最前面卡片的 alignment 属性
                          _frontCardAlignment += Alignment(
                            details.delta.dx / (size.width / 2) * speed,
                            details.delta.dy / (size.height / 2) * speed,
                          );
                          // 设置最前面卡片的旋转角度
                          _frontCardRotation = _frontCardAlignment.x;
                          // setState 更新界面
                          setState(() {});
                        },
                        onPanEnd: (DragEndDetails details) {
                          // 如果最前面的卡片横轴移动距离超过限制就运行换位动画，否则运行回弹动画
                          if (_frontCardAlignment.x > limit || _frontCardAlignment.x < -limit) {
                            _runChangeOrderAnimation();
                          } else {
                            _runReboundAnimation(
                              details.velocity.pixelsPerSecond,
                              size,
                            );
                          }
                        },
                      ),
                    )
                  : IgnorePointer(),
            ],
          );
        },
      ),
    );
  }

  //列表为空显示空提醒
  Widget _emptyView() {
    return Center(
      child: Text(
        "暂无设备\n请联系工作人员上门绑定设备",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 40.sp),
      ),
    );
  }

  // 改变位置的动画
  void _runChangeOrderAnimation() {
    _cardChangeController.reset();
    _cardChangeController.forward();
  }

  // 卡片回弹的动画
  void _runReboundAnimation(Offset pixelsPerSecond, Size size) {
    // 创建动画值
    _reboundAnimation = _reboundController.drive(
      AlignmentTween(
        // 起始值是卡片当前位置，最终值是卡片的默认位置
        begin: _frontCardAlignment,
        end: Alignment(0.0, -0.5),
      ),
    );
    // 计算卡片运动速度
    final double unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final double unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;
    // 创建弹簧模拟的定义
    const spring = SpringDescription(mass: 30, stiffness: 1, damping: 1);
    // 创建弹簧模拟
    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
    // 根据给定的模拟运行动画
    _reboundController.animateWith(simulation);
    // 重置旋转值
    _frontCardRotation = 0.0;
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}

/// 卡片尺寸
class CardSizes {
  static Size front(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.95, constraints.maxHeight * 0.85);
  }

  static Size middle(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.9, constraints.maxHeight * 0.85);
  }

  static Size back(BoxConstraints constraints) {
    return Size(constraints.maxWidth * 0.85, constraints.maxHeight * 0.85);
  }
}

/// 卡片位置
class CardAlignments {
  static Alignment front = Alignment(0.0, -0.5);
  static Alignment middle = Alignment(0.0, 0.0);
  static Alignment back = Alignment(0.0, 0.5);
}

/// 卡片运动动画
class CardAnimations {
  /// 最前面卡片的消失动画值
  static Animation<Alignment> frontCardDisappearAnimation(
    AnimationController parent,
    Alignment beginAlignment,
  ) {
    return AlignmentTween(
      begin: beginAlignment,
      end: Alignment(
        beginAlignment.x > 0 ? beginAlignment.x + 40.0 : beginAlignment.x - 40.0,
        0.0,
      ),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// 中间卡片位置变换动画值
  static Animation<Alignment> middleCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.middle,
      end: CardAlignments.front,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// 中间卡片尺寸变换动画值
  static Animation<Size> middleCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.middle(constraints),
      end: CardSizes.front(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  /// 最后面卡片位置变换动画值
  static Animation<Alignment> backCardAlignmentAnimation(
    AnimationController parent,
  ) {
    return AlignmentTween(
      begin: CardAlignments.back,
      end: CardAlignments.middle,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  /// 最后面卡片尺寸变换动画值
  static Animation<Size> backCardSizeAnimation(
    AnimationController parent,
    BoxConstraints constraints,
  ) {
    return SizeTween(
      begin: CardSizes.back(constraints),
      end: CardSizes.middle(constraints),
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }
}
