import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import 'add_stock_item_screen.dart';
import 'stock_item_detail_screen.dart';

class StockBookScreen extends StatefulWidget {
  final bool isNested;
  const StockBookScreen({super.key, this.isNested = false});

  @override
  State<StockBookScreen> createState() => _StockBookScreenState();
}

class _StockBookScreenState extends State<StockBookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadStockItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: widget.isNested ? null : AppBar(
        backgroundColor: const Color(0xFF285CCC),
        elevation: 0,
        title: const Text('Stock Book', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2BD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'STOCK VALUE',
                  style: TextStyle(
                    color: Color(0xFF285CCC),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Total Items Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Items: ${stockProvider.items.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'View Rate List',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
              ],
            ),
          ),
          
          // Show local tabs if nested, otherwise it would have been in the Appbar
          if (widget.isNested)
            Container(
              color: const Color(0xFF285CCC),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'All Items'),
                  Tab(text: 'Low Stock'),
                ],
              ),
            ),

          Expanded(
            child: stockProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildItemList(stockProvider.items),
                      _buildItemList(stockProvider.lowStockItems),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFEF4444), // Red brand color from UI
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStockItemScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD ITEM', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      ),
    );
  }

  Widget _buildItemList(List items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No items found',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF6B7280)),
        ),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StockItemDetailScreen(item: item)),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE6EAF2))),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EAF2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 20, color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs ${item.sellingPrice}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const Text(
                      'Pieces (pcs)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
