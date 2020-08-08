import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


///使用自定义字体
///首先在 pubspec.yaml 中配置字体资源, 然后根据 family 调用自定义字体库
class CustomerFontPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("客制化字体"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
        child:  Column(
          children: <Widget>[
            Text("使用自定义字体库, 使用自定义字体库, 使用自定义字体库, 使用自定义字体库, 使用自定义字体库",
              style: TextStyle(fontFamily: "familyFontStyle"),
            ),
            Text("使用原生字体, 使用原生字体, 使用原生字体, 使用原生字体, 使用原生字体, 使用原生字体")
          ],
        ),
      ),
    );
  }
}