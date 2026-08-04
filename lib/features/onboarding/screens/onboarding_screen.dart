import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

/// Onboarding slide data.
class _OnboardingSlide {
  final String headline;
  final String subheadline;
  final IconData icon;
  final String statLabel1;
  final String statValue1;
  final String statLabel2;
  final String statValue2;

  const _OnboardingSlide({
    required this.headline,
    required this.subheadline,
    required this.icon,
    required this.statLabel1,
    required this.statValue1,
    required this.statLabel2,
    required this.statValue2,
  });
}

/// Onboarding Screen — 3 slides with page indicators and "Let's get started!" button.
/// Follows Blue Theme per agents.md. Does NOT copy DigiKhata's visual design.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      headline: 'Track Customers\n& Suppliers',
      subheadline:
          'Super app for small businesses trusted\nby 5M+ businesses across Pakistan.',
      icon: Icons.people_alt_rounded,
      statLabel1: 'TOTAL PAYABLES',
      statValue1: 'Rs 84,200',
      statLabel2: 'TOTAL RECEIVABLES',
      statValue2: 'Rs 142,500',
    ),
    _OnboardingSlide(
      headline: 'Manage Stock,\nBills & Cash',
      subheadline:
          'Keep track of inventory, bills, salaries\nand daily cash flow effortlessly.',
      icon: Icons.inventory_2_rounded,
      statLabel1: 'STOCK VALUE',
      statValue1: 'Rs 450,000',
      statLabel2: 'CASH IN HAND',
      statValue2: 'Rs 180,000',
    ),
    _OnboardingSlide(
      headline: 'Grow Your\nBusiness Smarter',
      subheadline:
          'Detailed reports, profit tracking, and\nreal-time dashboards at your fingertips.',
      icon: Icons.analytics_rounded,
      statLabel1: 'NET PROFIT',
      statValue1: 'Rs 208,000',
      statLabel2: 'TOTAL INCOME',
      statValue2: 'Rs 370,000',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.emailAuth);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.emailAuth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF285CCC),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page view — top visual area
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _slides.length,
                itemBuilder: (context, idx) {
                  return _SlidePage(slide: _slides[idx]);
                },
              ),
            ),

            // Bottom white card panel
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App logo + name row
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2BD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF285CCC),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'DigiKhata',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Slide headline
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _slides[_currentPage].subheadline,
                      key: ValueKey(_currentPage),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Page indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? const Color(0xFF285CCC)
                              : const Color(0xFFE6EAF2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF285CCC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _slides.length - 1
                                ? "Let's get started!"
                                : 'Next',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual onboarding slide — shows two floating stat cards + centered icon.
class _SlidePage extends StatelessWidget {
  final _OnboardingSlide slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background pattern
        Positioned.fill(
          child: CustomPaint(painter: _BgCirclePainter()),
        ),

        // Centered icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(slide.icon, size: 52, color: Colors.white),
          ),
        ),

        // Floating stat card — top right (Payables / negative)
        Positioned(
          top: 24,
          right: 20,
          child: _StatCard(
            label: slide.statLabel1,
            value: slide.statValue1,
            isPositive: false,
            changeText: '4.2% from last week',
            actionLabel: 'You Gave',
          ),
        ),

        // Floating stat card — bottom left (Receivables / positive)
        Positioned(
          bottom: 32,
          left: 20,
          child: _StatCard(
            label: slide.statLabel2,
            value: slide.statValue2,
            isPositive: true,
            changeText: '12.5% this month',
            actionLabel: 'You Got',
          ),
        ),
      ],
    );
  }
}

/// Floating statistics card shown on onboarding slides.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final String changeText;
  final String actionLabel;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isPositive,
    required this.changeText,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  changeText,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPositive ? 'You are to get' : 'You are to give',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for subtle background circles on the Blue area.
class _BgCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      120,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      90,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BgCirclePainter oldDelegate) => false;
}
