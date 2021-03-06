import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/widget/BaseDialog.dart';

/// 弹框, 提示内容
class MessageDialog extends Dialog {
  final Color positiveTextColor;
  final String title;
  final String message;
  final String negativeText;
  final String positiveText;
  final Function onCloseEvent;
  final Function onPositivePressEvent;

  MessageDialog({
    Key key,
    @required this.title,
    @required this.message,
    this.negativeText,
    this.positiveText,
    this.positiveTextColor,
    this.onPositivePressEvent,
    @required this.onCloseEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: BaseDialog(
        title: title,
        negativeText: negativeText,
        positiveText: positiveText,
        positiveTextColor: positiveTextColor,
        onCloseEvent: onCloseEvent,
        onPositivePressEvent: onPositivePressEvent,
        body: Container(
          constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
          padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: IntrinsicHeight(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
