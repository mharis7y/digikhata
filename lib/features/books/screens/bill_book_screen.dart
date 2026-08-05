import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import '../providers/bill_provider.dart';
import 'create_bill_screen.dart';
import 'individual_bill_screen.dart';
import 'package:intl/intl.dart';

class BillBookScreen extends StatefulWidget {
  final bool isNested;
  const BillBookScreen({super.key, this.isNested = false});

  @override
  State<BillBookScreen> createState() => _BillBookScreenState();
}

class _BillBookScreenState extends State<BillBookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: widget.isNested ? null : AppBar(
        backgroundColor: const Color(0xFF285CCC),
        elevation: 0,
        title: const Text('Bill Book', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Total Sales Banner
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
                  const Text('Total Sale', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins')),
                  Text(
                    'Rs ${billProvider.totalSaleAmount.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFFFF2BD), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: billProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBillsList(billProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFEF4444),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateBillScreen()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('CREATE NEW BILL', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildBillsList(BillProvider provider) {
    if (provider.bills.isEmpty) {
      return const Center(
        child: Text('No bills found', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.bills.length,
      itemBuilder: (context, index) {
        final bill = provider.bills[index];
        final dateStr = DateFormat('EEE, dd MMM yy • hh:mm a').format(bill.billDate);
        final color = bill.type == 'sale' ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => IndividualBillScreen(bill: bill)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill # ${bill.billNo ?? bill.id.substring(0, 8)}',
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Rs ${bill.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr, 
                      style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
                if (bill.partyName != null && bill.partyName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2BD).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF285CCC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 14, color: Color(0xFF285CCC)),
                        const SizedBox(width: 4),
                        Text(
                          bill.partyName!, 
                          style: const TextStyle(color: Color(0xFF285CCC), fontSize: 12, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
