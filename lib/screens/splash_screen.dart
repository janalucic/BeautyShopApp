import 'package:flutter/material.dart';
import 'login_screen.dart'; // importuj svoj LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadina
          SizedBox.expand(
            child: Image.asset(
              'assets/images/splash111.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Tamni overlay
          Container(
            color: const Color.fromARGB(51, 0, 0, 0),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1), // gornji razmak

                // Logo i slogan centrirani
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                        const Color.fromARGB(77, 255, 255, 255),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/adora.jpg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Slogan
                      const Text(
                        'Beauty made easy',
                        style: TextStyle(
                          color: Color(0xFF800020), // bordo
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3), // razmak između logo/slogan i strelice

                // Pulsirajuća strelica
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0, bottom: 50),
                    child: GestureDetector(
                      onTap: () {
                        // OVDE preusmerava na LoginScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: ScaleTransition(
                        scale: _animation,
                        child: const Text(
                          '>>>',
                          style: TextStyle(
                            color: Color(0xFFFFC1CC), // svetlo roze
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
