import 'package:flutter/material.dart';
import 'package:my_flutter_library/widget/BaseDialog.dart';

/// 弹框, 多选
/// 可设置 默认选中项, 最多选中个数, 最小选中个数
class MultiSelectDialog extends StatefulWidget {
  final Color positiveTextColor;
  final String title;
  final List<String> options;
  final List<String> defaultChoice;
  int maxChoicesNum;
  final int minChoicesNum;
  final String negativeText;
  final String positiveText;
  final Function onCloseEvent;
  final Function(List<int>) onPositivePressEvent;

  MultiSelectDialog({
    Key key,
    @required this.title,
    @required this.options,
    this.defaultChoice,
    this.maxChoicesNum,
    this.minChoicesNum: 0,
    this.negativeText,
    this.positiveText,
    this.positiveTextColor,
    this.onPositivePressEvent,
    @required this.onCloseEvent,
  }) : super(key: key) {
    if (maxChoicesNum == null) {
      maxChoicesNum = options.length;
    }
  }

  @override
  State<StatefulWidget> createState() {
    return MultiSelectDialogState();
  }
}

class MultiSelectDialogState extends State<MultiSelectDialog> {
  List<int> _values = [];

  @override
  void initState() {
    super.initState();
    widget.defaultChoice.forEach((element) {
      _values.add(widget.options.indexOf(element));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: BaseDialog(
          title: widget.title,
          negativeText: widget.negativeText,
          positiveText: widget.positiveText,
          positiveTextColor: widget.positiveTextColor,
          onCloseEvent: widget.onCloseEvent,
          onPositivePressEvent: () {
            Navigator.pop(context);
            widget.onPositivePressEvent(_values);
          },
          body: Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.options.length, (i) => _buildItem(i))),
              ))),
    );
  }

  Widget _buildItem(int index) {
    return Material(
        type: MaterialType.transparency,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            child: SizedBox(
              height: 42.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.options[index],
                      style: _values.contains(index)
                          ? TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            )
                          : TextStyle(
                              fontSize: 13,
                            ),
                    ),
                  ),
                  Visibility(visible: _values.contains(index), child: Image.asset('assets/ic_check.png', width: 16.0, height: 16.0)),
                ],
              ),
            ),
            onTap: () {
              if (mounted) {
                if (_values.contains(index)) {
                  //当前数量大于最小数时才能取消勾选
                  if (_values.length > widget.minChoicesNum) {
                    setState(() {
                      _values.remove(index);
                    });
                  }
                } else {
                  //当前数量,小于最多可选数时才能继续选择
                  if (_values.length < widget.maxChoicesNum) {
                    setState(() {
                      _values.add(index);
                    });
                  }
                }
              }
            },
          ),
        ));
  }
}
