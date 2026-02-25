import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'api_client_provider.dart';

class AdminStats {
  final int totalOrders;
  final double totalRevenue;
  final double totalCommission;
  final int activeOrders;
  final int totalUsers;

  AdminStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCommission,
    required this.activeOrders,
    required this.totalUsers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalCommission: (json['totalCommission'] ?? 0).toDouble(),
      activeOrders: json['activeOrders'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
    );
  }
}

class AdminState {
  final AdminStats? stats;
  final List<User> recentUsers;
  final bool isLoading;
  final String? error;

  AdminState({
    this.stats,
    this.recentUsers = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    AdminStats? stats,
    List<User>? recentUsers,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      recentUsers: recentUsers ?? this.recentUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final Ref _ref;

  AdminNotifier(this._ref) : super(AdminState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = _ref.read(apiClientProvider);
      
      // Fetch stats
      final statsRes = await api.dio.get('/admin/stats');
      final stats = AdminStats.fromJson(statsRes.data);
      
      // Fetch recent users
      final usersRes = await api.dio.get('/admin/users', queryParameters: {'limit': 5});
      final usersList = (usersRes.data[0] as List).map((e) => User.fromJson(e)).toList();
      
      state = state.copyWith(
        stats: stats,
        recentUsers: usersList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> blockUser(String userId, bool isBlocked) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.dio.patch('/admin/users/$userId/block', data: {'isBlocked': isBlocked});
      await refresh();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update user status: $e');
    }
  }

  Future<void> updateRole(String userId, UserRole role) async {
    try {
      final api = _ref.read(apiClientProvider);
      await api.dio.patch('/admin/users/$userId/role', data: {'role': role.toString().split('.').last});
      await refresh();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update user role: $e');
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref);
});
