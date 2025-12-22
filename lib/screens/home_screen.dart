import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'users_screen.dart'; // importuj UsersScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _currentIndex = 0; // kontrola BottomNavigationBar

  final List<String> banners = [
    'assets/images/bannerno1.jpg',
    'assets/images/bannerno2.jpg',
  ];

  // Staticke kategorije
  final List<String> categories = [
    'Šamponi',
    'Losioni',
    'Maske za kosu',
    'Serumi',
    'Gelovi',
    'Boje za kosu',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Logo
            Image.asset(
              'assets/images/adora.jpg',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),

            // Polje za pretragu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pretraži proizvode...',
                  prefixIcon:
                  const Icon(Icons.search, color: Color(0xFFD87F7F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE3CFCF),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dugmad kategorija
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((c) => _categoryButton(c)).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bannere
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return index == 0
                      ? _bannerWithBadge(banners[index])
                      : _bannerWithoutText(banners[index]);
                },
              ),
            ),

            const SizedBox(height: 10),

            // Dots indicator
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: banners.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Color(0xFFD87F7F),
                  dotColor: Color(0xFFBFA1A1),
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Izdvajamo za vas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD87F7F),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Dugme Porudžbine
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ).then((_) {
              setState(() {
                _currentIndex = 0; // reset na Home kada se vrati
              });
            });
          } else if (index == 2) {
            // Dugme Korpa
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ).then((_) {
              setState(() {
                _currentIndex = 0; // reset na Home kada se vrati
              });
            });
          } else if (index == 3) {
            // Dugme Korisnici
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UsersScreen()),
            ).then((_) {
              setState(() {
                _currentIndex = 0; // reset na Home kada se vrati
              });
            });
          } else if (index == 4) {
            // Dugme Profil
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ).then((_) {
              setState(() {
                _currentIndex = 0; // reset na Home kada se vrati
              });
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: const Color(0xFFD87F7F),
        unselectedItemColor: const Color(0xFFBFA1A1),
        backgroundColor: const Color(0xFFF5E8E8),
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Porudžbine'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Korpa'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Korisnici'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _categoryButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD8B4B4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _bannerWithBadge(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(12),
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFFD87F7F),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '50% OFF',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerWithoutText(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
