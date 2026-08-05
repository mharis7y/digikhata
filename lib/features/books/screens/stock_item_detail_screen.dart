import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import 'stock_transaction_screen.dart';
import 'package:intl/intl.dart';

class StockItemDetailScreen extends StatefulWidget {
  final StockItem item;
  const StockItemDetailScreen({super.key, required this.item});

  @override
  State<StockItemDetailScreen> createState() => _StockItemDetailScreenState();
}

class _StockItemDetailScreenState extends State<StockItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadStockTransactions(widget.item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates to the item itself (like quantity)
    final provider = context.watch<StockProvider>();
    final currentItem = provider.items.firstWhere(
      (i) => i.id == widget.item.id,
      orElse: () => widget.item,
    );
    final transactions = provider.currentTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF4444), // Following the orange/red header in the screenshot
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentItem.name, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
            const Text('Click here to view settings', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Top Card
          Container(
            color: const Color(0xFFEF4444),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${currentItem.quantity.toStringAsFixed(0)} (pcs)', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const Text('Stock In Hand', style: TextStyle(color: Color(0xFF1F2937), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rs ${(currentItem.quantity * currentItem.sellingPrice).toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const Text('Stock Value', style: TextStyle(color: Color(0xFF1F2937), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
                ],
              ),
            ),
          ),
          
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Entries', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        SizedBox(width: 40, child: Text('In', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold))),
                        SizedBox(width: 40, child: Text('Out', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold))),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Transactions List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isOut = tx.transactionType == 'out';
                      
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(color: Color(0xFFE6EAF2))),
                        ),
                        child: Row(
                          children: [
                            // Left section
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('EEE, dd MMM yy • hh:mm a').format(tx.createdAt),
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                    ),
                                    const SizedBox(height: 4),
                                    if (tx.details != null && tx.details!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6EAF2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(tx.details!, style: const TextStyle(fontSize: 12)),
                                      ),
                                    const SizedBox(height: 4),
                                    if (tx.billNo != null && tx.billNo!.isNotEmpty)
                                      Text('Bill No. ${tx.billNo}', style: const TextStyle(fontSize: 12)),
                                    if (tx.partyName != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFEF4444)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: Color(0xFFEF4444)),
                                            const SizedBox(width: 4),
                                            Text(tx.partyName!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                            // In Section (Green block if in)
                            Container(
                              width: 60,
                              color: isOut ? Colors.transparent : const Color(0xFFDCFCE7), // Light green bg
                              alignment: Alignment.center,
                              child: isOut ? null : Text(
                                tx.quantity.toStringAsFixed(0),
                                style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            // Out Section
                            Container(
                              width: 60,
                              alignment: Alignment.center,
                              child: isOut ? Text(
                                tx.quantity.toStringAsFixed(0),
                                style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16),
                              ) : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => StockTransactionScreen(item: currentItem, transactionType: 'in')));
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text('IN / BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => StockTransactionScreen(item: currentItem, transactionType: 'out')));
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                    label: const Text('OUT / SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
}
