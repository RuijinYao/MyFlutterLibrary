import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/widget/CustomCharPaint.dart';

class TestWidget extends StatefulWidget {
  final int value;
  final int count;
  final String itemName;
  final String myChosen;
  final bool animation;

  int animationDuration;
  double percent;

  TestWidget({@required this.value, @required this.count, @required this.itemName, this.animation : true, this.animationDuration : 1000, this.myChosen}) {
    percent = value / count;
  }

  @override
  State<StatefulWidget> createState() => TestWidgetState();
}

class TestWidgetState extends State<TestWidget> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  double _percent = 0.0;

  static ui.Image checkedImage;
  static Rect checkedImageRect;

  ImageListener _imageListener = (image, synchronousCall) {
    checkedImage = image.image;
    checkedImageRect = Rect.fromLTWH(0, 0, checkedImage.width.toDouble(), checkedImage.height.toDouble());
  };

  @override
  void initState() {
    if (widget.animation) {
      _animationController = new AnimationController(vsync: this, duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0.0, end: widget.percent).animate(_animationController)
        ..addListener(() {
          setState(() {
            _percent = _animation.value;
          });
        });
      _animationController.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(TestWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      if (_animationController != null) {
        _animationController.duration = Duration(milliseconds: widget.animationDuration);
        _animation = Tween(begin: oldWidget.percent, end: widget.percent).animate(_animationController);
        _animationController.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }

    AssetImage('assets/check.png').resolve(createLocalImageConfiguration(context)).addListener(ImageStreamListener(_imageListener));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 15.h),
        child: CustomPaint(
          size: Size(ScreenUtil.screenWidth, 80.h),
          painter: CustomChartPaint(
              data: widget.value,
              itemName: widget.itemName,
              myChosen: widget.myChosen,
              length: widget.count,
              targetPercent: _percent,
              checkedImage: checkedImage,
              checkedImageRect: checkedImageRect),
        ));
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    super.dispose();
  }
}
