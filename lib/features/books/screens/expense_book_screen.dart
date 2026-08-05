import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';
import 'expense_account_screen.dart';

class ExpenseBookScreen extends StatefulWidget {
  final bool isNested;
  const ExpenseBookScreen({super.key, this.isNested = false});

  @override
  State<ExpenseBookScreen> createState() => _ExpenseBookScreenState();
}

class _ExpenseBookScreenState extends State<ExpenseBookScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Create Expense Account', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins')),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'shop expense',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      await context.read<ExpenseProvider>().createExpenseAccount(nameController.text.trim());
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: widget.isNested ? null : AppBar(
        backgroundColor: const Color(0xFFEF4444),
        elevation: 0,
        title: const Text('Expense', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: expenseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenseProvider.expenseAccounts.isEmpty
              ? _buildEmptyState(context)
              : _buildFilledState(context, expenseProvider),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total expense for ${DateFormat('MMMM').format(DateTime.now())}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontFamily: 'Poppins')),
              const Text('Rs 0', style: TextStyle(color: Color(0xFFEF4444), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long, size: 80, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(height: 32),
              const Text('1- Create expense accounts', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontFamily: 'Poppins')),
              const SizedBox(height: 12),
              const Text('2- Manage your expense', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontFamily: 'Poppins')),
              const SizedBox(height: 12),
              const Text('3- Keep record of all expenses', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontFamily: 'Poppins')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateAccountDialog(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilledState(BuildContext context, ExpenseProvider provider) {
    return Column(
      children: [
        // Top search bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE6EAF2))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.filter_alt_outlined, color: Color(0xFFEF4444)),
            ],
          ),
        ),
        // List of accounts
        Expanded(
          child: ListView.separated(
            itemCount: provider.expenseAccounts.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE6EAF2)),
            itemBuilder: (context, index) {
              final account = provider.expenseAccounts[index];
              final total = provider.getTotalForAccount(account.id);
              final timeStr = DateFormat('hh:mm a').format(account.createdAt);
              
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseAccountScreen(account: account)));
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EAF2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            account.name.substring(0, 2).toUpperCase(),
                            style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                            const SizedBox(height: 4),
                            Text('Today • $timeStr', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                      Text(
                        'Rs ${total.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEF4444), fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Create account button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateAccountDialog(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
