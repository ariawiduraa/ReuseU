import 'package:flutter/material.dart';
import 'package:reuseu/screens/splash_screen.dart';
import 'package:reuseu/navigation/main_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reuseu/endpoints/endpoints.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Endpoints.supabaseUrl,
    publishableKey: Endpoints.supabaseAnonKey,
  );

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

class _AppLaunchAnimationState extends State<AppLaunchAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      if (!mounted) return;

      // Cek apakah user sudah punya sesi aktif
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Sudah login → langsung ke halaman utama
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        // Belum login → ke onboarding/splash
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
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