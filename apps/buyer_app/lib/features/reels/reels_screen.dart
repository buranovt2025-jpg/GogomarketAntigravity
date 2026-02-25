import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

// Mock reels data
final _mockReels = [
  {
    'id': 'r1',
    'seller': 'NikeUz',
    'title': 'Новая коллекция Air Max 2024 🔥',
    'likes': 2341,
    'comments': 128,
    'color': const Color(0xFF1A1A2E),
    'emoji': '👟',
  },
  {
    'id': 'r2',
    'seller': 'TechStore',
    'title': 'Samsung S24 Ultra — обзор 📱',
    'likes': 5102,
    'comments': 312,
    'color': const Color(0xFF0D0D1F),
    'emoji': '📱',
  },
  {
    'id': 'r3',
    'seller': 'FashionHub',
    'title': 'Весенняя коллекция 2024 🌸',
    'likes': 1890,
    'comments': 95,
    'color': const Color(0xFF1F0D1A),
    'emoji': '👗',
  },
  {
    'id': 'r4',
    'seller': 'SoundPro',
    'title': 'Sony WH-1000XM5 — лучшие наушники 🎧',
    'likes': 3450,
    'comments': 201,
    'color': const Color(0xFF0D1F1A),
    'emoji': '🎧',
  },
];

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  final Set<String> _liked = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Рилсы', style: AppTextStyles.headlineM),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemCount: _mockReels.length,
        itemBuilder: (context, i) => _ReelItem(
          data: _mockReels[i],
          isLiked: _liked.contains(_mockReels[i]['id'] as String),
          onLike: () {
            setState(() {
              final id = _mockReels[i]['id'] as String;
              if (_liked.contains(id)) {
                _liked.remove(id);
              } else {
                _liked.add(id);
              }
            });
          },
        ),
      ),
    );
  }
}

class _ReelItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLiked;
  final VoidCallback onLike;

  const _ReelItem({
    required this.data,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final likes = (data['likes'] as int) + (isLiked ? 1 : 0);

    return Container(
      color: data['color'] as Color,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          // Emoji placeholder (вместо реального видео)
          Center(
            child: Text(
              data['emoji'] as String,
              style: const TextStyle(fontSize: 120),
            ),
          ),
          // Bottom info
          Positioned(
            left: 16,
            right: 80,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GogoAvatar(
                      name: data['seller'] as String,
                      size: 36,
                      showBorder: true,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      data['seller'] as String,
                      style: AppTextStyles.labelL,
                    ),
                    const SizedBox(width: 8),
                    _FollowButton(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data['title'] as String,
                  style: AppTextStyles.bodyL,
                ),
              ],
            ),
          ),
          // Right actions
          Positioned(
            right: 12,
            bottom: 80,
            child: Column(
              children: [
                _ActionButton(
                  icon: isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isLiked ? AppColors.accent : Colors.white,
                  label: _formatNum(likes),
                  onTap: onLike,
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: _formatNum(data['comments'] as int),
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Поделиться',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Купить',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelS),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Подписаться', style: AppTextStyles.labelS),
    );
  }
}

// ignore: must_be_immutable
class GogoAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool showBorder;

  const GogoAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        border: showBorder
            ? Border.all(color: Colors.white, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
