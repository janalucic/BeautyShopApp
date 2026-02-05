import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_picker/image_picker.dart';

import 'category_products_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'users_screen.dart';

import 'package:first_app_flutter/viewmodels/product.dart';
import 'package:first_app_flutter/viewmodels/category.dart';
import 'package:first_app_flutter/viewmodels/banner.dart';
import 'package:first_app_flutter/models/category.dart' as model;
import 'package:first_app_flutter/models/product.dart';
import 'package:first_app_flutter/models/banner.dart';

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

  @override
  void initState() {
    super.initState();

    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProductViewModel>().fetchProducts();
      await context.read<CategoryViewModel>().fetchCategories();
      await context.read<BannerViewModel>().fetchBanners();
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
        final isAdmin = context.read<UserProvider>().isAdmin;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(
              categoryId: category.id,
              categoryName: category.name,
              isAdmin: isAdmin,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD87F7F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        category.name,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _showDeleteCategoryDialog(model.Category category, CategoryViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD87F7F),
        title: const Text('Obriši kategoriju', style: TextStyle(color: Colors.white)),
        content: Text(
          'Da li ste sigurni da želite da obrišete kategoriju "${category.name}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              await vm.deleteCategory(category.id); // briše iz Firebase
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Obriši', style: TextStyle(color: Color(0xFFD87F7F))),
          ),
        ],
      ),
    );
  }


  void _showAddCategoryDialog(CategoryViewModel categoryVM) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD87F7F),
        title: const Text('Dodaj novu kategoriju', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Unesi ime kategorije',
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
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await categoryVM.addCategory(name); // pozivaš ViewModel
                Navigator.pop(context); // zatvara dijalog
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Dodaj', style: TextStyle(color: Color(0xFFD87F7F))),
          ),
        ],
      ),
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
                _adminIcon(
                  Icons.delete,
                      () => _showDeleteCategoryDialog(category, vm),
                ),

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

  // ================= BANNERI =================

  Widget _bannerSection(BannerViewModel bannerVM, ProductViewModel productVM) {
    final banners = bannerVM.activeBanners;
    final isAdmin = context.read<UserProvider>().isAdmin;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: banners.isEmpty
              ? Center(
            child: Text(
              'Nema aktivnih banera.',
              style: TextStyle(color: Colors.grey[400]),
            ),
          )
              : PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            itemBuilder: (_, i) {
              final banner = banners[i];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (banner.productId != 0) {
                        final product = productVM.products.firstWhere(
                                (p) => p.id == banner.productId,
                            orElse: () => Product(
                              id: 0,
                              name: 'Nepoznat proizvod',
                              description: '',
                              price: 0,
                              imageUrl: '',
                              popular: false,
                              categoryId: 0,
                            ));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product, isAdmin: isAdmin),
                          ),
                        );
                      }
                    },
                    child: Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  if (isAdmin)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          _adminIcon(Icons.edit,
                                  () => _showEditBannerDialog(banner)),
                          const SizedBox(width: 4),
                          _adminIcon(Icons.delete,
                                  () => _showDeleteBannerDialog(banner)),
                        ],
                      ),
                    ),
                ],
              );
            },
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
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: _showAddBannerDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Dodaj baner",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2A7A7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
      ],
    );
  }

  // ================= ADMIN BANER DIALOGS =================

  Future<void> _showDeleteBannerDialog(BannerModel banner) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFD87F7F),
          title:
          const Text('Obriši baner', style: TextStyle(color: Colors.white)),
          content: const Text('Da li ste sigurni da želite da obrišete baner?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<BannerViewModel>().deleteBanner(banner.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Obriši',
                  style: TextStyle(color: Color(0xFFD87F7F))),
            ),
          ],
        ));
  }

  Future<void> _showAddBannerDialog() async {
    XFile? pickedImage;
    Product? selectedProduct; // nullable
    int? selectedProductId;
    bool isActive = true;

    final products = context.read<ProductViewModel>().products;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD87F7F),
          title: const Text('Dodaj baner', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        pickedImage = image;
                      });
                    }
                  },
                  child: Text(
                    pickedImage == null ? 'Izaberi sliku' : 'Slika izabrana',
                  ),
                ),
                const SizedBox(height: 8),
                // Dropdown za izbor proizvoda
                DropdownButton<int>(
                  value: selectedProductId,
                  hint: const Text('Izaberi proizvod', style: TextStyle(color: Colors.white)),
                  isExpanded: true,
                  dropdownColor: const Color(0xFFD87F7F),
                  items: products
                      .map(
                        (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, style: const TextStyle(color: Colors.white)),
                    ),
                  )
                      .toList(),
                  onChanged: (id) {
                    setState(() {
                      selectedProductId = id;
                      selectedProduct = id != null
                          ? products.firstWhere((p) => p.id == id)
                          : null; // može biti null
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Aktivan', style: TextStyle(color: Colors.white)),
                    Checkbox(
                      value: isActive,
                      onChanged: (v) => setState(() => isActive = v ?? true),
                      activeColor: Colors.white,
                      checkColor: const Color(0xFFD87F7F),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pickedImage == null) return; // ne može bez slike

                final url = await context.read<BannerViewModel>().uploadImage(File(pickedImage!.path));

                final banner = BannerModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  imageUrl: url,
                  productId: selectedProduct?.id ?? 0, // ako nije izabrano, 0
                  isActive: isActive,
                );

                await context.read<BannerViewModel>().addBanner(banner);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Sačuvaj', style: TextStyle(color: Color(0xFFD87F7F))),
            ),
          ],
        );
      }),
    );
  }


  Future<void> _showEditBannerDialog(BannerModel banner) async {
    XFile? pickedImage;
    final products = context.read<ProductViewModel>().products;
    int? selectedProductId = banner.productId != 0 ? banner.productId : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD87F7F),
          title: const Text('Izmeni baner', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (image != null) setState(() => pickedImage = image);
                  },
                  child: Text(pickedImage == null ? 'Izaberi novu sliku' : 'Slika izabrana'),
                ),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: selectedProductId,
                  hint: const Text('Izaberi proizvod', style: TextStyle(color: Colors.white)),
                  isExpanded: true,
                  dropdownColor: const Color(0xFFD87F7F),
                  items: products
                      .map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, style: const TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (id) => setState(() => selectedProductId = id),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                String url = banner.imageUrl;
                if (pickedImage != null) {
                  url = await context.read<BannerViewModel>().uploadImage(File(pickedImage!.path));
                }

                final updatedBanner = BannerModel(
                  id: banner.id,
                  imageUrl: url,
                  productId: selectedProductId ?? 0,
                  isActive: banner.isActive, // status ostaje isti
                );

                await context.read<BannerViewModel>().updateBanner(updatedBanner);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Sačuvaj', style: TextStyle(color: Color(0xFFD87F7F))),
            ),
          ],
        );
      }),
    );
  }

  // ====================== BUILD HOME SCREEN ======================

  Widget _buildHomeScreen(
      ProductViewModel productVM, CategoryViewModel categoryVM, BannerViewModel bannerVM) {
    final products = productVM.products;
    final popular = products.where((p) => p.popular).toList();
    final searchResults = _searchQuery.isEmpty
        ? <Product>[]
        : products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final isAdmin = context.read<UserProvider>().isAdmin;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 120,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/adora.jpg',
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                if (!context.watch<UserProvider>().isGuest &&
                    !context.watch<UserProvider>().isAdmin)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAdmin)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddCategoryDialog(categoryVM),
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories
                                .map((c) => _categoryItem(c, isAdmin, categoryVM))
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ),


                  // BANERI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _bannerSection(bannerVM, productVM),
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
                itemBuilder: (_, i) => _recommendedProductCard(popular[i]),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (_, i) => _recommendedProductCard(searchResults[i]),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<UserProvider>().isGuest;
    final isAdmin = context.watch<UserProvider>().isAdmin;

    final productVM = context.watch<ProductViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();
    final bannerVM = context.watch<BannerViewModel>();

    final List<Widget> screens = isAdmin
        ? [
      _buildHomeScreen(productVM, categoryVM, bannerVM),
      const OrdersScreen(),
      const UsersScreen(),
      const ProfileScreen(),
    ]
        : [
      _buildHomeScreen(productVM, categoryVM, bannerVM),
      const OrdersScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = isAdmin
        ? const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Porudžbine'),
      BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Korisnici'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ]
        : const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Porudžbine'),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Korpa'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
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
        items: navItems,
      ),
    );
  }
}