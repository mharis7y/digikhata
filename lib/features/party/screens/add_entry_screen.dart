import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/party_model.dart';
import '../models/ledger_entry_model.dart';
import '../providers/party_provider.dart';

/// Add Entry Screen per agents.md:
/// - Shows "You Got Rs X From {name}" or "You Gave Rs X To {name}"
/// - Amount input (Rs field with backspace calculator-style)
/// - Add Items (linked stock items)
/// - Note field
/// - Custom numpad with SAVE button
/// - Color: green for You Got, red for You Gave
class AddEntryScreen extends StatefulWidget {
  final PartyModel party;
  final EntryType entryType;

  const AddEntryScreen({
    super.key,
    required this.party,
    required this.entryType,
  });

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  String _amountStr = '';
  final _noteController = TextEditingController();
  bool _isSaving = false;

  bool get _isYouGot => widget.entryType == EntryType.youGot;
  Color get _themeColor =>
      _isYouGot ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

  double get _amount {
    if (_amountStr.isEmpty) return 0;
    return double.tryParse(_amountStr) ?? 0;
  }

  String get _title {
    final name = widget.party.name;
    if (_isYouGot) {
      return 'You Got Rs ${_amount > 0 ? _amount.toStringAsFixed(0) : '0'} From $name';
    } else {
      return 'You Gave Rs ${_amount > 0 ? _amount.toStringAsFixed(0) : '0'} To $name';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _appendDigit(String digit) {
    setState(() {
      if (digit == '.' && _amountStr.contains('.')) return;
      if (_amountStr.length >= 10) return;
      _amountStr += digit;
    });
  }

  void _backspace() {
    if (_amountStr.isNotEmpty) {
      setState(() => _amountStr = _amountStr.substring(0, _amountStr.length - 1));
    }
  }

  void _clear() {
    setState(() => _amountStr = '');
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<PartyProvider>();
    final success = await provider.addLedgerEntry(
      partyId: widget.party.id,
      entryType: widget.entryType,
      amount: _amount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save entry'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Amount Display + Fields ──────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Amount Field
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: _themeColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Rs',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _themeColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _amountStr.isEmpty ? '0' : _amountStr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _amountStr.isEmpty
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.backspace_rounded,
                            color: _themeColor,
                          ),
                          onPressed: _backspace,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Add Items Row
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Stock item linking coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: const Color(0xFFE6EAF2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Add Items',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: _themeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: _themeColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Note Field
                  TextField(
                    controller: _noteController,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add Note',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: _themeColor.withValues(alpha: 0.7),
                      ),
                      suffixIcon: Icon(Icons.mic_rounded, color: _themeColor),
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
                        borderSide:
                            BorderSide(color: _themeColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SAVE Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _themeColor.withValues(alpha: 0.5),
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
                              'SAVE',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Custom Numpad ─────────────────────────────────────────────
            Expanded(
              child: Container(
                color: const Color(0xFFF7F9FC),
                child: _NumPad(
                  onDigit: _appendDigit,
                  onBackspace: _backspace,
                  onClear: _clear,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Number Pad ─────────────────────────────────────────────────────────
class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const _NumPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      padding: const EdgeInsets.all(8),
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: [
        _NumKey(label: 'AC', onTap: onClear, isSpecial: true),
        _NumKey(label: 'M+', onTap: () {}, isSpecial: true),
        _NumKey(label: 'M-', onTap: () {}, isSpecial: true),
        _NumKey(
          icon: Icons.backspace_outlined,
          onTap: onBackspace,
          isSpecial: true,
        ),
        _NumKey(label: '%', onTap: () => onDigit('%'), isSpecial: true),
        _NumKey(label: '÷', onTap: () => onDigit('÷'), isSpecial: true),
        _NumKey(label: '×', onTap: () => onDigit('×'), isSpecial: true),
        _NumKey(label: '-', onTap: () => onDigit('-'), isSpecial: true),
        _NumKey(label: '7', onTap: () => onDigit('7')),
        _NumKey(label: '8', onTap: () => onDigit('8')),
        _NumKey(label: '9', onTap: () => onDigit('9')),
        _NumKey(label: '+', onTap: () => onDigit('+'), isSpecial: true),
        _NumKey(label: '4', onTap: () => onDigit('4')),
        _NumKey(label: '5', onTap: () => onDigit('5')),
        _NumKey(label: '6', onTap: () => onDigit('6')),
        _NumKey(label: '=', onTap: () {}, isSpecial: true),
        _NumKey(label: '1', onTap: () => onDigit('1')),
        _NumKey(label: '2', onTap: () => onDigit('2')),
        _NumKey(label: '3', onTap: () => onDigit('3')),
        _NumKey(label: '↵', onTap: () {}, isSpecial: true, rowSpan: 2),
        _NumKey(label: '0', onTap: () => onDigit('0'), colSpan: 2),
        _NumKey(label: '.', onTap: () => onDigit('.')),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSpecial;
  final int colSpan;
  final int rowSpan;

  const _NumKey({
    this.label,
    this.icon,
    required this.onTap,
    this.isSpecial = false,
    this.colSpan = 1,
    this.rowSpan = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSpecial ? const Color(0xFFE5E7EB) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: icon != null
              ? Icon(icon, color: const Color(0xFF374151), size: 22)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight:
                        isSpecial ? FontWeight.w500 : FontWeight.w400,
                    color: const Color(0xFF374151),
                  ),
                ),
        ),
      ),
    );
  }
}
