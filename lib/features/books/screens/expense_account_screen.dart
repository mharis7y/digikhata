import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'package:intl/intl.dart';

class ExpenseAccountScreen extends StatelessWidget {
  final ExpenseAccount account;

  const ExpenseAccountScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.expenses.where((e) => e.expenseAccountId == account.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF4444),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.name, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 18)),
            const Text('Click here to edit', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Security Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('Only you can see these entries', style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Poppins', fontSize: 14)),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: expenses.isEmpty
                ? _buildEmptyState()
                : _buildExpenseList(expenses),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(account: account)));
                },
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                label: const Text('EXPENSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB91C1C), // Dark red for expense button
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: const [
        Text('Add Expense', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontFamily: 'Poppins')),
        SizedBox(height: 16),
        Icon(Icons.arrow_downward, color: Color(0xFFEF4444), size: 48),
        SizedBox(height: 48),
      ],
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6EAF2))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('dd MMM yyyy, hh:mm a').format(expense.createdAt), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontFamily: 'Poppins')),
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(expense.note!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                  ]
                ],
              ),
              Text(
                'Rs ${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEF4444), fontFamily: 'Poppins'),
              )
            ],
          ),
        );
      },
    );
  }
}
