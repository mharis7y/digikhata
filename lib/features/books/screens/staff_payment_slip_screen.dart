import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/staff.dart';
import '../providers/staff_provider.dart';

class StaffPaymentSlipScreen extends StatefulWidget {
  final Staff staff;
  final double initialAmount;

  const StaffPaymentSlipScreen({super.key, required this.staff, required this.initialAmount});

  @override
  State<StaffPaymentSlipScreen> createState() => _StaffPaymentSlipScreenState();
}

class _StaffPaymentSlipScreenState extends State<StaffPaymentSlipScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.initialAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<StaffProvider>();
    await provider.addPayroll(widget.staff.id, amount, _selectedDate, _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null);
    
    setState(() => _isSaving = false);

    if (provider.errorMessage == null) {
      if (mounted) Navigator.pop(context); // Close the slip screen
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Payment Slip', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Staff Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6EAF2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person, size: 48, color: Color(0xFF285CCC)),
                  const SizedBox(height: 8),
                  Text(widget.staff.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins')),
                  Text(widget.staff.phone, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Payment Date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              ),
            ),
            const SizedBox(height: 16),
            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount Paid',
                prefixText: 'Rs ',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Note
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                prefixIcon: const Icon(Icons.notes_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SAVE PAYMENT', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
