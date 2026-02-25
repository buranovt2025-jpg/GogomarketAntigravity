import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Платформа', style: AppTextStyles.headlineM),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(adminProvider.notifier).refresh(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: state.isLoading && state.stats == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : RefreshIndicator(
              onRefresh: () => ref.read(adminProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.error != null)
                      _ErrorBanner(message: state.error!),
                    
                    Text('Статистика платформы', style: AppTextStyles.headlineM),
                    const SizedBox(height: 12),
                    _PlatformStats(stats: state.stats),
                    const SizedBox(height: 24),
                    
                    Text('Управление', style: AppTextStyles.headlineM),
                    const SizedBox(height: 12),
                    _AdminActions(),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Новые пользователи', style: AppTextStyles.headlineM),
                        TextButton(
                          onPressed: () {
                            context.push('/users');
                          },
                          child: Text('Все', style: TextStyle(color: AppColors.accent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _RecentUsers(users: state.recentUsers),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTextStyles.bodyM.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _PlatformStats extends StatelessWidget {
  final AdminStats? stats;
  const _PlatformStats({this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'label': 'Пользователей',
        'value': _fmt(stats?.totalUsers ?? 0),
        'icon': Icons.people_rounded,
        'color': AppColors.accent
      },
      {
        'label': 'Заказов',
        'value': _fmt(stats?.totalOrders ?? 0),
        'icon': Icons.receipt_long_rounded,
        'color': AppColors.success
      },
      {
        'label': 'Оборот (сум)',
        'value': _fmtCurrency(stats?.totalRevenue ?? 0),
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFFF39C12)
      },
      {
        'label': 'Комиссия (сум)',
        'value': _fmtCurrency(stats?.totalCommission ?? 0),
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppColors.primary
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final s = items[i];
        final color = s['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(s['icon'] as IconData, color: color, size: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['value'] as String,
                      style: AppTextStyles.headlineS.copyWith(color: color, fontSize: 18)),
                  Text(s['label'] as String, style: AppTextStyles.bodyS.copyWith(fontSize: 12, color: AppColors.textHint)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  String _fmtCurrency(double v) {
    if (v >= 1000000000) return '${(v / 1000000000).toStringAsFixed(1)}B';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _AdminActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'Пользователи', 'icon': Icons.people_outline_rounded, 'route': '/users'},
      {'label': 'Продавцы', 'icon': Icons.store_outlined, 'route': '/users'},
      {'label': 'Контент', 'icon': Icons.video_library_outlined, 'route': '/moderation'},
      {'label': 'Настройки', 'icon': Icons.settings_outlined, 'route': null},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () {
            if (a['route'] != null) {
              context.push(a['route'] as String);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(a['icon'] as IconData,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(a['label'] as String, style: AppTextStyles.labelM)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentUsers extends StatelessWidget {
  final List<User> users;
  const _RecentUsers({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text('Нет новых пользователей', style: AppTextStyles.bodyM),
      ));
    }
    return Column(
      children: users.map((u) {
        final roleLabel = _getRoleLabel(u.role);
        final roleColor = _getRoleColor(u.role);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: u.isBlocked ? Border.all(color: AppColors.error.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              GogoAvatar(name: u.name ?? 'U', size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name ?? 'Без имени', style: AppTextStyles.labelL),
                    Text(u.phone, style: AppTextStyles.bodyM),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   GogoBadge(
                    label: roleLabel,
                    orderStatus: _mapRoleToStatus(u.role),
                  ),
                  if (u.isBlocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('Заблокирован', style: AppTextStyles.bodyS.copyWith(color: AppColors.error, fontSize: 10)),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.seller: return 'Продавец';
      case UserRole.buyer: return 'Покупатель';
      case UserRole.courier: return 'Курьер';
      case UserRole.admin: return 'Админ';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.seller: return AppColors.primary;
      case UserRole.buyer: return AppColors.success;
      case UserRole.courier: return AppColors.info;
      case UserRole.admin: return AppColors.accent;
    }
  }
  
  OrderStatus _mapRoleToStatus(UserRole role) {
    switch (role) {
      case UserRole.seller: return OrderStatus.pending;
      case UserRole.buyer: return OrderStatus.delivered;
      case UserRole.courier: return OrderStatus.delivering;
      case UserRole.admin: return OrderStatus.confirmed;
    }
  }
}
