import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';
import '../constants/api_endpoints.dart';
import '../../features/auth/data/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(apiClient, storageService);
});

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated;
});

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  UserModel? _currentUser;

  AuthService(this._apiClient, this._storageService);

  Future<bool> get isAuthenticated async {
    final token = await _storageService.getAccessToken();
    return token != null;
  }

  UserModel? get currentUser => _currentUser;

  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data;
    final user = UserModel.fromJson(data['user']);
    final tokens = data['tokens'];

    await _storageService.saveTokens(
      tokens['accessToken'],
      tokens['refreshToken'],
    );
    await _storageService.saveUserId(user.id);

    _currentUser = user;
    return user;
  }

  Future<UserModel> register({
    required String phone,
    required String password,
    required String storeName,
    required String cabinetType,
    String? category,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'phone': phone,
        'password': password,
        'role': 'seller',
        'storeName': storeName,
        'cabinetType': cabinetType,
        if (category != null) 'category': category,
      },
    );

    final data = response.data;
    final user = UserModel.fromJson(data['user']);
    final tokens = data['tokens'];

    await _storageService.saveTokens(
      tokens['accessToken'],
      tokens['refreshToken'],
    );
    await _storageService.saveUserId(user.id);

    _currentUser = user;
    return user;
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.getProfile);
    _currentUser = UserModel.fromJson(response.data);
    return _currentUser!;
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _currentUser = null;
  }
}
