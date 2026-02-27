import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/cart_provider.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgDark,
            expandedHeight: 400,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${product.id}',
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: AppTextStyles.headlineL,
                        ),
                      ),
                      if (product.rating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFF39C12), size: 18),
                              const SizedBox(width: 4),
                              Text(product.rating.toStringAsFixed(1), style: AppTextStyles.labelM),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_formatPrice(product.price)} сум',
                    style: AppTextStyles.priceL.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  if (product.description != null && product.description!.isNotEmpty) ...[
                    Text('Описание', style: AppTextStyles.headlineS),
                    const SizedBox(height: 8),
                    Text(product.description!, style: AppTextStyles.bodyM),
                    const SizedBox(height: 32),
                  ],
                  Row(
                    children: [
                      GogoAvatar(name: product.sellerName ?? 'Продавец', size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.sellerName ?? 'Магазин', style: AppTextStyles.labelL),
                            Text('Перейти в чат', style: AppTextStyles.bodyS.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.push('/chat/${product.sellerId}?name=${product.sellerName ?? "Продавец"}');
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GogoButton(
          label: 'Добавить в корзину',
          size: GogoButtonSize.large,
          icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 24),
          onPressed: () {
            ref.read(cartProvider.notifier).addProduct(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.title} добавлен', style: AppTextStyles.labelM),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      color: AppColors.bgOverlay,
      child: const Icon(Icons.image_outlined, color: AppColors.textHint, size: 64),
    );
  }

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }
}
