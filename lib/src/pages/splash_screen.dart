import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../db/db_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _spinAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _textColorAnimation;
  
  bool _isDatabaseConnected = false;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _spinAnimation = Tween<double>(begin: 0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 1.0, curve: Curves.easeInOutSine))
    );

    // Fade in starts at 2 seconds (0.4 * 5s)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeIn))
    );

    // Slide up starts at 2 seconds (0.4 * 5s)
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut))
    );

    _textColorAnimation = ColorTween(begin: Colors.white, end: Colors.black).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.6, 1.0, curve: Curves.easeIn))
    );

    _mainController.forward();

    _connectToDatabase();

    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  Future<void> _connectToDatabase() async {
    try {
      final db = DatabaseService();
      await db.connect();
      if (mounted) {
        setState(() {
          _isDatabaseConnected = true;
        });
      }
    } catch (e) {
      debugPrint('Localhost DB connection failed: $e');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(isDatabaseConnected: _isDatabaseConnected),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('assets/background_splash.png', fit: BoxFit.cover),
          
          // White Conic Gradient Overlay (Fades In)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: const BoxDecoration(
                gradient: SweepGradient(
                  center: Alignment.center,
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          Container(color: Colors.black.withOpacity(0.1)),
          
          Center(
            child: AnimatedBuilder(
              animation: _spinAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [Colors.green, Colors.red, Colors.green],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Transform.rotate(
                            angle: -_spinAnimation.value,
                            child: Image.asset(
                              'assets/images/deriv.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 60, color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _textColorAnimation,
                  builder: (context, child) {
                    return Center(
                      child: Text(
                        'Drink & Deryve',
                        style: TextStyle(
                          fontFamily: 'Josefine',
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: _textColorAnimation.value,
                          shadows: _textColorAnimation.value == Colors.white 
                            ? [Shadow(blurRadius: 10.0, color: Colors.black.withOpacity(0.5), offset: const Offset(2.0, 2.0))]
                            : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
