import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/admin_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Управление пользователями', style: AppTextStyles.headlineS),
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GogoTextField(
              label: '',
              controller: _searchCtrl,
              hint: 'Поиск по имени или телефону...',
              prefixIcon: Icon(Icons.search_rounded),
              onChanged: (v) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.recentUsers.length,
                    itemBuilder: (context, i) {
                      final u = state.recentUsers[i];
                      if (_searchCtrl.text.isNotEmpty &&
                          !(u.name?.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ?? false) &&
                          !u.phone.contains(_searchCtrl.text)) {
                        return const SizedBox.shrink();
                      }

                      return _UserCard(user: u);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final User user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: user.isBlocked ? Border.all(color: AppColors.error.withOpacity(0.5)) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GogoAvatar(name: user.name ?? 'U', size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name ?? 'Без имени', style: AppTextStyles.labelL),
                    Text(user.phone, style: AppTextStyles.bodyM),
                  ],
                ),
              ),
              _RoleBadge(role: user.role),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                    ref.read(adminProvider.notifier).blockUser(user.id, !user.isBlocked);
                },
                icon: Icon(
                  user.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                  size: 18,
                  color: user.isBlocked ? AppColors.success : AppColors.error,
                ),
                label: Text(
                  user.isBlocked ? 'Разблокировать' : 'Заблокировать',
                  style: TextStyle(color: user.isBlocked ? AppColors.success : AppColors.error),
                ),
              ),
              const SizedBox(width: 8),
              GogoButton(
                label: 'Изменить роль',
                size: GogoButtonSize.small,
                variant: GogoButtonVariant.secondary,
                onPressed: () {
                   _showRolePicker(context, ref);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRolePicker(BuildContext context, WidgetRef ref) {
      showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.bgSurface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text('Выберите роль', style: AppTextStyles.headlineS),
                      const SizedBox(height: 16),
                      ...UserRole.values.map((r) => ListTile(
                          title: Text(_getRoleLabel(r)),
                          leading: Radio<UserRole>(
                              value: r,
                              groupValue: user.role,
                              activeColor: AppColors.accent,
                              onChanged: (val) {
                                  if (val != null) {
                                      ref.read(adminProvider.notifier).updateRole(user.id, val);
                                  }
                                  Navigator.pop(context);
                              },
                          ),
                          onTap: () {
                              Navigator.pop(context);
                          },
                      )),
                  ],
              ),
          ),
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
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    String label = '';
    Color color = Colors.grey;
    OrderStatus status = OrderStatus.pending;

    switch (role) {
      case UserRole.seller:
        label = 'Продавец';
        color = AppColors.primary;
        status = OrderStatus.pending;
        break;
      case UserRole.buyer:
        label = 'Покупатель';
        color = AppColors.success;
        status = OrderStatus.delivered;
        break;
      case UserRole.courier:
        label = 'Курьер';
        color = AppColors.info;
        status = OrderStatus.delivering;
        break;
      case UserRole.admin:
        label = 'Админ';
        color = AppColors.accent;
        status = OrderStatus.confirmed;
        break;
    }

    return GogoBadge(
      label: label,
      orderStatus: status,
    );
  }
}
