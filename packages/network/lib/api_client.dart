import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String _baseUrl = 'http://localhost:3000';
  static const String _tokenKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({String? baseUrl})
      : _storage = const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      _LogInterceptor(),
    ]);
  }

  // === Auth ===
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    await _saveTokens(res.data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String role,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'phone': phone,
      'password': password,
      'role': role,
    });
    await _saveTokens(res.data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }

  // === Products ===
  Future<List<dynamic>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get('/products', queryParameters: {
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      'page': page,
      'limit': limit,
    });
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    final res = await _dio.get('/products/$id');
    return res.data as Map<String, dynamic>;
  }

  // === Orders ===
  Future<List<dynamic>> getOrders() async {
    final res = await _dio.get('/orders');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final res = await _dio.post('/orders', data: data);
    return res.data as Map<String, dynamic>;
  }

  // === Stories ===
  Future<List<dynamic>> getStories({int page = 1, int limit = 10}) async {
    final res = await _dio.get('/stories', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return res.data as List<dynamic>;
  }

  Future<void> likeStory(String storyId) async {
    await _dio.post('/stories/$storyId/like');
  }

  // === Media ===
  Future<Map<String, dynamic>> uploadFile(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post('/media/upload', data: formData);
    return res.data as Map<String, dynamic>;
  }

  // === Helpers ===
  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    if (accessToken != null) {
      await _storage.write(key: _tokenKey, value: accessToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }
}

// === Auth Interceptor — автоматически добавляет JWT ===
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: implement token refresh
    }
    handler.next(err);
  }
}

// === Log Interceptor (только в debug) ===
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API ERROR] ${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
