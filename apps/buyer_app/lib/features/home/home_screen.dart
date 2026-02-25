import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../catalog/catalog_screen.dart';
import '../reels/reels_screen.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ReelsScreen(),
    CatalogScreen(),
    CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: _buildDrawer(user),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(cartCount),
    );
  }

  Widget _buildBottomNav(int cartCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNav,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: AppTextStyles.labelS,
        unselectedLabelStyle: AppTextStyles.labelS,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            activeIcon: Icon(Icons.play_circle_filled_rounded),
            label: 'Рилсы',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store_rounded),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Корзина',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(User? user) {
    return Drawer(
      backgroundColor: AppColors.bgSurface,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            GogoAvatar(
              name: user?.name ?? 'Гость',
              size: 72,
              showBorder: true,
            ),
            const SizedBox(height: 14),
            Text(user?.name ?? 'Гость', style: AppTextStyles.headlineM),
            const SizedBox(height: 6),
            Text(user?.phone ?? '', style: AppTextStyles.bodyM),
            const SizedBox(height: 32),
            const Divider(color: AppColors.divider),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded,
                  color: AppColors.primary),
              title: Text('Мои заказы', style: AppTextStyles.bodyL),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border_rounded,
                  color: AppColors.primary),
              title: Text('Избранное', style: AppTextStyles.bodyL),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined,
                  color: AppColors.primary),
              title: Text('Настройки', style: AppTextStyles.bodyL),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('Выйти',
                  style: AppTextStyles.bodyL.copyWith(color: AppColors.error)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
