import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_library/dio/DioUtil.dart';
import 'package:my_flutter_library/widget/ProgressDialog.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DownloadPageState();
  }
}

class DownloadPageState extends State<DownloadPage> {
  int percent = 0;
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("下载文件"),
      ),
      body: Container(
        height: 200,
        child: Center(
            child: FlatButton(
                onPressed: _download,
                child: Text("下载"),
            ),
        )
      ),
    );
  }

  _download() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      //ios打开APP STORE下载
      String url = 'itms-apps://itunes.apple.com/cn/app/id414478124?mt=8'; // 这是微信的地址
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      _requestPermission();
    }
  }

  ///查询存储相关的权限
  _requestPermission() async {
    var status = await Permission.storage.status;
    //用户还没申请权限
    if (status.isUndetermined) {
      status = await Permission.storage.request();
    }

    if (status.isPermanentlyDenied) {
      //用户拒绝了权限, 并勾选不再提醒, 给用户必要提示去往设置页面,手动打开权限
      openAppSettings();
    } else if (status.isDenied) {
      //给用户必要提示, 重新申请权限
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      //用户同意了权限
      _downloadApk();
    }
  }

  ///开始下载
  _downloadApk() async {
    final String path = await _apkLocalPath;

    final url = "https://down.qq.com/qqweb/QQ_1/android_apk/Android_8.4.1.4680_537064985.apk";

    //用于取消下载
    CancelToken cancelToken = CancelToken();

    _showProgress(taskId: cancelToken);

    DioUtil.getInstance().download(url, path + "/qq.apk", onReceiveProgress: (int count, int total) {
      //进度
      //print("$count $total");
      if (count < total) {
        double percent = (count / total) * 100;
        //print("percent: $percent");
        pr.update(progress: percent);
      } else {
        //下载完成, 开始安装应用
        pr.hide();
        _installApk();
      }
    }, cancelToken: cancelToken);
  }

  /// 获取安装地址
  Future<String> get _apkLocalPath async {
    final directory = defaultTargetPlatform == TargetPlatform.android ? await getExternalStorageDirectory() : await getApplicationSupportDirectory();

    print("_apkLocalPath- ${directory.path}");
    return directory.path;
  }

  /// 原生通信安装apk
  Future<Null> _installApk() async {
    const platform = const MethodChannel("my_flutter_library/plugin");
    try {
      final path = await _apkLocalPath;
      //传递 Map 类型数据到原生
      //result 是原生的 MethodChannel.Result.success(Object) 传递过来的 Object
      var result = await platform.invokeMethod('install', {'path': path + '/qq.apk'});
    } on PlatformException catch (_) {}
  }

  _showProgress({taskId}) {
    pr = ProgressDialog(context, taskId);
    pr.show();
  }
}
