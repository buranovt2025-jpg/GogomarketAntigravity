import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Дашборд', style: AppTextStyles.headlineM),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _InitialsAvatar('Продавец'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Stats Row ===
            _StatsGrid(),
            const SizedBox(height: 24),
            Text('Быстрые действия', style: AppTextStyles.headlineM),
            const SizedBox(height: 12),
            _QuickActions(onTap: (route) => context.go(route)),
            const SizedBox(height: 24),
            Text('Последние заказы', style: AppTextStyles.headlineM),
            const SizedBox(height: 12),
            _RecentOrders(),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Товаров', 'value': '48', 'icon': Icons.inventory_2_rounded, 'color': AppColors.primary},
      {'label': 'Заказов', 'value': '124', 'icon': Icons.shopping_bag_rounded, 'color': AppColors.accent},
      {'label': 'Продажи', 'value': '12.4M', 'icon': Icons.trending_up_rounded, 'color': AppColors.success},
      {'label': 'Рейтинг', 'value': '4.8★', 'icon': Icons.star_rounded, 'color': const Color(0xFFF39C12)},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
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
                      style: AppTextStyles.headlineL.copyWith(color: color)),
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

class _QuickActions extends StatelessWidget {
  final void Function(String) onTap;
  const _QuickActions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'label': 'Товары', 'icon': Icons.inventory_rounded, 'route': '/products'},
      {'label': 'Заказы', 'icon': Icons.receipt_long_rounded, 'route': '/orders'},
    ];
    return Row(
      children: actions.map((a) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onTap(a['route'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(a['icon'] as IconData, color: Colors.white, size: 28),
                  const SizedBox(height: 6),
                  Text(a['label'] as String, style: AppTextStyles.labelM),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _RecentOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': '#1042', 'buyer': 'Алишер К.', 'amount': '299 000', 'status': OrderStatus.delivering},
      {'id': '#1041', 'buyer': 'Малика У.', 'amount': '649 000', 'status': OrderStatus.confirmed},
      {'id': '#1040', 'buyer': 'Руслан М.', 'amount': '199 000', 'status': OrderStatus.delivered},
    ];
    return Column(
      children: orders.map((o) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(o['id'] as String,
                style: AppTextStyles.labelL.copyWith(color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(o['buyer'] as String, style: AppTextStyles.bodyM),
            ),
            Text('${o['amount']} сум', style: AppTextStyles.labelM),
            const SizedBox(width: 8),
            GogoBadge(
              label: '',
              orderStatus: o['status'] as OrderStatus,
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar(this.name);

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((w) => w[0].toUpperCase()).join();
    return Container(
      width: 36, height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: AppTextStyles.labelM.copyWith(fontSize: 13)),
    );
  }
}
