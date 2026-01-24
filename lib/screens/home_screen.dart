import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'category_products_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'users_screen.dart';

import 'package:first_app_flutter/viewmodels/product.dart';
import 'package:first_app_flutter/viewmodels/category.dart';
import 'package:first_app_flutter/models/category.dart';
import 'package:first_app_flutter/models/product.dart';

import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String _searchQuery = '';
  int? _selectedCategoryId;

  final List<String> banners = [
    'assets/images/bannerno1.jpg',
    'assets/images/bannerno2.jpg',
    'assets/images/maskara.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Fetch proizvoda i kategorija u post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductViewModel>(context, listen: false).fetchProducts();
      Provider.of<CategoryViewModel>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _categoryButton(Category category) {
    final bool isSelected = _selectedCategoryId == category.id;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selectedCategoryId = category.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryProductsScreen(
                categoryId: category.id,
                categoryName: category.name,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFFD87F7F)
              : const Color(0xFFD8B4B4),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(category.name, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _recommendedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              isAdmin: true,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFD87F7F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    product.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${product.price.toStringAsFixed(2)} RSD',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _banner(String imagePath, {Product? product, String? badgeText}) {
    return GestureDetector(
      onTap: () {
        if (product != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product, isAdmin: true),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            if (badgeText != null)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) =>
                      Transform.scale(scale: _scaleAnimation.value, child: child),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                        color: Color(0xFFD87F7F), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = context.watch<UserProvider>().isGuest;
    final productVM = Provider.of<ProductViewModel>(context);
    final categoryVM = Provider.of<CategoryViewModel>(context);

    final List<Category> categories = categoryVM.categories.value;
    final List<Product> products = productVM.products;
    final List<Product> popularProducts =
    products.where((p) => p.popular).toList();

    final searchResults = _searchQuery.isEmpty
        ? []
        : products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Lista ekrana za bottom nav sa pravim ekranima
    final List<Widget> _screens = [
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            /// LOGO
            Image.asset(
              'assets/images/adora.jpg',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 15),
            /// PRETRAGA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Pretraži proizvode...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_searchQuery.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ValueListenableBuilder<List<Category>>(
                  valueListenable: categoryVM.categories,
                  builder: (context, categories, _) {
                    if (categories.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nema kategorija.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: categories
                            .map((c) => _categoryButton(c))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PageView(
                  controller: _pageController,
                  children: [
                    _banner(banners[0],
                        product: products.isNotEmpty ? products[0] : null,
                        badgeText: '50% OFF'),
                    _banner(banners[1],
                        product: products.length > 1 ? products[1] : null),
                    _banner(banners[2], badgeText: 'NOVO'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: banners.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFFD87F7F),
                    dotColor: Color(0xFFBFA1A1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Izdvajamo za vas',
                  style: TextStyle(
                      fontFamily: 'Spinnaker',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD87F7F)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: popularProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) =>
                      _recommendedProductCard(popularProducts[index]),
                ),
              ),
            ],
          ],
        ),
      ),
      const OrdersScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      body: _screens[_currentIndex],
      bottomNavigationBar: isGuest
          ? null
          : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: const Color(0xFFD87F7F),
        unselectedItemColor: const Color(0xFFBFA1A1),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Porudžbine'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Korpa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
