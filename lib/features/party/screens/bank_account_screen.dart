import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/party_provider.dart';

/// Bank Account Screen — allows user to select a bank and add account details.
/// Per agents.md: select bank from list → add Account Title + Account Number
class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _accountNumberController = TextEditingController();
  String? _selectedBank;
  bool _isSaving = false;

  // Popular banks list
  static const List<Map<String, String>> _banks = [
    {'name': 'HBL', 'full': 'Habib Bank Limited', 'icon': '🏦'},
    {'name': 'MCB', 'full': 'MCB Bank Limited', 'icon': '🏛️'},
    {'name': 'UBL', 'full': 'United Bank Limited', 'icon': '🏢'},
    {'name': 'Allied Bank', 'full': 'Allied Bank Limited', 'icon': '🏦'},
    {'name': 'Meezan Bank', 'full': 'Meezan Bank Limited', 'icon': '🌙'},
    {'name': 'Bank Alfalah', 'full': 'Bank Alfalah Limited', 'icon': '🏦'},
    {'name': 'Faysal Bank', 'full': 'Faysal Bank Limited', 'icon': '🏛️'},
    {'name': 'Standard Chartered', 'full': 'Standard Chartered Bank', 'icon': '🌐'},
    {'name': 'Askari Bank', 'full': 'Askari Bank Limited', 'icon': '🏦'},
    {'name': 'Bank Al Habib', 'full': 'Bank Al Habib Limited', 'icon': '🏢'},
    {'name': 'Silkbank', 'full': 'Silkbank Limited', 'icon': '🏦'},
    {'name': 'Summit Bank', 'full': 'Summit Bank Limited', 'icon': '🏛️'},
    {'name': 'JS Bank', 'full': 'JS Bank Limited', 'icon': '🏦'},
    {'name': 'Other', 'full': 'Other Bank', 'icon': '🏦'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<PartyProvider>();
    final success = await provider.addBankAccount(
      bankName: _selectedBank!,
      accountTitle: _titleController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to add bank account'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Bank Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Select Bank ─────────────────────────────────────────────
              const Text(
                'Select Bank',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),

              // Bank grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                ),
                itemCount: _banks.length,
                itemBuilder: (context, index) {
                  final bank = _banks[index];
                  final isSelected = _selectedBank == bank['name'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedBank = bank['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF285CCC)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF285CCC)
                              : const Color(0xFFE6EAF2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF285CCC)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            bank['icon']!,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bank['name']!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ─── Account Title ────────────────────────────────────────────
              const Text(
                'Account Title',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. Muhammad Ali',
                  hintStyle: const TextStyle(
                      fontFamily: 'Poppins', color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE6EAF2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE6EAF2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF285CCC), width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter account title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ─── Account Number ───────────────────────────────────────────
              const Text(
                'Account Number',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. 1234567890123456',
                  hintStyle: const TextStyle(
                      fontFamily: 'Poppins', color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE6EAF2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE6EAF2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF285CCC), width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ─── Save Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285CCC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'SAVE BANK ACCOUNT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
