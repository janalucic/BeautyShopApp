import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'product_detail_screen.dart';
import 'search_results_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> banners = [
    'assets/images/bannerno1.jpg',
    'assets/images/bannerno2.jpg',
    'assets/images/maskara.jpg',
  ];

  final List<String> categories = [
    'Šamponi',
    'Losioni',
    'Maske za kosu',
    'Serumi',
    'Gelovi',
    'Boje za kosu',
  ];

  /// MOCK proizvodi
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Proizvod 1',
      'image': 'assets/images/cherry2.png',
      'price': 1000.0,
      'description': 'Opis proizvoda 1',
      'popular': true,
    },
    {
      'name': 'Proizvod 2',
      'image': 'assets/images/cherry2.png',
      'price': 1500.0,
      'description': 'Opis proizvoda 2',
      'popular': true,
    },
    {
      'name': 'Proizvod 3',
      'image': 'assets/images/cherry2.png',
      'price': 2000.0,
      'description': 'Opis proizvoda 3',
      'popular': false,
    },
    {
      'name': 'Proizvod 4',
      'image': 'assets/images/cherry2.png',
      'price': 1200.0,
      'description': 'Opis proizvoda 4',
      'popular': true,
    },
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // =================== WIDGETI ===================

  Widget _recommendedProductCard(Map<String, dynamic> product) {
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
                color: const Color(0xFFD87F7F).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    product['image'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${product['price'].toStringAsFixed(2)} RSD',
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

  Widget _categoryButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD8B4B4),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _banner(String imagePath, {String? badgeText}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: badgeText == null
          ? null
          : Positioned(
        top: 12,
        right: 12,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFD87F7F),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                badgeText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =================== BUILD ===================

  @override
  Widget build(BuildContext context) {
    final popularProducts =
    products.where((p) => p['popular'] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      body: SingleChildScrollView(
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

            const SizedBox(height: 20),

            /// PRETRAGA → VODI NA SEARCH RESULTS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (query) {
                  if (query.trim().isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchResultsScreen(
                        query: query,
                        products: products,
                      ),
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Pretraži proizvode...',
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFFD87F7F)),
                  filled: true,
                  fillColor: const Color(0xFFE3CFCF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// KATEGORIJE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map(_categoryButton).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// BANNERI
            SizedBox(
              height: 200,
              child: PageView(
                controller: _pageController,
                children: [
                  _banner(banners[0], badgeText: '50% OFF'),
                  _banner(banners[1]),
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

            /// POPULARNO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Izdvajamo za Vas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD87F7F),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children:
                popularProducts.map(_recommendedProductCard).toList(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UsersScreen()));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        selectedItemColor: const Color(0xFFD87F7F),
        unselectedItemColor: const Color(0xFFBFA1A1),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Porudžbine'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Korpa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Korisnici'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
