import 'package:flutter/material.dart';
import 'package:my_flutter_library/widget/BaseDialog.dart';

/// 弹框, 单选
class SingleSelectDialog extends StatefulWidget {
  final Color positiveTextColor;
  final String title;
  final List<String> options;
  final String negativeText;
  final String positiveText;
  final Function onCloseEvent;
  final Function(int index, String value) onPositivePressEvent;

  SingleSelectDialog({
    Key key,
    @required this.title,
    @required this.options,
    this.negativeText,
    this.positiveText,
    this.positiveTextColor,
    this.onPositivePressEvent,
    @required this.onCloseEvent,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SingleSelectDialogState();
  }
}

class SingleSelectDialogState extends State<SingleSelectDialog> {
  int _value = 0;

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
          widget.onPositivePressEvent(_value, widget.options[_value]);
        },
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.options.length, (i) => _buildItem(i))),
      ),
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
                      style: _value == index
                          ? TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                    ),
                  ),
                  Visibility(visible: _value == index, child: Image.asset('assets/ic_check.png', width: 16.0, height: 16.0)),
                ],
              ),
            ),
            onTap: () {
              if (mounted) {
                setState(() {
                  _value = index;
                });
              }
            },
          ),
        ));
  }
}
