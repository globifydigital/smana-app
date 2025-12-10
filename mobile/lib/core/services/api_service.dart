import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio _dio;

  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(request: true, requestBody: true, responseBody: true),
    );
  }

  void setToken(String token) {
    _token = token;
  }

  Dio get dio => _dio;

  // Generic POST
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // Generic GET
  Future<Response> get(String path) async {
    return await _dio.get(path);
  }
}
