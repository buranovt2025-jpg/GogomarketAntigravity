import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'api_client_provider.dart';

// ===================== STATE =====================

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

// ===================== NOTIFIER =====================

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _tryRestoreSession();
  }

  /// Попробовать восстановить сессию по сохранённому токену
  Future<void> _tryRestoreSession() async {
    try {
      final api = _ref.read(apiClientProvider);
      final token = await api.getAccessToken();
      if (token == null) return;

      state = state.copyWith(isLoading: true);
      final me = await api.getMe();
      state = state.copyWith(
        user: _parseUser(me),
        isLoading: false,
      );
    } catch (_) {
      // Токен невалидный — остаёмся не-авторизованными
      state = const AuthState();
    }
  }

  /// Логин через реальный API
  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(apiClientProvider);
      final data = await api.login(phone: phone, password: password);

      // После логина получаем профиль
      final me = await api.getMe();
      state = state.copyWith(user: _parseUser(me), isLoading: false);
      return true;
    } on Exception catch (e) {
      final msg = _friendlyError(e.toString());
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  /// Регистрация нового покупателя
  Future<bool> register({
    required String phone,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = _ref.read(apiClientProvider);
      await api.register(phone: phone, password: password, name: name);
      // После регистрации сразу логинимся
      return await login(phone: phone, password: password);
    } on Exception catch (e) {
      final msg = _friendlyError(e.toString());
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.logout();
    } catch (_) {}
    state = const AuthState();
  }

  User _parseUser(Map<String, dynamic> m) {
    final roleStr = m['role']?.toString().toUpperCase() ?? 'BUYER';
    final role = roleStr == 'SELLER'
        ? UserRole.seller
        : roleStr == 'COURIER'
            ? UserRole.courier
            : roleStr == 'ADMIN'
                ? UserRole.admin
                : UserRole.buyer;

    return User(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ??
          m['buyerProfile']?['name']?.toString() ??
          '—',
      phone: m['phone']?.toString() ?? '',
      role: role,
      avatarUrl: m['buyerProfile']?['avatarUrl']?.toString(),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('401') || raw.contains('Unauthorized')) {
      return 'Неверный телефон или пароль';
    }
    if (raw.contains('400') || raw.contains('Bad Request')) {
      return 'Проверьте правильность введённых данных';
    }
    if (raw.contains('SocketException') || raw.contains('Connection')) {
      return 'Нет подключения к серверу';
    }
    return 'Ошибка: $raw';
  }
}

// ===================== PROVIDERS =====================

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
