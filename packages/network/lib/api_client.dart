import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Базовый URL реального бэкенда
const _kBaseUrl = 'http://146.190.24.241/api';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  // Токены
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: ContentType.json.value,
    ));

    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugLog(o.toString()),
    ));
  }

  void debugLog(String msg) {
    // ignore in prod
    assert(() {
      // ignore: avoid_print
      print('[ApiClient] $msg');
      return true;
    }());
  }

  // =================== AUTH ===================

  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    // Сохраняем токены
    if (data['accessToken'] != null) {
      await _storage.write(key: _accessTokenKey, value: data['accessToken'] as String);
    }
    if (data['refreshToken'] != null) {
      await _storage.write(key: _refreshTokenKey, value: data['refreshToken'] as String);
    }
    return data;
  }

  /// POST /auth/register
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    String role = 'BUYER',
    String? name,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'phone': phone,
      'password': password,
      'role': role,
      if (name != null) 'name': name,
    });
    return res.data as Map<String, dynamic>;
  }

  /// GET /auth/me
  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  /// POST /auth/refresh
  Future<void> refreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    if (token == null) throw Exception('No refresh token');
    final res = await _dio.post('/auth/refresh', data: {'refreshToken': token});
    final data = res.data as Map<String, dynamic>;
    if (data['accessToken'] != null) {
      await _storage.write(key: _accessTokenKey, value: data['accessToken'] as String);
    }
    if (data['refreshToken'] != null) {
      await _storage.write(key: _refreshTokenKey, value: data['refreshToken'] as String);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  // =================== PRODUCTS ===================

  /// GET /products?category=&search=&page=&limit=
  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
    bool? isFeatured,
  }) async {
    final res = await _dio.get('/products', queryParameters: {
      if (category != null && category != 'Все') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'limit': limit,
      if (isFeatured != null) 'isFeatured': isFeatured,
    });
    return res.data as Map<String, dynamic>;
  }

  /// GET /products/:id
  Future<Map<String, dynamic>> getProduct(String id) async {
    final res = await _dio.get('/products/$id');
    return res.data as Map<String, dynamic>;
  }

  // =================== ORDERS ===================

  /// POST /orders
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    String deliveryType = 'DELIVERY',
  }) async {
    final res = await _dio.post('/orders', data: {
      'items': items,
      'deliveryAddress': deliveryAddress,
      'deliveryType': deliveryType,
    });
    return res.data as Map<String, dynamic>;
  }

  /// GET /orders (покупатель видит свои заказы)
  Future<List<dynamic>> getOrders({String? status}) async {
    final res = await _dio.get('/orders', queryParameters: {
      if (status != null) 'status': status,
    });
    return (res.data is List) ? res.data as List : (res.data['items'] as List? ?? []);
  }

  // =================== STORIES/REELS ===================

  /// GET /stories/feed
  Future<List<dynamic>> getStoriesFeed({int page = 1, int limit = 10}) async {
    final res = await _dio.get('/stories/feed', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return (res.data is List) ? res.data as List : (res.data['items'] as List? ?? []);
  }

  /// POST /stories/:id/like
  Future<void> likeStory(String id) async {
    await _dio.post('/stories/$id/like');
  }

  // =================== MEDIA ===================

  /// POST /media/upload/image
  Future<String> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post('/media/upload/image', data: formData);
    return (res.data as Map<String, dynamic>)['url'] as String;
  }

  // =================== SELLER PRODUCTS ===================

  /// GET /products/seller/my-products (требует JWT + роль SELLER)
  Future<dynamic> getMySellerProducts({int page = 1, int limit = 50}) async {
    final res = await _dio.get('/products/seller/my-products', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return res.data;
  }

  /// POST /products (создать товар — только SELLER)
  Future<Map<String, dynamic>> createSellerProduct({
    required String title,
    required double price,
    required int stock,
    required String category,
    String? description,
    List<String>? imageUrls,
  }) async {
    final res = await _dio.post('/products', data: {
      'title': title,
      'price': price,
      'stock': stock,
      'category': category,
      if (description != null) 'description': description,
      if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
    });
    return res.data as Map<String, dynamic>;
  }

  /// PUT /products/:id (обновить товар — только владелец)
  Future<Map<String, dynamic>> updateSellerProduct({
    required String productId,
    required String title,
    required double price,
    required int stock,
    required String category,
    String? description,
    List<String>? imageUrls,
  }) async {
    final res = await _dio.put('/products/$productId', data: {
      'title': title,
      'price': price,
      'stock': stock,
      'category': category,
      if (description != null) 'description': description,
      if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
    });
    return res.data as Map<String, dynamic>;
  }

  /// DELETE /products/:id
  Future<void> deleteSellerProduct(String productId) async {
    await _dio.delete('/products/$productId');
  }

  /// PUT /products/:id/toggle (toggle active)
  Future<Map<String, dynamic>> toggleSellerProduct(String productId) async {
    final res = await _dio.put('/products/$productId/toggle');
    return res.data as Map<String, dynamic>;
  }
  /// PUT /orders/:id/status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _dio.put('/orders/$orderId/status', data: {'status': status});
  }
}

// =================== AUTH INTERCEPTOR ===================

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  static const _accessTokenKey = 'access_token';

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Публичные endpoints — без токена
    final publicRoutes = ['/auth/login', '/auth/register'];
    if (publicRoutes.any((r) => options.path.contains(r))) {
      return handler.next(options);
    }

    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        // Попробуем обновить токен
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          final res = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {}),
          );
          final newToken = (res.data as Map<String, dynamic>)['accessToken'] as String?;
          if (newToken != null) {
            await _storage.write(key: _accessTokenKey, value: newToken);
            // Повторяем оригинальный запрос
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryRes = await _dio.fetch(err.requestOptions);
            return handler.resolve(retryRes);
          }
        }
      } catch (_) {
        // Refresh failed — logout
        await _storage.deleteAll();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}
