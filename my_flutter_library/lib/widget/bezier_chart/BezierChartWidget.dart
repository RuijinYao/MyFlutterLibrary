import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart' as intl;
import 'package:my_flutter_library/widget/bezier_chart/BezierChartConfig.dart';
import 'package:my_flutter_library/widget/bezier_chart/BezierLine.dart';
import 'package:my_flutter_library/widget/bezier_chart/MySingleChildScrollView.dart';

typedef FooterValueBuilder = String Function(double value);
typedef FooterDateTimeBuilder = String Function(
    DateTime value, BezierChartScale scaleType);

class BezierChart extends StatefulWidget {
  ///Chart configuration
  final BezierChartConfig config;

  ///Type of Chart
  final BezierChartScale bezierChartScale;

  ///Aggregation of Chart
  final BezierChartAggregation bezierChartAggregation;

  ///[Optional] This callback only works if the `BezierChartScale` is `BezierChartScale.CUSTOM` otherwise it will be ignored
  ///This is used to display a custom footer value based on the current 'x' value
  final FooterValueBuilder footerValueBuilder;

  ///[Optional] This callback only works if the `BezierChartScale` is Date type otherwise it will be ignored
  ///This is used to display a custom footer value based on the current 'x' value
  final FooterDateTimeBuilder footerDateTimeBuilder;

  ///[Optional] This callback only works if the `BezierChartScale` is Date type otherwise it will be ignored
  ///This is used to display a custom bubble label value based on the current 'x' value
  final FooterDateTimeBuilder bubbleLabelDateTimeBuilder;

  ///[Optional] This callback notify when the display indicator is visible or not
  final ValueChanged<bool> onIndicatorVisible;

  ///[Optional] This callback will display the current `DateTime` selected by the indicator
  ///Only works when the `BezierChartScale` is date type
  final ValueChanged<DateTime> onDateTimeSelected;

  ///This value represents the date selected to display the info in the Chart
  ///For `BezierChartScale.HOURLY` it will use year, month, day and hour
  ///For `BezierChartScale.WEEKLY` it will use year, month and day
  ///For `BezierChartScale.MONTHLY` it will use year, month
  ///For `BezierChartScale.YEARLY` it will use year
  final DateTime selectedDate;

  ///This value represents the value selected to display the info in the Chart
  ///It's only for `BezierChartScale.CUSTOM`
  final double selectedValue;

  ///Beziers used in the Axis Y
  final BezierLine bezierLine;

  ///Notify if the `BezierChartScale` changed, it only works with date scales.
  final ValueChanged<BezierChartScale> onScaleChanged;

  BezierChart({
    Key key,
    this.config,
    this.footerValueBuilder,
    this.footerDateTimeBuilder,
    this.bubbleLabelDateTimeBuilder,
    this.selectedDate,
    this.onIndicatorVisible,
    this.onDateTimeSelected,
    this.selectedValue,
    this.bezierChartAggregation = BezierChartAggregation.SUM,
    @required this.bezierChartScale,
    @required this.bezierLine,
    this.onScaleChanged,
  }) : super(key: key);

  @override
  BezierChartState createState() => BezierChartState();
}

@visibleForTesting
class BezierChartState extends State<BezierChart>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  ScrollController _scrollController;
  GlobalKey _keyScroll = GlobalKey();

  ///Track the current position when dragging the indicator
  Offset _verticalIndicatorPosition;
  bool _displayIndicator = false;

  ///padding for leading and trailing of the chart
  final double horizontalPadding = 50.0;

  ///spacing between each datapoint
  double horizontalSpacing = 60.0;

  ///List of `DataPoint`s used to display all the values for the `X` axis
  List<DataPoint> _xAxisDataPoints = [];

  ///List of `BezierLine`s used to display all lines, each line contains a list of `DataPoint`s
  BezierLine bezierLine;

  ///Current scale when use pinch/zoom
  double _currentScale = 1.0;

  ///This value allow us to get the last scale used when start the pinch/zoom again
  double _previousScale;

  ///The current chart scale
  BezierChartScale _currentBezierChartScale;

  double _lastValueSnapped = double.infinity;

  bool get isPinchZoomActive => (_touchFingers > 1 && widget.config.pinchZoom);

  ///When we only have 1 axis we don't need to much span to change the date type chart`
  bool get isOnlyOneAxis => _xAxisDataPoints.length <= 1;

  double _contentWidth = 0.0;
  bool _isScrollable = false;

  ///Calculate all of the values related to the Y axis
  List<double> _yValues;

  ///Values from valueBuilder
  List<double> _tempYValues;

  DateTime _dateTimeSelected;
  GlobalKey _keyLastYAxisItem = GlobalKey();
  double _yAxisWidth = 0.0;

  ///Refresh the position of the vertical/bubble
  void _refreshPosition(details) {
    if (_animationController.status == AnimationStatus.completed &&
        _displayIndicator) {
      return _updatePosition(details.globalPosition);
    }
  }

  ///Update and refresh the position based on the current screen
  void _updatePosition(Offset globalPosition) {
    RenderBox renderBox = context.findRenderObject();
    final position = renderBox.globalToLocal(globalPosition);
    if (position == null) return;
    return setState(
      () {
        //将点击的屏幕位置换算成自定义视图中的坐标值

        //_scrollController.offset  可滚动小部件的当前滚动偏移量
        //当数据量较少时, 表宽度没有铺满整个屏幕, 表会居中显示

        Offset fixedPosition;
        double screenWidth = MediaQuery.of(context).size.width;
        if(_contentWidth < screenWidth){
            fixedPosition = Offset(
                position.dx - (screenWidth - _contentWidth) / 2,
                position.dy
            );
        } else {
            fixedPosition = Offset(
                position.dx + _scrollController.offset - horizontalPadding,
                position.dy);
        }

        _verticalIndicatorPosition = fixedPosition;
      },
    );
  }

  ///After long press this method is called to display the bubble indicator if is not visible
  ///An animation and snap sound are triggered
  void _onDisplayIndicator(details, {bool updatePosition = true}) {
    if (!_displayIndicator) {
      _displayIndicator = true;
      _animationController.forward(
        from: 0.0,
      );
      if (widget.onIndicatorVisible != null) {
        widget.onIndicatorVisible(true);
      }
    }
    _onDataPointSnap(double.maxFinite);
    if (updatePosition) _updatePosition(details.globalPosition);
  }

  ///Hide the vertical/bubble indicator and refresh the user.widget
  void _onHideIndicator() {
    if (_displayIndicator) {
      if (widget.onIndicatorVisible != null) {
        widget.onIndicatorVisible(false);
      }
      _animationController.reverse(from: 1.0).whenCompleteOrCancel(
        () {
          setState(
            () {
              _displayIndicator = false;
            },
          );
        },
      );
    }
  }

  ///When the current indicator reach any data point a feedback is triggered
  void _onDataPointSnap(double value) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (_lastValueSnapped != value && widget.config.snap) {
      if (isIOS) {
        HapticFeedback.heavyImpact();
      } else {
        Feedback.forTap(context);
      }
      _lastValueSnapped = value;
    }
  }

  ///Building the data points for the `X` axis based on the `_currentBezierChartScale`
  void _buildXDataPoints() {
    _xAxisDataPoints = [];
    _tempYValues = [];
    final scale = _currentBezierChartScale;

    DateTime date;
    for (int i = 0; i < widget.bezierLine.data.length; i++) {
      if(scale == BezierChartScale.MONTHLY){
        date = _convertToMonthOnly(widget.bezierLine.data[i].xAxis);
      } else if(scale == BezierChartScale.YEARLY){
        date = _convertToYearOnly(widget.bezierLine.data[i].xAxis);
      } else {
        date = widget.bezierLine.data[i].xAxis;
      }

      _xAxisDataPoints.add(DataPoint(value: (i * 5).toDouble(), xAxis: date));
    }
  }

  DateTime _convertToYearOnly(DateTime date){
    int year = date.year;
    return DateTime(year);
  }

  DateTime _convertToMonthOnly(DateTime date){
    int year = date.year;
    int month = date.month;
    return DateTime(year, month);
  }

  ///Calculating the size of the content based on the parent constraints and on the `_currentBezierChartScale`
  double _buildContentWidth(BoxConstraints constraints) {
    final scale = _currentBezierChartScale;

    if (scale == BezierChartScale.WEEKLY) {
      horizontalSpacing = constraints.maxWidth / 7;
      return _xAxisDataPoints.length * (horizontalSpacing * _currentScale) -
          horizontalPadding / 2;
    } else if (scale == BezierChartScale.MONTHLY) {
      horizontalSpacing = constraints.maxWidth / 7;
      return _xAxisDataPoints.length * (horizontalSpacing * _currentScale) -
          horizontalPadding / 2;
    } else if (scale == BezierChartScale.YEARLY) {
      if (_xAxisDataPoints.length > 12) {
        horizontalSpacing = constraints.maxWidth / 12;
      } else if (_xAxisDataPoints.length < 6) {
        horizontalSpacing = constraints.maxWidth / 6;
      } else {
        horizontalSpacing = constraints.maxWidth / _xAxisDataPoints.length;
      }
      return _xAxisDataPoints.length * (horizontalSpacing * _currentScale) -
          horizontalPadding;
    }
    return 0.0;
  }

  ///When the user.widget finish rendering for the first time
  _onLayoutDone(_) {
    _yAxisWidth = _keyLastYAxisItem.currentContext?.size?.width;
    //Move to selected position
    if (widget.selectedDate != null) {
      int index = -1;
      if (_currentBezierChartScale == BezierChartScale.WEEKLY) {
        index = _xAxisDataPoints
            .indexWhere((dp) => areEqualDates((dp.xAxis), widget.selectedDate));
      } else if (_currentBezierChartScale == BezierChartScale.MONTHLY) {
        index = _xAxisDataPoints.indexWhere((dp) =>
            (dp.xAxis).year == widget.selectedDate.year &&
            (dp.xAxis).month == widget.selectedDate.month);
      } else if (_currentBezierChartScale == BezierChartScale.YEARLY) {
        index = _xAxisDataPoints
            .indexWhere((dp) => (dp.xAxis).year == widget.selectedDate.year);
      }

      //If it's a valid index then scroll to the date selected based on the current position
      if (index >= 0) {
        Offset fixedPosition;

        final jumpToX = (index * horizontalSpacing) -
            horizontalPadding / 2 -
            _keyScroll.currentContext.size.width / 2;
        _scrollController.jumpTo(jumpToX);

        fixedPosition = Offset(
            isOnlyOneAxis
                ? 0.0
                : (index * horizontalSpacing + 2 * horizontalPadding) -
                    _scrollController.offset,
            0.0);
        _verticalIndicatorPosition = fixedPosition;
        _onDisplayIndicator(
          LongPressMoveUpdateDetails(
            globalPosition: fixedPosition,
            offsetFromOrigin: fixedPosition,
          ),
        );
      }
    }
    _checkIfNeedScroll();
    if (_isScrollable) {
      setState(() {});
    }
  }

  _checkIfNeedScroll() {
    //print("_contentWidth: $_contentWidth, _keyScroll.currentContext.size.width: ${_keyScroll.currentContext.size.width}");
    if (_contentWidth > MediaQuery.of(context).size.width) {
      _isScrollable = true;
    }
  }

  ///Calculating the new series based on the `_currentBezierChartScale`
  _computeSeries() {
    _yValues = [];
    //fill data series for DateTime scale type

    BezierLine line = widget.bezierLine;
    Map<String, List<double>> tmpMap = Map();
    for (DataPoint dataPoint in line.data) {
      String key;
      if (_currentBezierChartScale == BezierChartScale.MONTHLY) {
        key =
            "${dataPoint.xAxis.year},${dataPoint.xAxis.month.toString().padLeft(2, '0')}";
      } else if (_currentBezierChartScale == BezierChartScale.YEARLY) {
        key = "${dataPoint.xAxis.year}";
      } else if (_currentBezierChartScale == BezierChartScale.WEEKLY) {
        key =
            "${dataPoint.xAxis.year},${dataPoint.xAxis.month.toString().padLeft(2, '0')},${dataPoint.xAxis.day.toString().padLeft(2, '0')}";
      } else {
        key =
            "${dataPoint.xAxis.year},${dataPoint.xAxis.month.toString().padLeft(2, '0')},${dataPoint.xAxis.day.toString().padLeft(2, '0')},${dataPoint.xAxis.hour.toString().padLeft(2, '0')}";
      }

      //support aggregations for y axis
      if (!tmpMap.containsKey(key)) {
        tmpMap[key] = new List<double>();
      }
      tmpMap[key].add(dataPoint.value);
    }

    Map<String, double> valueMap = Map();
    if (widget.bezierChartAggregation == BezierChartAggregation.SUM) {
      valueMap = tmpMap.map((k, v) => MapEntry(
          k, v.reduce((c1, c2) => double.parse((c1 + c2).toStringAsFixed(2)))));
    } else if (widget.bezierChartAggregation == BezierChartAggregation.FIRST) {
      valueMap = tmpMap.map((k, v) => MapEntry(k, v.reduce((c1, c2) => c1)));
    } else if (widget.bezierChartAggregation ==
        BezierChartAggregation.AVERAGE) {
      valueMap = tmpMap
          .map((k, v) => MapEntry(k, v.reduce((c1, c2) => c1 + c2) / v.length));
    } else if (widget.bezierChartAggregation == BezierChartAggregation.COUNT) {
      valueMap = tmpMap.map((k, v) => MapEntry(k, v.length.toDouble()));
    } else if (widget.bezierChartAggregation == BezierChartAggregation.MAX) {
      valueMap = tmpMap
          .map((k, v) => MapEntry(k, v.reduce((c1, c2) => c1 > c2 ? c1 : c2)));
    } else if (widget.bezierChartAggregation == BezierChartAggregation.MIN) {
      valueMap = tmpMap
          .map((k, v) => MapEntry(k, v.reduce((c1, c2) => c1 < c2 ? c1 : c2)));
    }

    List<DataPoint> newDataPoints = [];
    valueMap.keys.forEach(
      (key) {
        final value = valueMap[key];
        if (!_yValues.contains(value)) {
          _yValues.add(value);

          ///Sum all the values corresponding to each month and create a new data serie
        }

        if (_currentBezierChartScale == BezierChartScale.MONTHLY) {
          List<String> split = key.split(",");
          int year = int.parse(split[0]);
          int month = int.parse(split[1]);
          final date = DateTime(year, month);
          newDataPoints.add(
            DataPoint(
              value: value,
              xAxis: date,
            ),
          );
        } else if (_currentBezierChartScale == BezierChartScale.WEEKLY) {
          List<String> split = key.split(",");
          int year = int.parse(split[0]);
          int month = int.parse(split[1]);
          int day = int.parse(split[2]);
          final date = DateTime(year, month, day, 0);
          newDataPoints.add(
            DataPoint(
              value: value,
              xAxis: date,
            ),
          );
        } else {
          ///Sum all the values corresponding to each year and create a new data serie
          int year = int.parse(key);
          final date = DateTime(year);
          newDataPoints.add(
            DataPoint(
              value: value,
              xAxis: date,
            ),
          );
        }
      },
    );

    bezierLine = BezierLine.copy(
      bezierLine: BezierLine(
        lineColor: line.lineColor,
        fillColor: line.fillColor,
        label: line.label,
        lineStrokeWidth: line.lineStrokeWidth,
        dataPointFillColor: line.dataPointFillColor,
        dataPointStrokeColor: line.dataPointStrokeColor,
        data: newDataPoints,
      ),
    );

    for (double temp in _tempYValues) {
      if (!_yValues.contains(temp)) _yValues.add(temp);
    }
    //sort yValues
    _yValues.sort((val1, val2) => (val1 > val2) ? 1 : -1);
  }

  ///Pinch and zoom based on the scale reported by the gesture detector
  _onPinchZoom(double scale) {
    scale = double.parse(scale.toStringAsFixed(1));
    if (isPinchZoomActive) {
      BezierChartScale lastScale = BezierChartScale.WEEKLY;
      if (_currentBezierChartScale == BezierChartScale.MONTHLY) {
        lastScale = BezierChartScale.MONTHLY;
      } else if (_currentBezierChartScale == BezierChartScale.YEARLY) {
        lastScale = BezierChartScale.YEARLY;
      }

      //when the scale is below 1 then we'll try to change the chart scale depending of the `_currentBezierChartScale`
      if (scale < 1) {
        if (_currentBezierChartScale == BezierChartScale.WEEKLY) {
          _currentBezierChartScale = BezierChartScale.MONTHLY;
          _previousScale = 1.5;
        } else if (_currentBezierChartScale == BezierChartScale.MONTHLY) {
          _currentBezierChartScale = BezierChartScale.YEARLY;
        }
        _currentScale = 1.0;
        setState(
          () {
            _buildXDataPoints();
            _computeSeries();
            _checkIfNeedScroll();
          },
        );
        _notifyScaleChanged(lastScale);
        return;
        //if the scale is greater than 1.5 then we'll try to change the chart scale depending of the `_currentBezierChartScale`
      } else if (scale > 1.5 || (isOnlyOneAxis && scale > 1.2)) {
        if (_currentBezierChartScale == BezierChartScale.YEARLY) {
          _currentBezierChartScale = BezierChartScale.MONTHLY;
          _currentScale = 1.0;
          _previousScale = 1.0 / scale;
          setState(
            () {
              _buildXDataPoints();
              _computeSeries();
              _checkIfNeedScroll();
            },
          );
          _notifyScaleChanged(lastScale);
        } else if (_currentBezierChartScale == BezierChartScale.MONTHLY) {
          _currentBezierChartScale = BezierChartScale.WEEKLY;
          _currentScale = 1.0;
          _previousScale = 1.0 / scale;
          setState(
            () {
              _buildXDataPoints();
              _computeSeries();
              _checkIfNeedScroll();
            },
          );
          _notifyScaleChanged(lastScale);
          return;
        }
      } else {
        if (scale > 2.5) scale = 2.5;
        if (scale != _currentScale) {
          setState(
            () {
              _currentScale = scale;
            },
          );
        }
      }
    }
  }

  void _notifyScaleChanged(BezierChartScale lastScale) {
    if (widget.onScaleChanged != null &&
        lastScale != _currentBezierChartScale) {
      widget.onScaleChanged(_currentBezierChartScale);
    }
  }

  bool areSeriesDifferent = false;

  @override
  void didUpdateWidget(BezierChart oldWidget) {
    /// Rebuild data points and series in case:
    /// 1. if the BezierChartScale is different from the old one
    /// 2. if the series are different
    /// 3. if either fromDate or toDate are different
    areSeriesDifferent = false;

    final size1 = oldWidget.bezierLine;
    final size2 = widget.bezierLine;
    if (size1.data.length != size2.data.length) {
      areSeriesDifferent = true;
    }

    if (!areSeriesDifferent) {
      final line1 = oldWidget.bezierLine;
      final line2 = widget.bezierLine;
      if (line1 != line2) {
        areSeriesDifferent = true;
      }
    }

    if (oldWidget.bezierChartScale != widget.bezierChartScale ||
        areSeriesDifferent) {
      _currentBezierChartScale = widget.bezierChartScale;
      _buildXDataPoints();
      _computeSeries();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _currentBezierChartScale = widget.bezierChartScale;
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _buildXDataPoints();
    _computeSeries();
    WidgetsBinding.instance.addPostFrameCallback(_onLayoutDone);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _touchFingers = 0;

  @override
  Widget build(BuildContext context) {
    //using `Listener` to fix the issue with single touch for multitouch gesture like pinch/zoom
    //https://github.com/flutter/flutter/issues/13102
    return Container(
      decoration: BoxDecoration(
        color: widget.config.backgroundGradient != null
            ? null
            : widget.config.backgroundColor,
        gradient: widget.config.backgroundGradient,
      ),
      alignment: Alignment.center,
      child: Listener(
        onPointerDown: (_) {
          _touchFingers++;
          if (_touchFingers > 1) {
            setState(() {});
          }
        },
        onPointerUp: (_) {
          _touchFingers--;
          if (_touchFingers < 2) {
            setState(() {});
          }
        },
        child: GestureDetector(
          onTapDown: widget.config.updatePositionOnTap
              ? null
              : (isPinchZoomActive ? null : _onDisplayIndicator),
          onLongPressMoveUpdate: isPinchZoomActive ? null : _refreshPosition,
          onScaleStart: (_) {
            _previousScale = _currentScale;
          },
          onScaleUpdate: !_displayIndicator
              ? (details) => _onPinchZoom(_previousScale * details.scale)
              : null,
          /*onTap: user.widget.config.updatePositionOnTap
              ? null
              : (isPinchZoomActive ? null : _onHideIndicator),*/
          /*onTapDown: user.widget.config.updatePositionOnTap
              ? (isPinchZoomActive ? null : _refreshPosition)
              : null,*/
          child: LayoutBuilder(
            builder: (context, constraints) {
              _contentWidth = _buildContentWidth(constraints);

              //动态设置数据后,重新判断是否需要滚动屏幕
              _checkIfNeedScroll();
              final items = <Widget>[];
              final maxHeight = constraints.biggest.height * 0.75;
              items.add(
                MySingleChildScrollView(
                  controller: _scrollController,
                  physics: isPinchZoomActive || !_isScrollable
                      ? NeverScrollableScrollPhysics()
                      : widget.config.physics,
                  key: _keyScroll,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Align(
                    alignment: Alignment(0.0, 0.7),
                    child: CustomPaint(
                      size: Size(
                        _contentWidth,
                        maxHeight,
                      ),
                      painter: _BezierChartPainter(
                        shouldRepaintChart: areSeriesDifferent,
                        config: widget.config,
                        maxYValue: _yValues.last,
                        minYValue: _yValues.first,
                        bezierChartScale: _currentBezierChartScale,
                        verticalIndicatorPosition: _verticalIndicatorPosition,
                        bezierLine: bezierLine,
                        showIndicator: _displayIndicator,
                        animation: CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.0,
                            1.0,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        xAxisDataPoints: _xAxisDataPoints,
                        onDataPointSnap: _onDataPointSnap,
                        maxWidth: MediaQuery.of(context).size.width,
                        scrollOffset: _scrollController.hasClients
                            ? _scrollController.offset
                            : 0.0,
                        footerDateTimeBuilder: widget.footerDateTimeBuilder,
                        bubbleLabelDateTimeBuilder:
                            widget.bubbleLabelDateTimeBuilder,
                        onDateTimeSelected: (val) {
                          if (widget.onDateTimeSelected != null) {
                            if (_dateTimeSelected == null) {
                              _dateTimeSelected = val;
                              widget.onDateTimeSelected(_dateTimeSelected);
                            } else {
                              if (_dateTimeSelected != val) {
                                _dateTimeSelected = val;
                                widget.onDateTimeSelected(_dateTimeSelected);
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
              );
              if (widget.config.displayYAxis) {
                if (_yValues != null && _yValues.isNotEmpty) {
                  //add a background container for the Y Axis
                  items.add(Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: _yAxisWidth + 10,
                      decoration: widget.config.backgroundGradient != null
                          ? BoxDecoration(
                              gradient: widget.config.backgroundGradient)
                          : null,
                      color: widget.config.backgroundGradient != null
                          ? null
                          : widget.config.backgroundColor,
                    ),
                  ));
                }

                final fontSize = widget.config.yAxisTextStyle?.fontSize ?? 28.0;
                final maxValue = _yValues.last;

                _addYItem(double value, {Key key}) {
                  items.add(
                    Positioned(
                        bottom: _getRealValue(
                                value,
                                maxHeight - widget.config.footerHeight,
                                maxValue) +
                            widget.config.footerHeight +
                            ScreenUtil().setHeight(25),
                        left: 15.0,
                        child: Container(
                          height: ScreenUtil().setHeight(25),
                          child: Center(
                            child: Text(
                              formatAsIntOrDouble(value),
                              key: key,
                              style: widget.config.yAxisTextStyle ??
                                  TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(fontSize)),
                            ),
                          ),
                        )),
                  );
                }

                final max = _yValues.last;

                int steps = (max / widget.config.yLineNum).ceil();

                for (int i = 0; i < max + steps; i++) {
                  if (i % steps == 0) {
                    bool isLast =
                        (i + steps) > max && (i + steps) >= (max + steps);
                    _addYItem(i.toDouble(),
                        key: isLast ? _keyLastYAxisItem : null);
                  }
                }
              }
              return Stack(
                children: items,
              );
            },
          ),
        ),
      ),
    );
  }
}

///return the real value of canvas
_getRealValue(double value, double maxConstraint, double maxValue) =>
    maxConstraint * value / (maxValue == 0 ? 1 : maxValue);

//BezierChart
class _BezierChartPainter extends CustomPainter {
  final BezierChartConfig config;
  final Offset verticalIndicatorPosition;
  final BezierLine bezierLine;
  final List<DataPoint> xAxisDataPoints;
  double _maxValueY = 0.0;
  double _maxValueX = 0.0;
  List<_CustomValue> _currentCustomValues = [];
  DataPoint _currentXDataPoint;
  final double radiusDotIndicatorMain = 7;
  final double radiusDotIndicatorItems = 3.5;
  final bool showIndicator;
  final Animation animation;
  final ValueChanged<double> onDataPointSnap;
  final BezierChartScale bezierChartScale;
  final double maxWidth;
  final double scrollOffset;
  bool footerDrawed = false;
  final FooterDateTimeBuilder footerDateTimeBuilder;
  final FooterDateTimeBuilder bubbleLabelDateTimeBuilder;
  final double maxYValue;
  final double minYValue;
  final ValueChanged<DateTime> onDateTimeSelected;
  final bool shouldRepaintChart;

  _BezierChartPainter({
    this.shouldRepaintChart,
    this.config,
    this.verticalIndicatorPosition,
    this.bezierLine,
    this.showIndicator,
    this.xAxisDataPoints,
    this.animation,
    this.bezierChartScale,
    this.onDataPointSnap,
    this.maxWidth,
    this.scrollOffset,
    this.footerDateTimeBuilder,
    this.bubbleLabelDateTimeBuilder,
    this.maxYValue,
    this.minYValue,
    this.onDateTimeSelected,
  }) : super(repaint: animation) {
    _maxValueY = _getMaxValueY();
    _maxValueX = _getMaxValueX();
  }

  ///return the max value of the Axis X
  double _getMaxValueX() {
    double x = double.negativeInfinity;
    for (DataPoint dp in xAxisDataPoints) {
      if (dp.value > x) x = dp.value;
    }
    return x;
  }

  ///return the max value of the Axis Y
  double _getMaxValueY() {
    if (maxYValue == 0.0) return 1.0;
    return maxYValue;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height - config.footerHeight;
    Paint paintVerticalIndicator = Paint();
    try {
      paintVerticalIndicator
        ..color = config.verticalIndicatorColor
        ..strokeWidth = config.verticalIndicatorStrokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square;
    } catch (ex) {
      print("err: $ex");
    }

    Paint paintControlPoints = Paint()..strokeCap = StrokeCap.round;

    Paint yAxisLinePaint = Paint()..color = config.yLineColor;

    double verticalX = 0.0;
    //fixing verticalIndicator outbounds
    if (verticalIndicatorPosition != null) {
      verticalX = verticalIndicatorPosition.dx;
      if (verticalIndicatorPosition.dx < 0) {
        verticalX = 0.0;
      } else if (verticalIndicatorPosition.dx > size.width) {
        verticalX = size.width;
      }
    }

    //variables for the last item on the list (this is required to display the indicator)
    Offset p0, p1, p2, p3;
    void _drawBezierLinePath(BezierLine line) {
      Path path = Path();
      Path fillPath = Path();
      List<Offset> dataPoints = [];

      TextPainter textPainterXAxis = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      TextStyle xAxisTextStyle = config.xAxisTextStyle ??
          TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 11,
          );

      Paint paintFillPath = Paint()
        ..color = line.fillColor
        ..strokeWidth = line.lineStrokeWidth
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round;

      Paint paintLine = Paint()
        ..color = line.lineColor
        ..strokeWidth = line.lineStrokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Paint paintXLines = Paint()
        ..color = config.xLinesColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      _AxisValue lastPoint;

      fillPath.moveTo(0, height);
      //display each data point
      for (int i = 0; i < xAxisDataPoints.length; i++) {
        double value = 0.0;

        double axisX = xAxisDataPoints[i].value;

        final double valueX = _getRealValue(
          axisX,
          size.width,
          _maxValueX,
        );

        //Only calculate and display the necessary data to improve the performance of the scrolling
        final range = maxWidth * 10;
        if (scrollOffset - range >= valueX || scrollOffset + range <= valueX) {
          continue;
        }

        //search from axis
        for (DataPoint dp in line.data) {
          final dateTime = (xAxisDataPoints[i].xAxis);

          if (areEqualDates(dateTime, dp.xAxis)) {
            value = dp.value;
            axisX = xAxisDataPoints[i].value;
            break;
          }
        }

        final double axisY = value;
        final double valueY = height -
            _getRealValue(
              axisY,
              height,
              _maxValueY,
            );

        if (config.displayLinesXAxis) {
          canvas.drawLine(
              Offset(valueX, height), Offset(valueX, valueY), paintXLines);
        }

        //将画笔移到第一个点开始的地方
        if (lastPoint == null) {
          lastPoint = _AxisValue(x: valueX, y: valueY);
          path.moveTo(valueX, valueY);
        }

        //两坐标点之间的位置
        final double controlPointX = lastPoint.x + (valueX - lastPoint.x) / 2;
        path.cubicTo(
            controlPointX, lastPoint.y, controlPointX, valueY, valueX, valueY);
        fillPath.cubicTo(
            controlPointX, lastPoint.y, controlPointX, valueY, valueX, valueY);

        dataPoints.add(Offset(valueX, valueY));

        //点击位置在两个坐标之间
        if (verticalIndicatorPosition != null &&
            verticalX >= lastPoint.x &&
            verticalX <= valueX) {
          //points to draw the info
          p0 = Offset(lastPoint.x, height - lastPoint.y);
          p1 = Offset(controlPointX, height - lastPoint.y);
          p2 = Offset(controlPointX, height - valueY);
          p3 = Offset(valueX, height - valueY);
        }

        if (verticalIndicatorPosition != null) {
          //get current information
          double nextX = double.infinity;
          double lastX = double.negativeInfinity;
          if (xAxisDataPoints.length > (i + 1)) {
            nextX = _getRealValue(
              xAxisDataPoints[i + 1].value,
              size.width,
              _maxValueX,
            );
          }
          if (i > 0) {
            lastX = _getRealValue(
              xAxisDataPoints[i - 1].value,
              size.width,
              _maxValueX,
            );
          }

          //if vertical indicator is in range then display the bubble info
          //当前点击位置在坐标点左右两侧, 不超过半个间距,就显示提示
          if (verticalX >= valueX - (valueX - lastX) / 2 &&
              verticalX <= valueX + (nextX - valueX) / 2) {
            _currentXDataPoint = xAxisDataPoints[i];
            if (_currentCustomValues.length < 1) {
              if (onDateTimeSelected != null) {
                onDateTimeSelected(xAxisDataPoints[i].xAxis);
              }

              onDataPointSnap(xAxisDataPoints[i].value);
              _currentCustomValues.add(
                _CustomValue(
                  value: "${formatAsIntOrDouble(axisY)}",
                  label: line.label,
                  color: line.dataPointFillColor,
                ),
              );
            }
          }
        }

        lastPoint = _AxisValue(x: valueX, y: valueY);

        if (i == xAxisDataPoints.length - 1) {
          fillPath.lineTo(size.width, height);
        }

        //draw footer
        textPainterXAxis.text = TextSpan(
          text: _getFooterText(xAxisDataPoints[i]),
          style: xAxisTextStyle,
        );
        textPainterXAxis.layout();
        textPainterXAxis.paint(
          canvas,
          Offset(valueX - textPainterXAxis.width / 2,
              height + textPainterXAxis.height / 1.5),
        );
      }

      //only draw the footer for the first line because it is the same for all the lines
      if (!footerDrawed) footerDrawed = true;

      if (config.displayYAxis) {
        int step = (maxYValue / (config.yLineNum)).ceil();
        for (int i = (config.yLineNum); i > 0; i--) {
          double valueY = height -
              _getRealValue(
                (step * i).floorToDouble(),
                height,
                _maxValueY,
              );

          canvas.drawLine(
              Offset(0, valueY), Offset(size.width, valueY), yAxisLinePaint);
        }
      }

      canvas.drawPath(fillPath, paintFillPath);
      canvas.drawPath(path, paintLine);
      if (config.showDataPoints) {
        //draw data points
        //Data points won't work until Flutter team fix this issue : https://github.com/flutter/flutter/issues/32218
        if (!kIsWeb) {
          canvas.drawPoints(
              PointMode.points,
              dataPoints,
              paintControlPoints
                ..style = PaintingStyle.stroke
                ..strokeWidth = 10
                ..color = line.dataPointStrokeColor);
          canvas.drawPoints(
            PointMode.points,
            dataPoints,
            paintControlPoints
              ..style = PaintingStyle.fill
              ..strokeWidth = line.lineStrokeWidth * 1.5
              ..color = line.dataPointFillColor,
          );
        }
      }
    }

    _drawBezierLinePath(bezierLine);

    if (verticalIndicatorPosition != null && showIndicator) {
      if (config.snap) {
        if (_currentXDataPoint != null) {
          verticalX = _getRealValue(
            _currentXDataPoint.value,
            size.width,
            _maxValueX,
          );
        } else {
          verticalX = 0.0;
        }
      }

      if (p0 != null) {
        //根据x的值,获取贝塞尔曲线上y的值
        final yValue = _getYValues(
          p0,
          p1,
          p2,
          p3,
          (verticalX - p0.dx) / (p3.dx - p0.dx),
        );

        double infoWidth = 0; //base value, modified based on the label text
        double infoHeight = 40;

        //bubble indicator padding
        final horizontalPadding = 28.0;

        double offsetInfo = 42 + ((_currentCustomValues.length - 1.0) * 10.0);
        final centerForCircle = Offset(verticalX, height - yValue);
        final center = config.verticalIndicatorFixedPosition
            ? Offset(verticalX, offsetInfo)
            : centerForCircle;

        if (config.showVerticalIndicator) {
          canvas.drawLine(
            Offset(verticalX, height),
            Offset(verticalX, config.verticalLineFullHeight ? 0.0 : center.dy),
            paintVerticalIndicator,
          );
        }

        //draw point
        canvas.drawCircle(
          centerForCircle,
          radiusDotIndicatorMain,
          Paint()
            ..color = bezierLine.dataPointFillColor
            ..strokeWidth = 4.0,
        );

        //calculate the total lenght of the lines
        List<TextSpan> textValues = [];
        List<Offset> centerCircles = [];

        double space =
            10 - ((infoHeight / (8.75)) * _currentCustomValues.length);
        infoHeight =
            infoHeight + (_currentCustomValues.length - 1) * (infoHeight / 3);

        for (_CustomValue customValue
            in _currentCustomValues.reversed.toList()) {
          textValues.add(
            TextSpan(
              text: config.bubbleIndicatorValueFormat != null
                  ? "${config.bubbleIndicatorValueFormat.format(double.parse(customValue.value))} "
                  : "${customValue.value} ",
              style: config.bubbleIndicatorValueStyle.copyWith(fontSize: 11),
              children: [
                TextSpan(
                  text: "${customValue.label}\n",
                  style: config.bubbleIndicatorLabelStyle.copyWith(fontSize: 9),
                ),
              ],
            ),
          );
          centerCircles.add(
            // Offset(center.dx - infoWidth / 2 + radiusDotIndicatorItems * 1.5,
            Offset(
                center.dx,
                center.dy -
                    offsetInfo -
                    radiusDotIndicatorItems +
                    space +
                    (_currentCustomValues.length == 1 ? 1 : 0)),
          );
          space += 12.5;
        }

        //Calculate Text size
        TextPainter textPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: _getInfoTitleText(),
            style: config.bubbleIndicatorTitleStyle.copyWith(fontSize: 9.5),
            children: textValues,
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        infoWidth =
            textPainter.width + radiusDotIndicatorItems * 2 + horizontalPadding;

        ///Draw Bubble Indicator Info

        /// Draw shadow bubble info
        if (animation.isCompleted) {
          Path path = Path();
          path.moveTo(center.dx - infoWidth / 2 + 4,
              center.dy - offsetInfo + infoHeight / 1.8);
          path.lineTo(center.dx + infoWidth / 2 + 4,
              center.dy - offsetInfo + infoHeight / 1.8);
          path.lineTo(center.dx + infoWidth / 2 + 4,
              center.dy - offsetInfo - infoHeight / 3);
          //path.close();
          // canvas.drawShadow(path, Colors.black, 20.0, false);
          canvas.drawPath(path, paintControlPoints..color = Colors.black12);
        }

        final paintInfo = Paint()
          ..color = config.bubbleIndicatorColor
          ..style = PaintingStyle.fill;

        //Draw Bubble info
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            _fromCenter(
              center: Offset(
                center.dx,
                (center.dy - offsetInfo * animation.value),
              ),
              width: infoWidth,
              height: infoHeight,
            ),
            Radius.circular(5),
          ),
          paintInfo,
        );

        //Draw triangle Bubble
        final double triangleSize = 6;

        Path pathArrow = Path();

        pathArrow.moveTo(center.dx - triangleSize,
            center.dy - offsetInfo * animation.value + infoHeight / 2.1);
        pathArrow.lineTo(
            center.dx,
            center.dy -
                offsetInfo * animation.value +
                infoHeight / 2.1 +
                triangleSize * 1.5);
        pathArrow.lineTo(center.dx + triangleSize,
            center.dy - offsetInfo * animation.value + infoHeight / 2.1);
        pathArrow.close();
        canvas.drawPath(
          pathArrow,
          paintInfo,
        );
        //End triangle

        if (animation.isCompleted) {
          //Paint Text , title and description
          textPainter.paint(
            canvas,
            Offset(
              center.dx - textPainter.width / 2,
              center.dy - offsetInfo - infoHeight / 2.5,
            ),
          );

          //draw circle indicators and text
          for (int z = 0; z < _currentCustomValues.length; z++) {
            _CustomValue customValue = _currentCustomValues[z];
            Offset centerIndicator = centerCircles.reversed.toList()[z];
            Offset fixedCenter = Offset(
                centerIndicator.dx -
                    infoWidth / 2 +
                    radiusDotIndicatorItems +
                    4,
                centerIndicator.dy);
            canvas.drawCircle(
                fixedCenter,
                radiusDotIndicatorItems,
                Paint()
                  ..color = customValue.color
                  ..style = PaintingStyle.fill);
            canvas.drawCircle(
                fixedCenter,
                radiusDotIndicatorItems,
                Paint()
                  ..color = Colors.black
                  ..strokeWidth = 0.5
                  ..style = PaintingStyle.stroke);
          }
        }
      }
    }
  }

  //indicators的标题
  String _getInfoTitleText() {
    final scale = bezierChartScale;

    if (bubbleLabelDateTimeBuilder != null) {
      return bubbleLabelDateTimeBuilder(_currentXDataPoint.xAxis, scale);
    }
    if (scale == BezierChartScale.WEEKLY) {
      final dateFormat = intl.DateFormat('EEE MM/dd');
      final date = _currentXDataPoint.xAxis;
      final now = DateTime.now();
      if (areEqualDates(date, now)) {
        return "Current\n";
      } else {
        return "${dateFormat.format(_currentXDataPoint.xAxis)}\n";
      }
    } else if (scale == BezierChartScale.MONTHLY) {
      final dateFormat = intl.DateFormat('MMM y');
      final date = _currentXDataPoint.xAxis;
      final now = DateTime.now();
      if (date.year == now.year && now.month == date.month) {
        return "Current Month\n";
      } else {
        return "${dateFormat.format(_currentXDataPoint.xAxis)}\n";
      }
    } else if (scale == BezierChartScale.YEARLY) {
      final dateFormat = intl.DateFormat('y');
      final date = _currentXDataPoint.xAxis;
      final now = DateTime.now();
      if (date.year == now.year) {
        return "Current Year\n";
      } else {
        return "${dateFormat.format(_currentXDataPoint.xAxis)}\n";
      }
    }
    return "";
  }

  //x轴文字
  String _getFooterText(DataPoint dataPoint) {
    final scale = bezierChartScale;
    if (footerDateTimeBuilder != null) {
      return footerDateTimeBuilder(dataPoint.xAxis, scale);
    }
    if (scale == BezierChartScale.WEEKLY) {
      final dateFormat = intl.DateFormat('EEE\nMM/dd');
      return "${dateFormat.format(dataPoint.xAxis)}";
    } else if (scale == BezierChartScale.MONTHLY) {
      final dateFormat = intl.DateFormat('MMM');
      final dateFormatYear = intl.DateFormat('y');
      final year = dateFormatYear.format(dataPoint.xAxis).substring(0);
      return "${dateFormat.format(dataPoint.xAxis)}\n$year";
    } else if (scale == BezierChartScale.YEARLY) {
      final dateFormat = intl.DateFormat('y');
      return "${dateFormat.format(dataPoint.xAxis)}";
    }
    return "";
  }

  _getYValues(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    if (t.isNaN) {
      t = 1.0;
    }
    //P0 = (X0,Y0)
    //P1 = (X1,Y1)
    //P2 = (X2,Y2)
    //P3 = (X3,Y3)
    //X(t) = (1-t)^3 * X0 + 3*(1-t)^2 * t * X1 + 3*(1-t) * t^2 * X2 + t^3 * X3
    //Y(t) = (1-t)^3 * Y0 + 3*(1-t)^2 * t * Y1 + 3*(1-t) * t^2 * Y2 + t^3 * Y3
    //source: https://stackoverflow.com/questions/8217346/cubic-bezier-curves-get-y-for-given-x
    final y0 = p0.dy; // x0 = p0.dx;
    final y1 = p1.dy; //x1 = p1.dx,
    final y2 = p2.dy; //x2 = p2.dx,
    final y3 = p3.dy; //x3 = p3.dx,

    //print("p0: $p0, p1: $p1, p2: $p2, p3: $p3 , t: $t");

    final y = pow(1 - t, 3) * y0 +
        3 * pow(1 - t, 2) * t * y1 +
        3 * (1 - t) * pow(t, 2) * y2 +
        pow(t, 3) * y3;
    return y;
  }

  Rect _fromCenter({Offset center, double width, double height}) =>
      Rect.fromLTRB(
        center.dx - width / 2,
        center.dy - height / 2,
        center.dx + width / 2,
        center.dy + height / 2,
      );

  @override
  bool shouldRepaint(_BezierChartPainter oldDelegate) =>
      shouldRepaintChart ||
      oldDelegate.verticalIndicatorPosition != verticalIndicatorPosition ||
      oldDelegate.scrollOffset != scrollOffset ||
      oldDelegate.showIndicator != showIndicator;
}

class _AxisValue {
  final double x;
  final double y;

  const _AxisValue({
    this.x,
    this.y,
  });
}

///This method remove the decimals if the value doesn't have decimals
String formatAsIntOrDouble(double str) {
  final values = str.toString().split(".");
  if (values.length > 1) {
    final int intDecimal = int.parse(values[1]);
    if (intDecimal == 0) {
      return str.toInt().toString();
    }
  }
  return str.toString();
}

class _CustomValue {
  final String value;
  final String label;
  final Color color;

  _CustomValue({
    @required this.value,
    @required this.label,
    @required this.color,
  });
}

bool areEqualDates(DateTime dateTime1, DateTime dateTime2) =>
    dateTime1.year == dateTime2.year &&
    dateTime1.month == dateTime2.month &&
    dateTime1.day == dateTime2.day;

bool areEqualDatesIncludingHour(DateTime dateTime1, DateTime dateTime2) =>
    dateTime1.year == dateTime2.year &&
    dateTime1.month == dateTime2.month &&
    dateTime1.day == dateTime2.day &&
    dateTime1.hour == dateTime2.hour;
