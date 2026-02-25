import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/cart_provider.dart';

// Mock products (в будущем заменить на FutureProvider + ApiClient)
final _categories = ['Все', 'Одежда', 'Электроника', 'Обувь', 'Декор'];

final _mockProducts = List.generate(
  12,
  (i) => Product(
    id: 'p$i',
    title: [
      'Nike Air Max 2024',
      'Samsung Galaxy S24',
      'Apple AirPods Pro',
      'Adidas Hoodie',
      'Sony Headphones',
      'Levi\'s 501 Jeans',
    ][i % 6],
    price: [299000, 1599000, 899000, 399000, 649000, 549000][i % 6].toDouble(),
    sellerId: 'seller1',
    category: ['Обувь', 'Электроника', 'Декор', 'Одежда'][i % 4],
    rating: 4.0 + (i % 5) * 0.2,
    reviewCount: 10 + i * 4,
    isFeatured: i % 5 == 0,
  ),
);

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  int _selectedCategory = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    var all = _mockProducts;
    if (_selectedCategory > 0) {
      all = all
          .where((p) => p.category == _categories[_selectedCategory])
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      all = all
          .where((p) => p.title.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Каталог', style: AppTextStyles.headlineM),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // === Search ===
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyL,
              decoration: InputDecoration(
                hintText: 'Поиск товаров...',
                hintStyle: AppTextStyles.bodyM,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textHint, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.bgCard,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // === Categories ===
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _selectedCategory == i
                          ? AppColors.primaryGradient
                          : null,
                      color: _selectedCategory == i
                          ? null
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _categories[i],
                      style: AppTextStyles.labelM.copyWith(
                        color: _selectedCategory == i
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // === Grid ===
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('Ничего не найдено', style: AppTextStyles.headlineM),
                        const SizedBox(height: 6),
                        Text('Попробуйте другой запрос',
                            style: AppTextStyles.bodyM),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) => GogoProductCard(
                      product: _filtered[i],
                      onAddToCart: () {
                        ref
                            .read(cartProvider.notifier)
                            .addProduct(_filtered[i]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_filtered[i].title} добавлен',
                                    style: AppTextStyles.labelM,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
