import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/presentation/screens/product_catalog_screen.dart';
import '../../cart/presentation/screens/cart_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../stories/presentation/screens/reels_feed_screen.dart';

class _ReelsTab extends StatelessWidget {
  const _ReelsTab();

  @override
  Widget build(BuildContext context) {
    return const ReelsFeedScreen();
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Tab'));
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProductCatalogScreen(),
    _ReelsTab(),
    CartScreen(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
