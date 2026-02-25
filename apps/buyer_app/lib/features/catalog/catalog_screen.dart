import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

// Mock products
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

final _categories = ['Все', 'Одежда', 'Электроника', 'Обувь', 'Декор'];

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  int _selectedCategory = 0;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _mockProducts.length,
              itemBuilder: (context, i) => GogoProductCard(
                product: _mockProducts[i],
                onAddToCart: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${_mockProducts[i].title} добавлен в корзину'),
                      backgroundColor: AppColors.bgSurface,
                      behavior: SnackBarBehavior.floating,
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
