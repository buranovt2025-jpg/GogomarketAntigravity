import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'seller_api_client_provider.dart';

class SellerAuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const SellerAuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  SellerAuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      SellerAuthState(
        user: clearUser ? null : user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class SellerAuthNotifier extends StateNotifier<SellerAuthState> {
  final Ref _ref;

  SellerAuthNotifier(this._ref) : super(const SellerAuthState()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final api = _ref.read(sellerApiClientProvider);
      final data = await api.getMe();
      state = state.copyWith(user: _parseUser(data), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(sellerApiClientProvider);
      final data = await api.login(phone: phone, password: password);
      
      final user = _parseUser(data['user'] ?? data);
      
      // Проверка роли продавца
      if (user.role != UserRole.seller && user.role != UserRole.admin) {
        state = state.copyWith(isLoading: false, error: 'Доступ только для продавцов');
        await api.logout();
        return false;
      }

      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Ошибка входа: ${e.toString()}');
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(sellerApiClientProvider).logout();
    state = const SellerAuthState();
  }

  User _parseUser(Map<String, dynamic> m) {
    final roleStr = m['role']?.toString().toUpperCase() ?? 'SELLER';
    final role = roleStr == 'ADMIN' 
        ? UserRole.admin 
        : (roleStr == 'SELLER' ? UserRole.seller : UserRole.buyer);

    return User(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? 'Продавец',
      phone: m['phone']?.toString() ?? '',
      role: role,
    );
  }
}

final sellerAuthProvider =
    StateNotifierProvider<SellerAuthNotifier, SellerAuthState>(
  (ref) => SellerAuthNotifier(ref),
);

