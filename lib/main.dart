import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(TrackMyCashApp());
}

class TrackMyCashApp extends StatelessWidget {
  const TrackMyCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TrackMyCash",
      theme: ThemeData(useMaterial3: true),
      home: SplashScreen(),
    );
  }
}
