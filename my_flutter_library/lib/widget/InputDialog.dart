import 'package:flutter/material.dart';
import 'package:my_flutter_library/widget/BaseDialog.dart';

/// 弹框, 输入内容
class InputDialog extends Dialog {
  final Color positiveTextColor;
  final String title;
  final String negativeText;
  final String positiveText;
  final Function onCloseEvent;
  final Function onPositivePressEvent;

  InputDialog({
    Key key,
    @required this.title,
    this.negativeText,
    this.positiveText,
    this.positiveTextColor,
    this.onPositivePressEvent,
    @required this.onCloseEvent,
  }) : super(key: key);

  final TextEditingController _controller = TextEditingController();

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
        onPositivePressEvent: () {
          Navigator.pop(context);
          onPositivePressEvent(_controller.text);
        },
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              autofocus: true,
              controller: _controller,
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                border: InputBorder.none,
                hintText: '输入文字…',
                //hintStyle: TextStyles.textGrayC14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
