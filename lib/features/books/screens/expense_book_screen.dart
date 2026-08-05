import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'package:intl/intl.dart';

class ExpenseBookScreen extends StatefulWidget {
  final bool isNested;
  const ExpenseBookScreen({super.key, this.isNested = false});

  @override
  State<ExpenseBookScreen> createState() => _ExpenseBookScreenState();
}

class _ExpenseBookScreenState extends State<ExpenseBookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: widget.isNested ? null : AppBar(
        backgroundColor: const Color(0xFF285CCC),
        elevation: 0,
        title: const Text('Expense Book', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Total Expenses Banner
          Container(
            color: const Color(0xFF285CCC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Expenses', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins')),
                  Text(
                    'Rs ${expenseProvider.totalExpenses.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFFFF2BD), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: expenseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildExpenseList(expenseProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFEF4444),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD EXPENSE', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildExpenseList(ExpenseProvider provider) {
    if (provider.expenses.isEmpty) {
      return const Center(child: Text('No expenses found', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280))));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.expenses.length,
      itemBuilder: (context, index) {
        final expense = provider.expenses[index];
        final dateStr = DateFormat('dd MMM yyyy').format(expense.date);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.category, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Text(expense.note!, style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF9CA3AF), fontSize: 12)),
                ],
              ),
              Text(
                'Rs ${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEF4444)),
              )
            ],
          ),
        );
      },
    );
  }
}
