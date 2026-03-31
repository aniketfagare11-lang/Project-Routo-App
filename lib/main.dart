import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const RoutoApp());
}

class RoutoApp extends StatelessWidget {
  const RoutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
