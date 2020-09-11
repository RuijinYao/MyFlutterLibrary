import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/dio/DioUtil.dart';
import 'package:my_flutter_library/widget/ProgressDialog.dart';
import 'package:my_flutter_library/widget/bezier_chart/BezierChartConfig.dart';
import 'package:my_flutter_library/widget/bezier_chart/BezierChartWidget.dart';
import 'package:my_flutter_library/widget/bezier_chart/BezierLine.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';


//https://github.com/aeyrium/bezier-chart
//在原有代码的基础上新增填充色
class BezierTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BezierTestPageState();
  }
}

class BezierTestPageState extends State<BezierTestPage> {
  BezierChartScale _chartScale = BezierChartScale.WEEKLY;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("贝塞尔曲线"),
      ),
      body: Container(
          height: ScreenUtil.screenHeight * 0.7,
          width: ScreenUtil.screenWidth,
          child: BezierChart(
              bezierChartScale: _chartScale,
              bezierLine: BezierLine(
                  lineColor: Color(0xffccc300),
                  fillColor: Color(0xffffc300),
                  dataPointStrokeColor: Colors.white,
                  dataPointFillColor: Color(0xffffc300),
                  data: [
                      new DataPoint(value: 34, xAxis: DateTime.now()),
                      new DataPoint(value: 24, xAxis: DateTime.now().add(Duration(days: 1))),
                      new DataPoint(value: 54, xAxis: DateTime.now().add(Duration(days: 2))),
                      new DataPoint(value: 7, xAxis: DateTime.now().add(Duration(days: 3))),
                      new DataPoint(value: 80, xAxis: DateTime.now().add(Duration(days: 4))),
                      new DataPoint(value: 66, xAxis: DateTime.now().add(Duration(days: 5))),
                      new DataPoint(value: 66, xAxis: DateTime.now().add(Duration(days: 6))),
                      new DataPoint(value: 66, xAxis: DateTime.now().add(Duration(days: 7))),
                      new DataPoint(value: 66, xAxis: DateTime.now().add(Duration(days: 8))),
                  ],
              ),
              config: BezierChartConfig(
                  updatePositionOnTap: false,
                  verticalIndicatorStrokeWidth: 1.0,
                  verticalIndicatorColor: Colors.black26,
                  yAxisTextStyle: TextStyle(color: Colors.black),
                  snap: true,
              ),
          ),
      )
    );
  }


}
