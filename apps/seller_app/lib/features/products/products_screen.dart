import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../providers/seller_products_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Мои товары', style: AppTextStyles.headlineM),
        leading: BackButton(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Добавить', style: AppTextStyles.labelM),
      ),
      body: state.isLoading && state.products.isEmpty
          ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => const GogoShimmerCard(height: 84),
            )
          : state.products.isEmpty
              ? _emptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = state.products[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Image placeholder
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: AppTextStyles.labelL),
                      const SizedBox(height: 4),
                      Text(p.category, style: AppTextStyles.bodyM),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${_fmt(p.price)} сум',
                              style: AppTextStyles.priceM),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.stock > 0
                                  ? AppColors.success.withOpacity(0.15)
                                  : AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.stock > 0 ? 'В наличии: ${p.stock}' : 'Нет',
                              style: AppTextStyles.labelS.copyWith(
                                color: p.stock > 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textHint, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return const GogoEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'У вас пока нет товаров',
      subtitle: 'Нажмите "Добавить" чтобы создать товар',
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
