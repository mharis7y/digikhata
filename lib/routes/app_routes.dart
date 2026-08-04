/// Centralized route names for the DigiKhata Clone app.
/// All navigation uses these constants to avoid string typos.
class AppRoutes {
  AppRoutes._();

  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String emailAuth = '/email-auth';
  static const String otpVerification = '/otp-verification';

  // Profile Setup (new accounts only)
  static const String profileSetup = '/profile-setup';

  // Home
  static const String home = '/home';

  // Party
  static const String party = '/party';
  static const String addParty = '/party/add';
  static const String customerLedger = '/party/customer-ledger';
  static const String supplierLedger = '/party/supplier-ledger';
  static const String bankAccount = '/party/bank-account';
  static const String addEntry = '/party/add-entry';

  // Books (single tab-wise module)
  static const String khataBooks = '/khata-books';
  static const String addCashEntry = '/books/add-cash';
  static const String addStockItem = '/books/add-stock';
  static const String stockReport = '/books/stock-report';
  static const String createBill = '/books/create-bill';
  static const String billDetail = '/books/bill-detail';
  static const String addStaff = '/books/add-staff';
  static const String attendance = '/books/attendance';
  static const String payroll = '/books/payroll';
  static const String addExpense = '/books/add-expense';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Other (home shortcuts)
  static const String calculator = '/calculator';
  static const String recycleBin = '/recycle-bin';

  // Notifications
  static const String notifications = '/notifications';

  // More (side menu)
  static const String pos = '/pos';
  static const String qr = '/qr';
  static const String kyc = '/kyc';
  static const String multiDevices = '/multi-devices';
  static const String businessCard = '/business-card';
  static const String tasdeeq = '/tasdeeq';
  static const String distributor = '/distributor';
  static const String backup = '/backup';

  // Super Admin
  static const String superAdminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminBusinesses = '/admin/businesses';
  static const String adminBanners = '/admin/banners';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminPushNotifications = '/admin/push-notifications';
  static const String adminSettings = '/admin/settings';
  static const String adminReports = '/admin/reports';
}
