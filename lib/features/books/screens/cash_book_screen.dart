import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_provider.dart';
import 'add_cash_entry_screen.dart';
import 'package:intl/intl.dart';

class CashBookScreen extends StatefulWidget {
  final bool isNested;
  const CashBookScreen({super.key, this.isNested = false});

  @override
  State<CashBookScreen> createState() => _CashBookScreenState();
}

class _CashBookScreenState extends State<CashBookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CashProvider>().loadCashEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cashProvider = context.watch<CashProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: widget.isNested ? null : AppBar(
        backgroundColor: const Color(0xFF285CCC),
        elevation: 0,
        title: const Text('Cash Book', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            color: const Color(0xFF285CCC),
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('Cash in Hand', cashProvider.cashInHand, const Color(0xFFFFF2BD)),
                Container(width: 1, height: 40, color: Colors.white30),
                _buildSummaryItem('Today Balance', cashProvider.cashInHand, Colors.white), // Simplified for now
                Container(width: 1, height: 40, color: Colors.white30),
                Column(
                  children: const [
                    Icon(Icons.history, color: Colors.white),
                    SizedBox(height: 4),
                    Text('History', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins')),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: cashProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildEntriesList(cashProvider),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCashEntryScreen(type: 'cash_out')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444), // Error Red
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CASH OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCashEntryScreen(type: 'cash_in')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E), // Success Green
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CASH IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color amountColor) {
    return Column(
      children: [
        Text(
          'Rs ${amount.toStringAsFixed(0)}',
          style: TextStyle(color: amountColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildEntriesList(CashProvider provider) {
    if (provider.entries.isEmpty) {
      return const Center(child: Text('No cash entries found', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280))));
    }

    // Grouping by date isn't strictly required but let's just display as a list for now
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.entries.length,
      itemBuilder: (context, index) {
        final entry = provider.entries[index];
        final isCashIn = entry.type == 'cash_in';
        final amountColor = isCashIn ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
        final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(entry.createdAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
                  Text(entry.note ?? (isCashIn ? 'Cash In' : 'Cash Out'), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280), fontSize: 12)),
                ],
              ),
              Text(
                'Rs ${entry.amount.toStringAsFixed(0)}',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: amountColor),
              )
            ],
          ),
        );
      },
    );
  }
}
