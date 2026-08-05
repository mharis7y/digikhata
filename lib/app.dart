import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile_setup/providers/business_provider.dart';
import 'features/party/providers/party_provider.dart';
import 'features/books/providers/stock_provider.dart';
import 'features/books/providers/bill_provider.dart';
import 'features/books/providers/cash_provider.dart';
import 'features/books/providers/staff_provider.dart';
import 'features/books/providers/expense_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/email_auth_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/profile_setup/screens/profile_setup_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/books/screens/khata_books_screen.dart';
import 'features/party/screens/party_screen.dart';
import 'features/party/screens/add_party_screen.dart';
import 'features/party/screens/customer_ledger_screen.dart';
import 'features/party/screens/supplier_ledger_screen.dart';
import 'features/party/screens/add_entry_screen.dart';
import 'features/party/screens/bank_account_screen.dart';
import 'features/party/models/party_model.dart';
import 'features/party/models/ledger_entry_model.dart';
import 'routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => PartyProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => CashProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'DigiKhata',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen());

      case AppRoutes.onboarding:
        return _slide(const OnboardingScreen());

      case AppRoutes.emailAuth:
        return _slide(const EmailAuthScreen());

      case AppRoutes.otpVerification:
        final email = settings.arguments as String? ?? '';
        return _slide(OtpVerificationScreen(email: email));

      case AppRoutes.profileSetup:
        return _slide(const ProfileSetupScreen());

      case AppRoutes.home:
        return _fade(const HomeScreen());

      case AppRoutes.khataBooks:
        final initialTab = settings.arguments as String? ?? 'cash';
        return _slide(KhataBooksScreen(initialTab: initialTab));

      // ─── Party routes ─────────────────────────────────────────────────────
      case AppRoutes.party:
        return _slide(const PartyScreen());

      case AppRoutes.addParty:
        final type = settings.arguments as PartyType? ?? PartyType.customer;
        return _slide(AddPartyScreen(partyType: type));

      case AppRoutes.customerLedger:
        final party = settings.arguments as PartyModel;
        return _slide(CustomerLedgerScreen(party: party));

      case AppRoutes.supplierLedger:
        final party = settings.arguments as PartyModel;
        return _slide(SupplierLedgerScreen(party: party));

      case AppRoutes.addEntry:
        final args = settings.arguments as Map<String, dynamic>;
        final party = args['party'] as PartyModel;
        final entryType = args['entryType'] as EntryType;
        return _slide(AddEntryScreen(party: party, entryType: entryType));

      case AppRoutes.bankAccount:
        return _slide(const BankAccountScreen());

      // Other routes — placeholder until implemented
      default:
        return _fade(const _PlaceholderScreen());
    }
  }

  static PageRoute _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRoute _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Temporary placeholder for routes not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Coming Soon',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded,
                size: 64, color: Color(0xFF285CCC)),
            SizedBox(height: 16),
            Text(
              'This screen is being built.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
