import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double _progress = 0;
CancelToken _taskId ;

bool _isShowing = false;

class ProgressDialog {
  _MyDialog _dialog;

  BuildContext _buildContext, _context;

  ProgressDialog(BuildContext buildContext, CancelToken taskId) {
    _buildContext = buildContext;
    _taskId = taskId;
  }

  void update({double progress}) {
    _progress = progress;
    _dialog.update();
  }

  bool isShowing() {
    return _isShowing;
  }

  void hide() {
    _isShowing = false;
    Navigator.of(_context).pop();
  }

  void show() {
    _dialog = new _MyDialog();
    _isShowing = true;
    showDialog<dynamic>(
      context: _buildContext,
      barrierDismissible: false,    //点击边框外围不会使边框消失
      builder: (BuildContext context) {
        _context = context;
        return Dialog(
            insetAnimationCurve: Curves.easeInOut,
            insetAnimationDuration: Duration(milliseconds: 100),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: _dialog);
      },
    );
  }
}

// ignore: must_be_immutable
class _MyDialog extends StatefulWidget {
  var _dialog = new _MyDialogState();

  update() {
    _dialog.changeState();
  }

  @override
  // ignore: must_be_immutable
  State<StatefulWidget> createState() {
    return _dialog;
  }
}

class _MyDialogState extends State<_MyDialog> {

  changeState() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _isShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _interceptBack,
        child: SizedBox(
          height: 220.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "更新中",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                    ),
                  )
                ],
              ),
              Divider(),
              SizedBox(
                width: 60.0,
                height: 60.0,
                child: Image.asset(
                  'assets/double_ring_loading_io.gif',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "${_progress.floor()}%",
                    style: TextStyle(
                        fontSize: 25.0
                    ),
                  )
                ],
              ),
              Divider(),
              FractionallySizedBox(
                  widthFactor: 0.6,
                  child: FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                        _taskId.cancel();
                    },
                    child: Text("取消",
                      style: TextStyle(
                        fontSize: 20.0,
                          color: Colors.white
                      ),
                    ),
                    color: Colors.green,
                  )
              )
            ],
          ),
        )
    );
  }

  //下载框弹出过程中禁用返回键
  Future<bool> _interceptBack(){
    return Future.value(false);
  }
}
