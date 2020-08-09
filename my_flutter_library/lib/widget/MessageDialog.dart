import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 公共弹框, 样式统一
class MessageDialog extends Dialog {
  final Color positiveTextColor;
  final String title;
  final String message;
  final String negativeText;
  final String positiveText;
  final Function onCloseEvent;
  final Function onPositivePressEvent;
  final bool showCloseButton;

  MessageDialog({
    Key key,
    @required this.title,
    @required this.message,
    this.negativeText,
    this.positiveText,
    this.positiveTextColor,
    this.onPositivePressEvent,
    @required this.onCloseEvent,
    this.showCloseButton = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(100.w),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: ShapeDecoration(
                color: Color(0xffffffff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(11.0),
                  ),
                ),
              ),
              margin: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: <Widget>[
                        Center(
                          child: Text(
                            title, style: TextStyle(fontSize: 35.sp),
                          ),
                        ),
                        Offstage(
                          offstage: showCloseButton,
                          child: GestureDetector(
                            onTap: this.onCloseEvent,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.close, color: Color(0xffe0e0e0),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 150.h),
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: IntrinsicHeight(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30.sp),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffe0e0e0),
                    height: 1.0,
                  ),
                  this._buildBottomButtonGroup(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtonGroup() {
    var widgets = <Widget>[];
    bool hasNegativeButton = negativeText != null && negativeText.isNotEmpty;
    bool hasPositiveButton = positiveText != null && positiveText.isNotEmpty;

    if (hasNegativeButton) widgets.add(_buildBottomCancelButton());

    if(hasNegativeButton && hasPositiveButton) {
      widgets.add(
        Container(
          color: Color(0xffe0e0e0),
          width: 1.0,
          height: 30.h,
        ),
      );
    }

    if (hasPositiveButton) widgets.add(_buildBottomPositiveButton());

    return Flex(
      direction: Axis.horizontal,
      children: widgets,
    );
  }

  Widget _buildBottomCancelButton() {
    return Flexible(
      fit: FlexFit.tight,
      child: FlatButton(
        onPressed: onCloseEvent,
        highlightColor: Colors.white,
        splashColor: Colors.white,
        focusColor: Colors.white,
        child: Text(
          negativeText,
          style: TextStyle(
            fontSize: 25.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPositiveButton() {
    return Flexible(
      fit: FlexFit.tight,
      child: FlatButton(
        onPressed: onPositivePressEvent,
        highlightColor: Colors.white,
        focusColor: Colors.white,
        splashColor: Colors.white,
        child: Text(
          positiveText,
          style: TextStyle(
            fontSize: 25.sp,
            color: positiveTextColor ?? Colors.black
          ),
        ),
      ),
    );
  }
}
