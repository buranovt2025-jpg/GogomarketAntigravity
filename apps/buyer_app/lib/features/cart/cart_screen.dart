import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  // Mock cart items
  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Nike Air Max 2024',
      'price': 299000.0,
      'qty': 1,
      'emoji': '👟',
    },
    {
      'name': 'Sony Headphones',
      'price': 649000.0,
      'qty': 2,
      'emoji': '🎧',
    },
  ];

  double get _total =>
      _items.fold(0, (s, e) => s + (e['price'] as double) * (e['qty'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Корзина', style: AppTextStyles.headlineM),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _items.clear()),
              child: Text(
                'Очистить',
                style: AppTextStyles.labelM.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: _items.isEmpty ? _emptyState() : _cartList(),
      bottomNavigationBar: _items.isEmpty ? null : _checkoutBar(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Корзина пуста', style: AppTextStyles.headlineM),
          const SizedBox(height: 8),
          Text('Добавьте товары из каталога', style: AppTextStyles.bodyM),
        ],
      ),
    );
  }

  Widget _cartList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = _items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Image area
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(item['emoji'] as String,
                    style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              // Name + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] as String,
                        style: AppTextStyles.labelL),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmt((item['price'] as double))} сум',
                      style: AppTextStyles.priceM,
                    ),
                  ],
                ),
              ),
              // Quantity controls
              Row(
                children: [
                  _CircleBtn(
                    icon: Icons.remove,
                    onTap: () {
                      setState(() {
                        if (item['qty'] > 1) {
                          item['qty']--;
                        } else {
                          _items.removeAt(i);
                        }
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item['qty']}', style: AppTextStyles.headlineM),
                  ),
                  _CircleBtn(
                    icon: Icons.add,
                    onTap: () => setState(() => item['qty']++),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _checkoutBar() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Text('Итого:', style: AppTextStyles.bodyL),
              Text('${_fmt(_total)} сум', style: AppTextStyles.priceL),
            ],
          ),
          const SizedBox(height: 16),
          GogoButton(
            label: 'Оформить заказ',
            fullWidth: true,
            icon: const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Заказ оформлен!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.bgOverlay,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
