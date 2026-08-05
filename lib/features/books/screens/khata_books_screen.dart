import 'package:flutter/material.dart';
import 'cash_book_screen.dart';
import 'stock_book_screen.dart';
import 'bill_book_screen.dart';
import 'staff_book_screen.dart';
import 'expense_book_screen.dart';

class KhataBooksScreen extends StatefulWidget {
  final String initialTab;
  const KhataBooksScreen({super.key, required this.initialTab});

  @override
  State<KhataBooksScreen> createState() => _KhataBooksScreenState();
}

class _KhataBooksScreenState extends State<KhataBooksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    switch (widget.initialTab) {
      case 'cash':
        initialIndex = 0;
        break;
      case 'stock':
        initialIndex = 1;
        break;
      case 'bills':
        initialIndex = 2;
        break;
      case 'staff':
        initialIndex = 3;
        break;
      case 'expense':
        initialIndex = 4;
        break;
    }
    _tabController = TabController(length: 5, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Books', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Cash'),
            Tab(text: 'Stock'),
            Tab(text: 'Bills'),
            Tab(text: 'Staff'),
            Tab(text: 'Expense'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Wrapping each in a builder or passing a flag might be needed to avoid duplicate appbars,
          // but since they have their own Appbars, they'll just have nested appbars which looks like nested headers.
          // Let's modify the screens so their Scaffold's AppBar is conditionally rendered or we just let it be for now.
          // Actually, they use `Scaffold` which will take up the full space. 
          // We can let them have their own app bars, they will just be below the KhataBooks app bar.
          CashBookScreen(isNested: true),
          StockBookScreen(isNested: true),
          BillBookScreen(isNested: true),
          StaffBookScreen(isNested: true),
          ExpenseBookScreen(isNested: true),
        ],
      ),
    );
  }
}
