import 'package:dio/dio.dart';

class AuthInterceptor extends InterceptorsWrapper {
  final int? entrepriseId;
  final String? token;
  AuthInterceptor(this.entrepriseId, this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (entrepriseId != null || token != null) {
      options.queryParameters.addAll({'entrepriseId': entrepriseId});
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}
