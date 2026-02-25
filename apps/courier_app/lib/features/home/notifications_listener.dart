import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import '../providers/socket_service_provider.dart';

class NotificationsListener extends ConsumerWidget {
  final Widget child;

  const NotificationsListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationStreamProvider, (previous, next) {
      if (next.hasValue) {
        final data = next.value!;
        _showNotification(context, data);
      }
    });

    return child;
  }

  void _showNotification(BuildContext context, Map<String, dynamic> data) {
    final message = data['message'] ?? 'Новое задание';
    final type = data['type'] ?? 'info';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              type == 'new-order' ? Icons.local_shipping_rounded : Icons.notifications_active_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyM.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
