import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'api_client_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearError = false}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final api = _ref.read(apiClientProvider);
      final data = await api.getMe();
      state = state.copyWith(user: _parseUser(data), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(apiClientProvider);
      final data = await api.login(phone: phone, password: password);
      
      final user = _parseUser(data['user'] ?? data);
      
      // Проверка роли курьера
      if (user.role != UserRole.courier) {
        state = state.copyWith(isLoading: false, error: 'Доступ только для курьеров');
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
    await _ref.read(apiClientProvider).logout();
    state = const AuthState();
  }

  User _parseUser(Map<String, dynamic> m) {
    final roleStr = m['role']?.toString().toUpperCase() ?? 'COURIER';
    final role = roleStr == 'COURIER' ? UserRole.courier : UserRole.buyer;

    return User(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? 'Курьер',
      phone: m['phone']?.toString() ?? '',
      role: role,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

final isAuthenticatedProvider = Provider<bool>((ref) => ref.watch(authProvider).isAuthenticated);
