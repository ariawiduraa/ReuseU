import 'package:flutter/material.dart';
import 'package:reuseu/screens/splash_screen.dart';
import 'package:reuseu/screens/auth/login_screen.dart'; 

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
      theme: ThemeData(primarySwatch: Colors.brown, fontFamily: 'Inter'),

      home: const AppLaunchAnimation(),
    );
  }
}

class AppLaunchAnimation extends StatefulWidget {
  const AppLaunchAnimation({super.key});

  @override
  State<AppLaunchAnimation> createState() => _AppLaunchAnimationState();
}

class _AppLaunchAnimationState extends State<AppLaunchAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((value) {

      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const SplashScreen())
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFFF5EDE0), 
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset('assets/images/splash.png', width: 150),
        ),
      ),
    );
  }
}