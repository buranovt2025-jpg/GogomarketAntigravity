import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

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
  SellerAuthNotifier() : super(const SellerAuthState());

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final user = User(
        id: 's1',
        name: 'Продавец',
        phone: phone,
        role: UserRole.seller,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void logout() => state = const SellerAuthState();
}

final sellerAuthProvider =
    StateNotifierProvider<SellerAuthNotifier, SellerAuthState>(
  (ref) => SellerAuthNotifier(),
);
