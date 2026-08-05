import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile_setup/providers/business_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../widgets/side_menu_drawer.dart';
import '../../../routes/app_routes.dart';

/// Home Screen per agents.md:
/// - Top bar: side-menu icon, business name, premium/crown icon, notifications bell, quick-apps grid icon
/// - Promo/banner slot (generic promotional banner area)
/// - KHATA grid: Party, Cash, Stock, Bills, Staff, Expense
/// - "View Dashboard" shortcut → Dashboard screen
/// - Other: Calculator, RecycleBin
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final businessProvider = context.watch<BusinessProvider>();

    final businessName = businessProvider.profile?.businessName ??
        authProvider.currentUser?.email?.split('@').first ??
        'My Business';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const SideMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ──────────────────────────────────────────────
            _TopBar(businessName: businessName),

            // ─── Main Content Area (Scrollable) ───────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo/Banner Slot
                    const _PromoBannerCard(),
                    const SizedBox(height: 24),

                    // Section Header: KHATA + View Dashboard shortcut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'K H A T A',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                            letterSpacing: 1.5,
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.dashboard),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bar_chart_rounded,
                                  color: Color(0xFF285CCC),
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'View Dashboard',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF285CCC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ─── KHATA Grid ─────────────────────────────────────────
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                      children: [
                        _KhataGridTile(
                          title: 'Party',
                          icon: Icons.people_alt_rounded,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.party),
                        ),
                        _KhataGridTile(
                          title: 'Cash',
                          icon: Icons.account_balance_wallet_rounded,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.khataBooks,
                              arguments: 'cash'),
                        ),
                        _KhataGridTile(
                          title: 'Stock',
                          icon: Icons.inventory_2_rounded,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.khataBooks,
                              arguments: 'stock'),
                        ),
                        _KhataGridTile(
                          title: 'Bills',
                          icon: Icons.receipt_long_rounded,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.khataBooks,
                              arguments: 'bills'),
                        ),
                        _KhataGridTile(
                          title: 'Staff',
                          icon: Icons.badge_rounded,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.khataBooks,
                              arguments: 'staff'),
                        ),
                        _KhataGridTile(
                          title: 'Expense',
                          icon: Icons.monetization_on_rounded,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.khataBooks,
                              arguments: 'expense'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ─── OTHER Section ─────────────────────────────────────
                    const Text(
                      'O T H E R',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _OtherCard(
                            title: 'Calculator',
                            subtitle: 'Quick arithmetic',
                            icon: Icons.calculate_rounded,
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.calculator),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar per agents.md: side-menu icon, business name, premium/crown icon, notifications bell, quick-apps grid icon
class _TopBar extends StatelessWidget {
  final String businessName;

  const _TopBar({required this.businessName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6EAF2)),
        ),
      ),
      child: Row(
        children: [
          // Hamburger Side Menu Icon
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: Color(0xFF285CCC), size: 26),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              tooltip: 'Menu',
            ),
          ),
          const SizedBox(width: 4),

          // Business Name Button (Pill)
          Expanded(
            child: InkWell(
              onTap: () {
                // Future profile switcher
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3FC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF285CCC).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        businessName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF285CCC),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Crown Icon (Premium)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2BD),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFF2BD).withValues(alpha: 0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('DigiKhata Premium — coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              tooltip: 'Premium',
            ),
          ),

          // Notification Bell
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF6B7280), size: 24),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.notifications),
                    tooltip: 'Notifications',
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Quick Apps Grid Icon
          IconButton(
            icon: const Icon(Icons.grid_view_rounded,
                color: Color(0xFF6B7280), size: 22),
            onPressed: () {
              _showQuickAppsModal(context);
            },
            tooltip: 'Quick Apps',
          ),
        ],
      ),
    );
  }

  void _showQuickAppsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Apps',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickAppItem(
                    icon: Icons.calculate_rounded,
                    label: 'Calculator',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, AppRoutes.calculator);
                    },
                  ),

                  _QuickAppItem(
                    icon: Icons.cloud_upload_rounded,
                    label: 'Backup',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, AppRoutes.backup);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAppItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAppItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2BD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF285CCC), size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic promotional banner card per agents.md in Blue Theme
class _PromoBannerCard extends StatelessWidget {
  const _PromoBannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF285CCC), Color(0xFF1F4AB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF285CCC).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative watermark icon
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Icons.trending_up_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2BD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'DIGIKHATA PREMIUM',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F4AB0),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Simplify Business Accounting',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Get automated reminders & daily backups with zero data loss.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exploring Premium features...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF2BD),
                  foregroundColor: const Color(0xFF285CCC),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Explore Now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual grid tile for KHATA section
class _KhataGridTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _KhataGridTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2BD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF285CCC),
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Other card for Calculator / RecycleBin
class _OtherCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _OtherCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF285CCC),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
