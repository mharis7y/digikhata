import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import 'individual_bill_preview_screen.dart';

class IndividualBillScreen extends StatelessWidget {
  final Bill bill;
  const IndividualBillScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, dd MMM yy • hh:mm a').format(bill.billDate);
    final balance = bill.totalAmount - bill.receivedAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        title: Text('Bill # ${bill.billNo ?? bill.id.substring(0, 8)}', style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Business Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('My Business', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                          Text('Business Phone', style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins')),
                          Text('Business Address here', style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EAF2),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(Icons.store, color: Color(0xFF9CA3AF), size: 32),
                    )
                  ],
                ),
              ),
              const Divider(color: Color(0xFFE6EAF2)),

              // Bill Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Bill # ${bill.billNo ?? bill.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Poppins')),
                    const SizedBox(height: 4),
                    Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins')),
                  ],
                ),
              ),

              // Customer Info
              if (bill.partyName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 80, child: Text('Customer:', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'))),
                          Text(bill.partyName!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(width: 80, child: Text('Phone:', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'))),
                          Text(bill.partyPhone ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              
              // Items Table
              Container(
                color: const Color(0xFFF7F9FC),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: const [
                    Expanded(flex: 3, child: Text('ITEM', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'))),
                    Expanded(flex: 1, child: Text('Qty', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'))),
                    Expanded(flex: 2, child: Text('RATE', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'))),
                    Expanded(flex: 2, child: Text('AMOUNT', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              
              ...bill.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(item.name, style: const TextStyle(fontFamily: 'Poppins'))),
                    Expanded(flex: 1, child: Text('${item.quantity}', style: const TextStyle(fontFamily: 'Poppins'))),
                    Expanded(flex: 2, child: Text('${item.price}', style: const TextStyle(fontFamily: 'Poppins'))),
                    Expanded(flex: 2, child: Text('${item.quantity * item.price}', style: const TextStyle(fontFamily: 'Poppins'), textAlign: TextAlign.right)),
                  ],
                ),
              )).toList(),
              
              const Divider(color: Color(0xFFE6EAF2)),
              
              // Totals
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                        Text('Rs ${bill.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Received', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                        Text('${bill.receivedAmount}', style: const TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                        Text('Rs $balance', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF285CCC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => IndividualBillPreviewScreen(bill: bill)),
              );
            },
            child: const Text('PREVIEW', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ),
        ),
      ),
    );
  }
}
