import 'package:flutter/material.dart';
import 'package:reuseu/screens/auth/login_screen.dart';

const kBgColor = Color(0xFFF5EDE0);
const kAccent = Color(0xFFC8956C);
const kAccentLight = Color(0xFFE8C9AE);
const kTextDark = Color(0xFF5C3D2E);
const kTextMuted = Color(0xFF9C6B50);
const kDark = Color(0xFF2C2C2A);
const kCircleBg = Color(0xFFEDD9C5);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.storefront_rounded,
      title: 'Jual Barang\nPreloved Kamu',
      description: 'Upload foto, tentukan harga, dan mulai jual barang bekas berkualitasmu dengan mudah.',
    ),
    _OnboardingData(
      icon: Icons.search_rounded,
      title: 'Temukan Barang\nImpianmu',
      description: 'Ribuan barang preloved dari berbagai kategori tersedia dengan harga yang terjangkau.',
    ),
    _OnboardingData(
      icon: Icons.handshake_rounded,
      title: 'Transaksi Aman\n& Terpercaya',
      description: 'Sistem pembayaran aman dan perlindungan pembeli membuat belanja makin nyaman.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: _pages.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, index) => _PageContent(
            data: _pages[index],
            currentPage: _currentPage,
            totalPages: _pages.length,
            isLast: _currentPage == _pages.length - 1,
            onNext: _nextPage,
            onSkip: _goToLogin,
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingData({required this.icon, required this.title, required this.description});
}

// ── Single page (Stateful untuk Animasi) ──────────────────────
class _PageContent extends StatefulWidget {
  final _OnboardingData data;
  final int currentPage;
  final int totalPages;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _PageContent({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _PageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: SizedBox(
                  width: 260,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(size: const Size(240, 280), painter: _ArchPainter()),
                      Icon(widget.data.icon, size: 100, color: kAccent),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.totalPages, (i) {
                  final active = i == widget.currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? kAccent : kAccentLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            Text(widget.data.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kTextDark, height: 1.25)),
            const SizedBox(height: 12),
            Text(widget.data.description, style: const TextStyle(fontSize: 14, color: kTextMuted, height: 1.6)),
            const Spacer(),
            Row(
              children: [
                if (!widget.isLast)
                  TextButton(
                    onPressed: widget.onSkip,
                    child: const Text('SKIP', style: TextStyle(color: kTextMuted, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                if (!widget.isLast) const Spacer(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(widget.isLast ? 'MULAI' : 'NEXT', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.05, size.width * 0.9, size.height * 0.9),
        const Radius.circular(120),
      ),
      Paint()..color = kCircleBg,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}