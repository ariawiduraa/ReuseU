import 'package:flutter/material.dart';
import 'package:reuseu/navigation/main_navigation.dart';
import 'package:reuseu/screens/home/home_screen.dart';
import 'package:reuseu/screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReuseU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Inter', // Sesuaikan jika menggunakan custom font
      ),
      home: const LoginScreen(),
    );
  }
}
