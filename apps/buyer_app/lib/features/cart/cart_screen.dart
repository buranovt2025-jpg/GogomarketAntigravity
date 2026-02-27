import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          'Корзина${cart.itemCount > 0 ? ' (${cart.itemCount})' : ''}',
          style: AppTextStyles.headlineM,
        ),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: Text(
                'Очистить',
                style: AppTextStyles.labelM.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cart.isEmpty ? _emptyState() : _cartList(context, ref, cart),
      bottomNavigationBar: cart.isEmpty ? null : _checkoutBar(context, ref, cart),
    );
  }

  Widget _emptyState() {
    return const GogoEmptyState(
      icon: Icons.remove_shopping_cart_outlined,
      title: 'Корзина пуста',
      subtitle: 'Добавьте товары из каталога',
    );
  }

  Widget _cartList(BuildContext context, WidgetRef ref, CartState cart) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = cart.items[i];
        return Dismissible(
          key: ValueKey(item.product.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) =>
              ref.read(cartProvider.notifier).removeProduct(item.product.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 28),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Image placeholder
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.shopping_bag_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                // Name + price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.title,
                          style: AppTextStyles.labelL,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        '${_fmt(item.product.price)} сум',
                        style: AppTextStyles.priceM,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Qty controls
                Row(
                  children: [
                    _QtyBtn(
                      icon: Icons.remove,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .decrementQuantity(item.product.id),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}',
                          style: AppTextStyles.headlineM),
                    ),
                    _QtyBtn(
                      icon: Icons.add,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .incrementQuantity(item.product.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _checkoutBar(BuildContext context, WidgetRef ref, CartState cart) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Итого (${cart.itemCount} шт.):',
                      style: AppTextStyles.bodyM),
                  Text('${_fmt(cart.total)} сум',
                      style: AppTextStyles.priceL),
                ],
              ),
              Consumer(
                builder: (context, ref, _) {
                  final orders = ref.watch(ordersProvider);
                  return GogoButton(
                    label: 'Оформить',
                    isLoading: orders.isPlacingOrder,
                    size: GogoButtonSize.medium,
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () async {
                      final ok = await ref
                          .read(ordersProvider.notifier)
                          .placeOrder();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? '🎉 Заказ #${ref.read(ordersProvider).lastOrderId ?? ''} оформлен!'
                                : ref.read(ordersProvider).error ?? 'Ошибка'),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ],
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

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.bgOverlay,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
