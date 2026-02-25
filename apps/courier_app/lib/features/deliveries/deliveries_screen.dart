import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

final _mockDeliveries = [
  {
    'id': '#1042',
    'address': 'Ташкент, ул. Амира Темура 15',
    'buyer': 'Алишер К.',
    'phone': '+998 90 123 45 67',
    'status': OrderStatus.delivering,
    'distance': '2.4 км',
  },
  {
    'id': '#1039',
    'address': 'Ташкент, Юнусабад 12-квартал',
    'buyer': 'Зулайхо Р.',
    'phone': '+998 91 555 22 33',
    'status': OrderStatus.confirmed,
    'distance': '5.1 км',
  },
  {
    'id': '#1035',
    'address': 'Ташкент, Чиланзар М 11',
    'buyer': 'Бахром Д.',
    'phone': '+998 99 888 11 22',
    'status': OrderStatus.packed,
    'distance': '3.8 км',
  },
];

class DeliveriesScreen extends ConsumerWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Мои доставки', style: AppTextStyles.headlineM),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text('Онлайн', style: AppTextStyles.labelM
                    .copyWith(color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('Сегодня', '5'),
                _Stat('Выполнено', '3'),
                _Stat('Рейтинг', '4.9★'),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockDeliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final d = _mockDeliveries[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: d['status'] == OrderStatus.delivering
                          ? AppColors.info.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(d['id'] as String,
                              style: AppTextStyles.labelL
                                  .copyWith(color: AppColors.info)),
                          GogoBadge(
                            label: '',
                            orderStatus: d['status'] as OrderStatus,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.accent, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(d['address'] as String,
                                style: AppTextStyles.bodyM),
                          ),
                          Text(d['distance'] as String,
                              style: AppTextStyles.labelM
                                  .copyWith(color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              color: AppColors.textHint, size: 16),
                          const SizedBox(width: 6),
                          Text(d['buyer'] as String, style: AppTextStyles.bodyM),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              final buyerId = 'mock_buyer_id_${d['id']}';
                              final buyerName = d['buyer'] as String;
                              context.push('/chat/$buyerId?name=$buyerName');
                            },
                            child: const Icon(Icons.chat_bubble_outline_rounded,
                                color: AppColors.info, size: 20),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.phone_rounded,
                                color: AppColors.success, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineM),
        Text(label, style: AppTextStyles.bodyM),
      ],
    );
  }
}
