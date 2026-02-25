import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Модерация контента', style: AppTextStyles.headlineS),
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Товары (12)'),
                Tab(text: 'Stories (5)'),
              ],
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textHint,
              indicatorColor: AppColors.accent,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ProductsQueue(),
                  _StoriesQueue(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, i) => _ModerationItem(
        title: 'iPhone 15 Pro Max 256GB',
        subtitle: 'Продавец: Apple Store',
        imageUrl: 'https://via.placeholder.com/150',
        onApprove: () {},
        onReject: () {},
      ),
    );
  }
}

class _StoriesQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, i) => _ModerationItem(
        title: 'Акция: Скидки до 50%',
        subtitle: 'Продавец: Korzinka.uz',
        imageUrl: 'https://via.placeholder.com/150',
        onApprove: () {},
        onReject: () {},
      ),
    );
  }
}

class _ModerationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ModerationItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelL, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: AppTextStyles.bodyM, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.error),
                onPressed: onReject,
              ),
              IconButton(
                icon: const Icon(Icons.check_rounded, color: AppColors.success),
                onPressed: onApprove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
