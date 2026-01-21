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

import '../providers/user_provider.dart'; // ← import UserProvider

// --- Stubovi da ne baca Lookup failed ---
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Orders Screen')));
}
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Cart Screen')));
}
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Users Screen')));
}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile Screen')));
}
// -----------------------

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

  Widget _categoryButton({required int id, required String title}) {
    final bool isSelected = _selectedCategoryId == id;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selectedCategoryId = id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryProductsScreen(
                categoryId: id,
                categoryName: title,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isSelected ? const Color(0xFFD87F7F) : const Color(0xFFD8B4B4),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(title, style: const TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    // ← Ovde čitamo status gosta iz Provider-a
    final bool isGuest = context.watch<UserProvider>().isGuest;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const OrdersScreen(),
          const CartScreen(),
          const UsersScreen(),
          const ProfileScreen(),
        ],
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Korisnici'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final productVM = Provider.of<ProductViewModel>(context);
    final products = productVM.products;
    final popularProducts = products.where((p) => p.popular).toList();

    final bool isSearching = _searchQuery.trim().isNotEmpty;
    final searchResults = products
        .where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    Product? productWithId1;
    if (products.isNotEmpty) {
      try {
        productWithId1 = products.firstWhere((p) => p.id == 1);
      } catch (_) {
        productWithId1 = products[0];
      }
    }

    if (productVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Image.asset(
            'assets/images/adora.jpg',
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 15),
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
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
          if (isSearching)
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (_, i) => _recommendedProductCard(searchResults[i]),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PageView(
                controller: _pageController,
                children: [
                  _banner(banners[0],
                      product: productWithId1, badgeText: '50% OFF'),
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
            SizedBox(
              height: 50,
              child: Consumer<CategoryViewModel>(
                builder: (context, categoryVM, _) {
                  if (categoryVM.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: categoryVM.categories.value
                        .map((c) => _categoryButton(id: c.id, title: c.name))
                        .toList(),
                  );
                },
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
                  color: Color(0xFFD87F7F),
                ),
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
    );
  }

  Widget _banner(String imagePath, {Product? product, String? badgeText}) {
    return GestureDetector(
      onTap: () {
        if (product != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    ProductDetailScreen(product: product, isAdmin: true)),
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
}
