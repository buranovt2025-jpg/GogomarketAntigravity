import 'package:flutter/material.dart';
import 'package:core/core.dart';

enum GogoBadgeType { category, orderStatus, custom }

class GogoBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final OrderStatus? orderStatus;

  const GogoBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.orderStatus,
  });

  /// Конструктор для статусов заказа
  const GogoBadge.orderStatus({
    super.key,
    required this.orderStatus,
  })  : label = '',
        color = null,
        textColor = null;

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? _statusColor ?? AppColors.bgOverlay;
    final fgColor = textColor ?? Colors.white;
    final displayLabel =
        label.isNotEmpty ? label : _statusLabel(orderStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        border: Border.all(color: bgColor.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayLabel,
        style: AppTextStyles.labelS.copyWith(color: fgColor),
      ),
    );
  }

  Color? get _statusColor => switch (orderStatus) {
        OrderStatus.pending => AppColors.statusPending,
        OrderStatus.confirmed => AppColors.info,
        OrderStatus.packed => AppColors.primary,
        OrderStatus.delivering => AppColors.statusDelivering,
        OrderStatus.delivered => AppColors.statusDelivered,
        OrderStatus.cancelled => AppColors.statusCancelled,
        null => null,
      };

  String _statusLabel(OrderStatus? status) => switch (status) {
        OrderStatus.pending => 'Ожидает',
        OrderStatus.confirmed => 'Подтверждён',
        OrderStatus.packed => 'Упакован',
        OrderStatus.delivering => 'Доставляется',
        OrderStatus.delivered => 'Доставлен',
        OrderStatus.cancelled => 'Отменён',
        null => '',
      };
}
