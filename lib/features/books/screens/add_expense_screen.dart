import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseAccount? account;

  const AddExpenseScreen({super.key, this.account});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String _amountStr = '0';
  final _detailsController = TextEditingController();
  final _billNoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isCash = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _detailsController.dispose();
    _billNoController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'AC') {
        _amountStr = '0';
      } else if (key == 'backspace') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (key == '=') {
        // Implement evaluation if needed, keeping simple for now
      } else if (key == 'Enter') {
        // hide calculator or move focus
      } else {
        if (_amountStr == '0' && key != '.') {
          _amountStr = key;
        } else {
          _amountStr += key;
        }
      }
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    if (widget.account == null) {
      // For global add, we need to enforce selecting an account, but in this workflow
      // we assume it's accessed from the account screen. If not, show error for now.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense account required')));
      return;
    }

    setState(() => _isSaving = true);
    final expense = Expense(
      id: '',
      ownerId: '', // Filled by provider
      expenseAccountId: widget.account!.id,
      amount: amount,
      note: _detailsController.text.trim().isEmpty ? null : _detailsController.text.trim(),
      date: _selectedDate,
      billNo: _billNoController.text.trim().isEmpty ? null : _billNoController.text.trim(),
      isCash: _isCash,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await context.read<ExpenseProvider>().addExpense(expense);
    setState(() => _isSaving = false);

    if (context.read<ExpenseProvider>().errorMessage == null) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<ExpenseProvider>().errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB91C1C), // Dark red for expense
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Expense${widget.account != null ? ' - ${widget.account!.name}' : ''}', style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE6EAF2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Rs ', style: TextStyle(color: Colors.black54, fontSize: 20)),
                            Text(_amountStr, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        InkWell(
                          onTap: () => _onKeyPress('backspace'),
                          child: const Icon(Icons.backspace_outlined, color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Attach Voice Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE6EAF2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Attach Voice Note', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w500)),
                        Icon(Icons.mic_none, color: Color(0xFFB91C1C)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Details
                  TextField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      hintText: 'Enter details...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE6EAF2))),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select Party/Bank
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE6EAF2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.account_circle_outlined, color: Color(0xFFB91C1C)),
                        SizedBox(width: 12),
                        Text('Select Party/Bank', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE6EAF2)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFFB91C1C), size: 20),
                                const SizedBox(width: 8),
                                Text(DateFormat('dd MMM, yyyy').format(_selectedDate), style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                            if (picked != null) setState(() => _selectedTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE6EAF2)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: Color(0xFFB91C1C), size: 20),
                                const SizedBox(width: 8),
                                Text(_selectedTime.format(context), style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // PDF and Bill No
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE6EAF2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.attach_file, color: Color(0xFFB91C1C), size: 20),
                              SizedBox(width: 8),
                              Text('PDF/Photos', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _billNoController,
                          decoration: InputDecoration(
                            hintText: 'Add Bill No.',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE6EAF2))),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cash Checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isCash,
                          onChanged: (val) => setState(() => _isCash = val ?? false),
                          activeColor: const Color(0xFFB91C1C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Cash', style: TextStyle(fontSize: 16, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Save Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB91C1C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Calculator Area
          Container(
            color: const Color(0xFFE6EAF2),
            padding: const EdgeInsets.all(8),
            child: _buildCalculator(),
          )
        ],
      ),
    );
  }

  Widget _buildCalculator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildCalcBtn('AC', color: Colors.black54),
            _buildCalcBtn('M+', color: Colors.black54),
            _buildCalcBtn('M-', color: Colors.black54),
            _buildCalcBtn('backspace', isIcon: true, icon: Icons.backspace_outlined),
          ],
        ),
        Row(
          children: [
            _buildCalcBtn('%', color: Colors.black54),
            _buildCalcBtn('/', color: Colors.black54),
            _buildCalcBtn('x', color: Colors.black54),
            _buildCalcBtn('-', color: Colors.black54),
          ],
        ),
        Row(
          children: [
            _buildCalcBtn('7'),
            _buildCalcBtn('8'),
            _buildCalcBtn('9'),
            _buildCalcBtn('+', color: Colors.black54),
          ],
        ),
        Row(
          children: [
            _buildCalcBtn('4'),
            _buildCalcBtn('5'),
            _buildCalcBtn('6'),
            _buildCalcBtn('=', color: Colors.black54),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildCalcBtn('1'),
                      _buildCalcBtn('2'),
                      _buildCalcBtn('3'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalcBtn('0', flex: 2),
                      _buildCalcBtn('.'),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: InkWell(
                  onTap: () => _onKeyPress('Enter'),
                  child: Container(
                    height: 104, // Roughly 2 standard button heights
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.keyboard_return, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCalcBtn(String label, {int flex = 1, Color color = Colors.black87, bool isIcon = false, IconData? icon}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => _onKeyPress(label),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
              ]
            ),
            child: Center(
              child: isIcon
                  ? Icon(icon, color: Colors.black87)
                  : Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins')),
            ),
          ),
        ),
      ),
    );
  }
}
