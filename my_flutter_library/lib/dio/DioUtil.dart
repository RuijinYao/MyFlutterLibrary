import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'package:my_flutter_library/util/Api.dart';
import 'package:my_flutter_library/util/Constant.dart';

import 'package:sp_util/sp_util.dart';

///网络请求的工具类, 单例模式
///网络返回数据格式
//{
//  "accessToken": "string",
//  "message": "string",
//  "result": {}, //具体请求结果
//  "status": 0
//}
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
    dio.interceptors.add(TokenInterceptor());
    ///刷新token 拦截器
    dio.interceptors.add(RefreshTokenInterceptor());

    ///日志拦截
    dio.interceptors.add(LogInterceptor(responseBody: Constant.isDebug));

    ///cookie 拦截 详情参考 https://github.com/flutterchina/cookie_jar
    dio.interceptors.add(CookieManager(CookieJar()));
  }

  //get请求
  Future<Map> get(String url, {Map<String, dynamic> params, Function successCallBack, Function errorCallBack, bool isFormData = true}) async {
    return _requestHttp(url, successCallBack, 'get', params, errorCallBack, isFormData);
  }

  //post请求
  Future<Map> post(String url, {Map<String, dynamic> params, Function successCallBack, Function errorCallBack, bool isFormData = true}) async {
    return _requestHttp(url, successCallBack, "post", params, errorCallBack, isFormData);
  }

  Future<Map> _requestHttp(String url,
      [Function successCallBack, String method, Map<String, dynamic> params, Function errorCallBack, bool isFormData]) async {
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
          if (isFormData) {
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

  Future download(String url, String savePath, {ProgressCallback onReceiveProgress, CancelToken cancelToken}) async {
    Response response;
    try {
      response = await dio.download(url, savePath,
          cancelToken: cancelToken, onReceiveProgress: onReceiveProgress, options: Options(receiveTimeout: 1000 * 600));
    } on DioError catch (e) {
      print('downloadFile error---------$e');
    }

    return response;
  }
}

///网络请求的自定义拦截器, 主要实现网络请求中token的检验
///用户登录时自动获取token值, 并且保存本地, 其他的接口请求时自动在 header中加入检验
class TokenInterceptor extends Interceptor {
  @override
  Future onRequest(RequestOptions options) async {
    String token = SpUtil.getString(Constant.token);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = "Bearer " + token;
    }

    return options;
  }

  @override
  Future onResponse(Response response) async {
    String uri = response.request.uri.toString();
    //如果是登录接口, 将保存token值
    if (uri == (Api.BASE_URL + Api.USER_LOGIN)) {
      String dataStr = json.encode(response.data);
      Map<String, dynamic> dataMap = json.decode(dataStr);
      //此处'accessToken' 为服务器返回的具体json 中相关 token 的key, 视具体情况而定
      SpUtil.putString(Constant.token, dataMap['accessToken']);
    }

    return response;
  }
}

///自定义拦截器, 自动刷新token
class RefreshTokenInterceptor extends Interceptor {
  Dio _tokenDio = Dio();

  @override
  Future onError(DioError error) async {
    //401 未认证, 刷新token值
    if (error.response != null && error.response.statusCode == Constant.unauthorized) {
      final Dio dio = DioUtil.getInstance().dio;
      dio.interceptors.requestLock.lock();
      final String refreshToken = await _refreshToken();
      SpUtil.putString(Constant.token, refreshToken);
      dio.interceptors.requestLock.unlock();

      //重新请求接口
      if (refreshToken != null) {
        final RequestOptions requestOptions = error.response.request;
        requestOptions.headers['Authorization'] = 'Bearer $refreshToken';
        try {
          //重新请求
          final Response response = await _tokenDio.request(requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              cancelToken: requestOptions.cancelToken,
              options: requestOptions,
              onReceiveProgress: requestOptions.onReceiveProgress);
          return response;
        } on DioError catch (e) {
          return e;
        }
      }
    }

    return error;
  }

  Future<String> _refreshToken() async {
    final Map<String, String> params = <String, String>{};
    params['refresh_token'] = SpUtil.getString(Constant.token);
    _tokenDio.options = DioUtil.getInstance().dio.options;

    try {
      final Response response = await _tokenDio.get(Api.USER_REFRESH_TOKEN, queryParameters: params);
      if (response.statusCode == Constant.netSucceed) {
        return jsonDecode(response.data)["accessToken"];
      }
    } on DioError catch (e) {
      print('刷新Token失败！');
    }

    return null;
  }
}
