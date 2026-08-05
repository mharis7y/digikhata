import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile_setup/providers/business_provider.dart';
import '../../../routes/app_routes.dart';

/// Splash Screen — shows branding, then routes based on session state.
/// Displays "Powered by Zenvyro Labs" per agents.md branding requirement.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.checkSession();

    if (!mounted) return;

    if (auth.isAuthenticated) {
      // Load the business profile from Supabase so Home screen has
      // business name, type, category available right away.
      final bizProvider = context.read<BusinessProvider>();
      await bizProvider.loadProfile(auth.currentUser!.id);

      if (!mounted) return;

      if (auth.isSuperAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.superAdminDashboard);
      } else if (auth.currentUser!.isProfileSetupComplete) {
        // Safety check: if profile is marked complete but business data
        // is missing (and user isn't "not a business person"), the
        // previous save must have failed — send them back to setup.
        final profile = bizProvider.profile;
        final hasBusinessData = profile != null &&
            (profile.isNotBusinessPerson ||
                (profile.businessName != null &&
                    profile.businessName!.isNotEmpty));

        if (hasBusinessData) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF285CCC),
      body: SafeArea(
        child: SizedBox.expand(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Logo & App Name
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2BD),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 56,
                          color: Color(0xFF285CCC),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'DigiKhata',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Digital Bookkeeping & Ledger',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                // Loading indicator
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),
                // Zenvyro Labs branding — required per agents.md
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Powered by',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Zenvyro Labs logo image
                    Image.asset(
                      'assests/images/logo.png',
                      height: 38,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Zenvyro Labs',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFF2BD),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

