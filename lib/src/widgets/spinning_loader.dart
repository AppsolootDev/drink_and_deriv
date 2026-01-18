import 'package:flutter/material.dart';

class SpinningRedLoader extends StatefulWidget {
  const SpinningRedLoader({super.key});

  @override
  State<SpinningRedLoader> createState() => _SpinningRedLoaderState();
}

class _SpinningRedLoaderState extends State<SpinningRedLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFCE2029)), // Deriv Red
                ),
              ),
              Image.asset(
                'assets/images/deriv.png',
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.stars, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Loading...",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
