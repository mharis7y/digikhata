import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/business_profile_model.dart';
import '../providers/business_provider.dart';
import '../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Business Type constants per agents.md reference (from reference screenshots)
// ─────────────────────────────────────────────────────────────────────────────
const List<BusinessTypeOption> kBusinessTypes = [
  BusinessTypeOption(
    label: 'Retailer / Shop',
    icon: Icons.storefront_rounded,
    value: 'Retailer',
  ),
  BusinessTypeOption(
    label: 'Wholesaler',
    icon: Icons.warehouse_rounded,
    value: 'Wholesaler',
  ),
  BusinessTypeOption(
    label: 'Distributor',
    icon: Icons.local_shipping_rounded,
    value: 'Distributor',
  ),
  BusinessTypeOption(
    label: 'Manufacturer',
    icon: Icons.factory_rounded,
    value: 'Manufacturer',
  ),
  BusinessTypeOption(
    label: 'Services',
    icon: Icons.build_circle_rounded,
    value: 'Services',
  ),
  BusinessTypeOption(
    label: 'Others',
    icon: Icons.category_rounded,
    value: 'Others',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Business Categories per agents.md reference screenshots
// ─────────────────────────────────────────────────────────────────────────────
const List<String> kBusinessCategories = [
  'Grocery',
  'Fashion & Textile',
  'Pharmacy & Medical Care',
  'Mobile & Electronics',
  'Vehicle Accessories',
  'Gym & Sports',
  'Babies & Toys',
  'Bakery & Cake',
  'Books & Stationery',
  'Chicken & Meat',
  'Gardening',
  'Hardware Tools',
  'Footwear',
  'Furniture',
  'Jewellery',
  'Salon & Beauty',
  'Petroleum',
  'Real Estate',
  'Agriculture',
  'Other',
];

class BusinessTypeOption {
  final String label;
  final IconData icon;
  final String value;

  const BusinessTypeOption({
    required this.label,
    required this.icon,
    required this.value,
  });
}

/// Profile / Business Setup Screen per agents.md:
/// - Progress indicator (3 steps)
/// - Personal: Selfie (optional), CNIC Front, CNIC Back (gallery or camera)
/// - "I am not a business person" toggle (skips business fields)
/// - Business: Business Name, Business Type (bottom sheet), Business Category (search screen)
/// - "Start" → routes to Home
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _businessNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Personal captures
  bool _selfieCaptured = false;
  bool _cnicFrontCaptured = false;
  bool _cnicBackCaptured = false;

  // Business
  bool _isNotBusinessPerson = false;
  String? _selectedBusinessType;
  String? _selectedCategory;

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  // ─── Step indicator (3-step progress bar) ───────────────────────────────
  int get _currentStep {
    final hasPersonal = _cnicFrontCaptured && _cnicBackCaptured;
    final hasBusiness = _isNotBusinessPerson ||
        (_selectedBusinessType != null && _selectedCategory != null);
    if (!hasPersonal) return 1;
    if (!hasBusiness) return 2;
    return 3;
  }

  // ─── Image picker simulation (camera / gallery) ──────────────────────────
  Future<void> _showImageSourceSheet({
    required String label,
    required bool isOptional,
    required void Function() onCapture,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              if (isOptional)
                const Text(
                  'Optional — you may skip this.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              const SizedBox(height: 20),
              _SourceOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                onTap: () {
                  Navigator.pop(ctx);
                  onCapture();
                },
              ),
              const SizedBox(height: 12),
              _SourceOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  onCapture();
                },
              ),
              if (isOptional) ...[
                const SizedBox(height: 12),
                _SourceOption(
                  icon: Icons.close_rounded,
                  label: 'Skip',
                  isDestructive: true,
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Business Type bottom sheet ──────────────────────────────────────────
  Future<void> _showBusinessTypeSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EAF2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'What is your Business Type?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kBusinessTypes.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (ctx2, i) {
                  final type = kBusinessTypes[i];
                  final selected = _selectedBusinessType == type.value;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedBusinessType = type.value);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFEEF3FC)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF285CCC)
                              : const Color(0xFFE6EAF2),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2BD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              type.icon,
                              size: 18,
                              color: const Color(0xFF285CCC),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              type.label,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Business Category search screen ─────────────────────────────────────
  Future<void> _showCategoryScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _CategorySelectScreen()),
    );
    if (result != null) {
      setState(() => _selectedCategory = result);
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    // CNIC Front and Back are compulsory per agents.md
    if (!_cnicFrontCaptured || !_cnicBackCaptured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CNIC Front and CNIC Back are required.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isNotBusinessPerson) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      if (_selectedBusinessType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your business type.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your business category.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final auth = context.read<AuthProvider>();
    final bizProvider = context.read<BusinessProvider>();
    final userId = auth.currentUser!.id;

    bizProvider.updateProfile(
      BusinessProfileModel(
        userId: userId,
        selfieUrl: _selfieCaptured ? 'local://selfie' : null,
        cnicFrontUrl: 'local://cnic_front',
        cnicBackUrl: 'local://cnic_back',
        isNotBusinessPerson: _isNotBusinessPerson,
        businessName: _isNotBusinessPerson
            ? null
            : _businessNameController.text.trim(),
        businessType: _isNotBusinessPerson ? null : _selectedBusinessType,
        businessCategory: _isNotBusinessPerson ? null : _selectedCategory,
      ),
    );

    final saved = await bizProvider.saveProfile(userId);
    if (!mounted) return;

    if (saved) {
      auth.setUser(auth.currentUser!.copyWith(isProfileSetupComplete: true));
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              bizProvider.errorMessage ?? 'Failed to save profile.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bizProvider = context.watch<BusinessProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ─── 3-step progress bar ────────────────────────────────────
            _StepProgressBar(currentStep: _currentStep, totalSteps: 3),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button + logo
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF285CCC),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2BD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 20,
                              color: Color(0xFF285CCC),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'DigiKhata',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Let\'s create your profile',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Please enter your profile & business information',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ─── Personal Section ────────────────────────────
                      const _SectionHeader(label: 'Personal'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _PhotoCaptureTile(
                              label: 'Selfie',
                              icon: Icons.face_retouching_natural_rounded,
                              isCaptured: _selfieCaptured,
                              isOptional: true,
                              onTap: () => _showImageSourceSheet(
                                label: 'Selfie',
                                isOptional: true,
                                onCapture: () =>
                                    setState(() => _selfieCaptured = true),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PhotoCaptureTile(
                              label: 'CNIC Front',
                              icon: Icons.credit_card_rounded,
                              isCaptured: _cnicFrontCaptured,
                              isOptional: false,
                              onTap: () => _showImageSourceSheet(
                                label: 'CNIC Front Side',
                                isOptional: false,
                                onCapture: () =>
                                    setState(() => _cnicFrontCaptured = true),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PhotoCaptureTile(
                              label: 'CNIC Back',
                              icon: Icons.credit_card_rounded,
                              isCaptured: _cnicBackCaptured,
                              isOptional: false,
                              onTap: () => _showImageSourceSheet(
                                label: 'CNIC Back Side',
                                isOptional: false,
                                onCapture: () =>
                                    setState(() => _cnicBackCaptured = true),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ─── Business Section ────────────────────────────
                      Row(
                        children: [
                          const _SectionHeader(label: 'Business'),
                          const Spacer(),
                          // "I am not a business person" checkbox
                          GestureDetector(
                            onTap: () => setState(
                                () => _isNotBusinessPerson =
                                    !_isNotBusinessPerson),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _isNotBusinessPerson
                                        ? const Color(0xFF285CCC)
                                        : Colors.white,
                                    border: Border.all(
                                      color: _isNotBusinessPerson
                                          ? const Color(0xFF285CCC)
                                          : const Color(0xFFE6EAF2),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _isNotBusinessPerson
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'I am not a\nbusiness person',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Business fields — hidden when toggle is on
                      AnimatedCrossFade(
                        firstChild: Column(
                          children: [
                            // Business Name
                            TextFormField(
                              controller: _businessNameController,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Color(0xFF1F2937),
                              ),
                              decoration: _fieldDecoration(
                                  'Enter your business name',
                                  Icons.storefront_outlined),
                              validator: (v) {
                                if (!_isNotBusinessPerson &&
                                    (v == null || v.trim().isEmpty)) {
                                  return 'Business name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Business Type dropdown (opens bottom sheet)
                            _DropdownField(
                              hint: 'What is your Business Type?',
                              value: _selectedBusinessType,
                              onTap: _showBusinessTypeSheet,
                            ),
                            const SizedBox(height: 12),

                            // Business Category (opens search screen)
                            _DropdownField(
                              hint: 'What is your Business Category?',
                              value: _selectedCategory,
                              onTap: _showCategoryScreen,
                            ),
                          ],
                        ),
                        secondChild: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2BD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF285CCC).withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'Business fields skipped. You can update your profile later.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        crossFadeState: _isNotBusinessPerson
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Start button ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: bizProvider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285CCC),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF285CCC).withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: bizProvider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF285CCC), size: 20),
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: Color(0xFF9CA3AF),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF285CCC), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Selection Screen with search
// ─────────────────────────────────────────────────────────────────────────────
class _CategorySelectScreen extends StatefulWidget {
  const _CategorySelectScreen();

  @override
  State<_CategorySelectScreen> createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends State<_CategorySelectScreen> {
  String _searchQuery = '';

  List<String> get _filtered => kBusinessCategories
      .where((c) =>
          c.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Category',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF285CCC)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF285CCC), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFE6EAF2),
              ),
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(
                    _filtered[i],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  onTap: () => Navigator.pop(context, _filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgressBar(
      {required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF285CCC)
                    : const Color(0xFFE6EAF2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
    );
  }
}

class _PhotoCaptureTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCaptured;
  final bool isOptional;
  final VoidCallback onTap;

  const _PhotoCaptureTile({
    required this.label,
    required this.icon,
    required this.isCaptured,
    required this.isOptional,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isCaptured ? const Color(0xFFEEF8F1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCaptured
                ? const Color(0xFF22C55E)
                : isOptional
                    ? const Color(0xFFE6EAF2)
                    : const Color(0xFFE6EAF2),
            width: isCaptured ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCaptured ? Icons.check_circle_rounded : icon,
              size: 32,
              color: isCaptured
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isCaptured
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF6B7280),
              ),
            ),
            if (isOptional && !isCaptured) ...[
              const SizedBox(height: 2),
              const Text(
                'optional',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? const Color(0xFF285CCC).withValues(alpha: 0.5)
                : const Color(0xFFE6EAF2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: value != null
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: value != null
                  ? const Color(0xFF285CCC)
                  : const Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFF6B7280)
        : const Color(0xFF285CCC);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
