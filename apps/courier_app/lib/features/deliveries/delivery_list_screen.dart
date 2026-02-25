import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/deliveries_provider.dart';

class DeliveryListScreen extends ConsumerWidget {
  const DeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Доставки', style: AppTextStyles.headlineM),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(deliveriesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading && state.availableOrders.isEmpty && state.myDeliveries.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveriesProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.myDeliveries.isNotEmpty) ...[
                    _SectionHeader(title: 'Мои активные доставки'),
                    ...state.myDeliveries.map((order) => _ActiveOrderCard(order: order)),
                    const SizedBox(height: 24),
                  ],
                  if (state.availableOrders.isNotEmpty) ...[
                    _SectionHeader(title: 'Доступные заказы'),
                    ...state.availableOrders.map((order) => _AvailableOrderCard(order: order)),
                  ],
                  if (state.availableOrders.isEmpty && state.myDeliveries.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text('Нет доступных заказов', style: AppTextStyles.bodyM),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: AppTextStyles.labelL.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _ActiveOrderCard extends ConsumerWidget {
  final CourierOrder order;
  const _ActiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.bgCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.title, style: AppTextStyles.headlineS),
                Text('${order.price.toInt()} сум', style: AppTextStyles.priceM),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.address, style: AppTextStyles.bodyM),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GogoButton(
                    label: 'Завершить',
                    onPressed: () => ref.read(deliveriesProvider.notifier).completeOrder(order.id),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                  onPressed: () {
                    // Navigate to map
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableOrderCard extends ConsumerWidget {
  final CourierOrder order;
  const _AvailableOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.bgCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.title, style: AppTextStyles.headlineS),
                Text('${order.price.toInt()} сум', style: AppTextStyles.priceM),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.address, style: AppTextStyles.bodyM),
            const SizedBox(height: 16),
            GogoButton(
              label: 'Взять заказ',
              fullWidth: true,
              size: GogoButtonSize.medium,
              onPressed: () => ref.read(deliveriesProvider.notifier).acceptOrder(order.id),
            ),
          ],
        ),
      ),
    );
  }
}
