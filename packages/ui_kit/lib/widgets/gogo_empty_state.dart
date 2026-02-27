import 'package:flutter/material.dart';
import 'package:core/core.dart';

class GogoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const GogoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, size: 64, color: AppColors.textHint),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headlineM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyM,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 32),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
