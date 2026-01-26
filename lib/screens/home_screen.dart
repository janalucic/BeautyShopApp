import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'category_products_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';

import 'package:first_app_flutter/viewmodels/product.dart';
import 'package:first_app_flutter/viewmodels/category.dart';
import 'package:first_app_flutter/models/category.dart' as model;
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

    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProducts();
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ================= KATEGORIJE =================

  Widget _categoryButton(model.Category category) {
    return ElevatedButton(
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
        backgroundColor: const Color(0xFFD87F7F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(category.name, style: const TextStyle(color: Colors.white)),
    );
  }

  void _showEditCategoryDialog(
      model.Category category, CategoryViewModel vm) {
    final controller = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD87F7F),
        title:
        const Text('Izmeni kategoriju', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Novo ime kategorije',
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              await vm.updateCategoryName(category.id, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Sačuvaj',
                style: TextStyle(color: Color(0xFFD87F7F))),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(
      model.Category category, bool isAdmin, CategoryViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          _categoryButton(category),
          if (isAdmin) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _adminIcon(Icons.edit,
                        () => _showEditCategoryDialog(category, vm)),
                const SizedBox(width: 4),
                _adminIcon(Icons.delete, () {}),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _adminIcon(IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFD87F7F),
        padding: const EdgeInsets.all(8),
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  // ================= PROIZVODI =================

  Widget _recommendedProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(product: product, isAdmin: true),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD87F7F).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(product.imageUrl, height: 90),
            const SizedBox(height: 8),
            Text(product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text('${product.price} RSD',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<UserProvider>().isGuest;
    final isAdmin = context.watch<UserProvider>().isAdmin;

    final productVM = context.watch<ProductViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();

    final products = productVM.products;
    final popular = products.where((p) => p.popular).toList();

    final searchResults = _searchQuery.isEmpty
        ? <Product>[]
        : products
        .where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final screens = [
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            SizedBox(
              width: MediaQuery.of(context).size.width, // puni ekran
              child: Image.asset(
                'assets/images/adora.jpg',
                height: 120,
                fit: BoxFit.cover, // popuni prostor i očuvaj proporcije
              ),
            ),

            const SizedBox(height: 16),

            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Pretraži proizvode...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_searchQuery.isEmpty) ...[
              // KATEGORIJE
              // KATEGORIJE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ValueListenableBuilder<List<model.Category>>(
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

                    // Dijalog za izmenu kategorije
                    void _showEditCategoryDialog(model.Category category) {
                      final TextEditingController controller =
                      TextEditingController(text: category.name);

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFFD87F7F),
                            title: const Text(
                              "Izmeni kategoriju",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: TextField(
                              controller: controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Novo ime kategorije",
                                hintStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Otkaži",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await categoryVM.updateCategoryName(
                                      category.id, controller.text);
                                  await categoryVM.fetchCategories(); // osveži listu
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  "Sačuvaj",
                                  style: TextStyle(color: Color(0xFFD87F7F)),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    // Dijalog za brisanje kategorije
                    void _showDeleteCategoryDialog(model.Category category) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFFD87F7F),
                            title: const Text(
                              "Brisanje kategorije",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "Da li ste sigurni da želite da obrišete kategoriju?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Otkaži",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await categoryVM.deleteCategory(category.id);
                                  await categoryVM.fetchCategories(); // osveži listu
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  "Obriši",
                                  style: TextStyle(color: Color(0xFFD87F7F)),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    // Jedan item kategorije sa admin dugmadima
                    Widget categoryItem(model.Category category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _categoryButton(category),
                            if (isAdmin) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _showEditCategoryDialog(category),
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(8),
                                      backgroundColor: const Color(0xFFD87F7F),
                                    ),
                                    child: const Icon(Icons.edit,
                                        size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  ElevatedButton(
                                    onPressed: () => _showDeleteCategoryDialog(category),
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(8),
                                      backgroundColor: const Color(0xFFD87F7F),
                                    ),
                                    child: const Icon(Icons.delete,
                                        size: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      );
                    }

                    // Glavna lista kategorija
                    return SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...categories.map(categoryItem).toList(),
                          if (isAdmin)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // dijalog za dodavanje nove kategorije
                                  final TextEditingController controller =
                                  TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: const Color(0xFFD87F7F),
                                        title: const Text("Nova kategorija",
                                            style: TextStyle(color: Colors.white)),
                                        content: TextField(
                                          controller: controller,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(
                                            hintText: "Ime kategorije",
                                            hintStyle: TextStyle(color: Colors.white70),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Otkaži",
                                                style: TextStyle(color: Colors.white)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await categoryVM.addCategory(controller.text);
                                              await categoryVM.fetchCategories(); // osveži listu
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                            ),
                                            child: const Text(
                                              "Sačuvaj",
                                              style: TextStyle(color: Color(0xFFD87F7F)),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text("Dodaj",
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2A7A7),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),




              // BANNERI
              SizedBox(
                height: 200,
                child: PageView(
                  controller: _pageController,
                  children: banners
                      .map((b) => Image.asset(b, fit: BoxFit.cover))
                      .toList(),
                ),
              ),

              const SizedBox(height: 10),
              SmoothPageIndicator(
                controller: _pageController,
                count: banners.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Color(0xFFD87F7F),
                  dotColor: Color(0xFFBFA1A1),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Izdvajamo za vas',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD87F7F))),

              const SizedBox(height: 10),

              SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popular.length,
                  itemBuilder: (_, i) =>
                      _recommendedProductCard(popular[i]),
                ),
              ),
            ] else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchResults.length,
                itemBuilder: (_, i) =>
                    _recommendedProductCard(searchResults[i]),
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
      body: screens[_currentIndex],
      bottomNavigationBar: isGuest
          ? null
          : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFD87F7F),
        unselectedItemColor: const Color(0xFFBFA1A1),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
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
