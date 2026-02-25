import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

final _mockOrders = [
  {'id': '#1042', 'buyer': 'Алишер Каримов', 'items': 2, 'total': 598000.0, 'status': OrderStatus.delivering},
  {'id': '#1041', 'buyer': 'Малика Усманова', 'items': 1, 'total': 649000.0, 'status': OrderStatus.confirmed},
  {'id': '#1040', 'buyer': 'Руслан Маматов', 'items': 3, 'total': 897000.0, 'status': OrderStatus.delivered},
  {'id': '#1039', 'buyer': 'Зулайхо Рашидова', 'items': 1, 'total': 299000.0, 'status': OrderStatus.pending},
  {'id': '#1038', 'buyer': 'Ботир Эшматов', 'items': 2, 'total': 450000.0, 'status': OrderStatus.cancelled},
];

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Заказы', style: AppTextStyles.headlineM),
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _mockOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final o = _mockOrders[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o['id'] as String,
                        style: AppTextStyles.labelL
                            .copyWith(color: AppColors.primary)),
                    GogoBadge(
                      label: '',
                      orderStatus: o['status'] as OrderStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 16, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Text(o['buyer'] as String, style: AppTextStyles.bodyM),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 16, color: AppColors.textHint),
                        const SizedBox(width: 6),
                        Text('${o['items']} товара(ов)',
                            style: AppTextStyles.bodyM),
                      ],
                    ),
                    Text(
                      '${_fmt(o['total'] as double)} сум',
                      style: AppTextStyles.priceM,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0).split('');
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return b.toString();
  }
}
