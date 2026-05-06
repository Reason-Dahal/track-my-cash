import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 🔥 ANIMATION CONTROLLER
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 🔥 NAVIGATE TO HOME AFTER DELAY
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔥 ROTATING LOADER
  Widget buildLoader() {
    return RotationTransition(
      turns: _controller,
      child: const Icon(
        Icons.currency_rupee, // 💰 change if you want
        size: 50,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // 🌿 LIGHT GREEN
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 APP TITLE
            const Text(
              "TrackMyCash",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 LOADER
            buildLoader(),

            const SizedBox(height: 20),

            const Text("Loading...", style: TextStyle(color: Colors.green)),
          ],
        ),
      ),

      // 🔥 FOOTER TEXT
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Developed for Reason",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontSize: 14),
        ),
      ),
    );
  }
}
