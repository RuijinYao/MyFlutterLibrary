import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:my_flutter_library/util/Api.dart';
import 'package:my_flutter_library/util/Constant.dart';

import 'package:shared_preferences/shared_preferences.dart';


///网络请求的工具类, 单例模式
class DioUtil {
  static DioUtil _instance;

  static DioUtil getInstance() {
    if (_instance == null) {
      _instance = DioUtil();
    }
    return _instance;
  }

  Dio dio = new Dio();

  DioUtil() {
    // Set default configs
    dio.options.baseUrl = Api.BASE_URL;
    dio.options.connectTimeout = Constant.connectTime;
    dio.options.receiveTimeout = Constant.receiveTime;

    ///token 拦截
    dio.interceptors.add(MyInterceptor());

    ///日志拦截
    dio.interceptors.add(LogInterceptor(responseBody: Constant.isDebug));

    //dio.interceptors.add(CookieManager(CookieJar()));//cookie 拦截 详情参考 https://github.com/flutterchina/cookie_jar
  }

  //get请求
  Future<Map> get(String url, {Map<String, dynamic> params, Function successCallBack, Function errorCallBack, bool isFormData = true}) async {
    return _requestHttp(url, successCallBack, 'get', params, errorCallBack, isFormData);
  }

  //post请求
  Future<Map> post(String url, {Map<String, dynamic> params, Function successCallBack, Function errorCallBack, bool isFormData = true}) async {
    return _requestHttp(url, successCallBack, "post", params, errorCallBack, isFormData);
  }

  Future<Map> _requestHttp(String url, [Function successCallBack, String method, Map<String, dynamic> params, Function errorCallBack, bool isFormData]) async {
    Response response;
    try {
      if (method == 'get') {
        if (params != null && params.isNotEmpty) {
          response = await dio.get(url, queryParameters: params);
        } else {
          response = await dio.get(url);
        }
      } else if (method == 'post') {

        if (params != null && params.isNotEmpty) {
            if(isFormData){
                response = await dio.post(url, data: FormData.fromMap(params));
            } else {
                //网络请求报错HTTP error 415 with FormData 时, 参数不能用 FormData 格式
                response = await dio.post(url, data: params);
            }
        } else {
          response = await dio.post(url);
        }
      }
    } on DioError catch (error) {
      // 处理报错
      Response errorResponse;
      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      // 连接超时
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        errorResponse.statusCode = Constant.connectTimeout;
      }
      // 接收超时
      else if (error.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = Constant.receiveTimeout;
      }

      // debug 开关
      if (Constant.isDebug) {
        print('请求报错: ' + error.toString());
        print('请求地址: ' + url);
        print('请求头: ' + dio.options.headers.toString());
        print('method: ' + dio.options.method);
      }
      _error(errorCallBack, {"错误码": error.response.statusCode, "message": error.message});
      return null;
    }
    // debug 开关
    if (Constant.isDebug) {
      print('请求地址: ' + url);
      print('请求头: ' + dio.options.headers.toString());
      if (params != null) {
        print('请求参数: ' + params.toString());
      }
      if (response != null) {
        print('回复:' + response.toString());
      }
    }
    String dataStr = json.encode(response.data);
    Map<String, dynamic> dataMap = json.decode(dataStr);
    if (dataMap == null || dataMap['status'] != 200) {
      _error(errorCallBack, {"错误码": dataMap['status'], "message": dataMap['message']});
    } else if (successCallBack != null) {
      successCallBack(dataMap['result']);
    }

    return response.data['result'];
  }

  _error(Function errorCallBack, Map<String, dynamic> error) {
    if (errorCallBack != null) {
      errorCallBack(error);
      return;
    }

    //todo showToast(error['message']);
  }
}


///网络请求的自定义拦截器, 主要实现网络请求中token的检验
///用户登录时自动获取token值, 并且保存本地, 其他的接口请求时自动在 header中加入检验
class MyInterceptor extends Interceptor {
  @override
  Future onRequest(RequestOptions options) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString(Constant.token);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = "Bearer " + token;
    }

    return options;
  }

  @override
  Future onResponse(Response response) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String uri = response.request.uri.toString();
    //如果是登录接口, 将保存token值
    if (uri == (Api.BASE_URL + Api.USER_LOGIN)) {
      String dataStr = json.encode(response.data);
      Map<String, dynamic> dataMap = json.decode(dataStr);
      //此处'accessToken' 为服务器返回的具体json 中相关 token 的key, 视具体情况而定
      preferences.setString(Constant.token, dataMap['accessToken']);
    }

    return response;
  }
}
