import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Платформа', style: AppTextStyles.headlineM),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36, height: 36,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform stats
            Text('Статистика платформы', style: AppTextStyles.headlineM),
            const SizedBox(height: 12),
            _PlatformStats(),
            const SizedBox(height: 24),
            // Quick actions
            Text('Управление', style: AppTextStyles.headlineM),
            const SizedBox(height: 12),
            _AdminActions(),
            const SizedBox(height: 24),
            // Recent users
            Text('Новые пользователи', style: AppTextStyles.headlineM),
            const SizedBox(height: 12),
            _RecentUsers(),
          ],
        ),
      ),
    );
  }
}

class _PlatformStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Пользователей', 'value': '12,481', 'icon': Icons.people_rounded, 'color': AppColors.accent},
      {'label': 'Продавцов', 'value': '1,234', 'icon': Icons.store_rounded, 'color': AppColors.primary},
      {'label': 'Заказов', 'value': '45,803', 'icon': Icons.receipt_long_rounded, 'color': AppColors.success},
      {'label': 'Доходов', 'value': '2.1 млрд', 'icon': Icons.trending_up_rounded, 'color': const Color(0xFFF39C12)},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final s = stats[i];
        final color = s['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(s['icon'] as IconData, color: color, size: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['value'] as String,
                      style: AppTextStyles.headlineM.copyWith(color: color)),
                  Text(s['label'] as String, style: AppTextStyles.bodyM),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'Пользователи', 'icon': Icons.people_outline_rounded},
      {'label': 'Продавцы', 'icon': Icons.store_outlined},
      {'label': 'Контент', 'icon': Icons.video_library_outlined},
      {'label': 'Платежи', 'icon': Icons.payments_outlined},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(a['icon'] as IconData,
                    color: AppColors.accent, size: 22),
                const SizedBox(width: 10),
                Text(a['label'] as String, style: AppTextStyles.labelM),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = [
      {'name': 'Алина Назарова', 'role': 'seller', 'phone': '+998 90 111 22 33'},
      {'name': 'Камола Юсупова', 'role': 'buyer', 'phone': '+998 91 444 55 66'},
      {'name': 'Темур Рахимов', 'role': 'courier', 'phone': '+998 99 777 88 99'},
    ];
    return Column(
      children: users.map((u) {
        final role = u['role'] as String;
        final roleLabel = {'seller': 'Продавец', 'buyer': 'Покупатель', 'courier': 'Курьер'}[role]!;
        final roleColor = {'seller': AppColors.primary, 'buyer': AppColors.success, 'courier': AppColors.info}[role]!;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                alignment: Alignment.center,
                child: Text(
                  (u['name'] as String)[0],
                  style: AppTextStyles.labelL,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u['name'] as String, style: AppTextStyles.labelL),
                    Text(u['phone'] as String, style: AppTextStyles.bodyM),
                  ],
                ),
              ),
              GogoBadge(
                label: roleLabel,
                color: roleColor,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
