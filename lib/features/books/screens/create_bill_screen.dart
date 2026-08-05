import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import '../providers/stock_provider.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../providers/cash_provider.dart';
import '../../party/providers/party_provider.dart';
import '../../party/models/party_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({super.key});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _discController = TextEditingController(text: '0');
  final TextEditingController _taxController = TextEditingController(text: '0');

  DateTime _selectedDate = DateTime.now();
  PartyModel? _selectedParty;
  List<BillItem> _items = [];
  String _paymentMode = 'Unpaid'; // 'Unpaid' or 'Cash'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final billsLength = context.read<BillProvider>().bills.length;
      _billNoController.text = (billsLength + 1).toString();
      context.read<PartyProvider>().loadParties();
      context.read<StockProvider>().loadStockItems();
    });
  }

  double get _itemsTotal => _items.fold(0.0, (sum, i) => sum + (i.quantity * i.price));

  double get _invoiceAmount {
    double total = _itemsTotal;
    double disc = double.tryParse(_discController.text) ?? 0.0;
    double tax = double.tryParse(_taxController.text) ?? 0.0;

    total = total - (total * (disc / 100));
    total = total + tax;
    return total;
  }

  void _selectParty() {
    final partyProvider = context.read<PartyProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Select Party', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: partyProvider.allParties.length,
                  itemBuilder: (context, index) {
                    final party = partyProvider.allParties[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF285CCC),
                        child: Text(party.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(party.name, style: const TextStyle(fontFamily: 'Poppins')),
                      subtitle: Text(party.type == PartyType.customer ? 'Customer' : 'Supplier'),
                      onTap: () {
                        setState(() {
                          _selectedParty = party;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItems() {
    final stockProvider = context.read<StockProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Select Stock Item', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: stockProvider.items.length,
                  itemBuilder: (context, index) {
                    final stockItem = stockProvider.items[index];
                    return ListTile(
                      title: Text(stockItem.name, style: const TextStyle(fontFamily: 'Poppins')),
                      subtitle: Text('Qty: ${stockItem.quantity} | Rate: Rs ${stockItem.sellingPrice}'),
                      onTap: () {
                        Navigator.pop(context);
                        _showQuantityDialog(stockItem);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuantityDialog(stockItem) {
    final qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Quantity for ${stockItem.name}'),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Quantity',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            TextButton(
              onPressed: () {
                final qty = double.tryParse(qtyController.text) ?? 1;
                setState(() {
                  _items.add(BillItem(
                    stockItemId: stockItem.id,
                    name: stockItem.name,
                    quantity: qty,
                    price: stockItem.sellingPrice,
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBill() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    final billProvider = context.read<BillProvider>();
    final cashProvider = context.read<CashProvider>();
    final stockProvider = context.read<StockProvider>();
    final partyProvider = context.read<PartyProvider>();

    final bill = Bill(
      id: '',
      ownerId: '',
      type: 'sale',
      billNo: _billNoController.text.trim(),
      partyId: _selectedParty?.id,
      partyName: _selectedParty?.name,
      partyPhone: _selectedParty?.phone,
      items: _items,
      totalAmount: _invoiceAmount,
      receivedAmount: _paymentMode == 'Cash' ? _invoiceAmount : 0.0,
      billDate: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await billProvider.createBill(bill, cashProvider, stockProvider, partyProvider);

    if (mounted) {
      Navigator.pop(context); // loading
      if (billProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(billProvider.errorMessage!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill saved successfully!')));
        Navigator.pop(context); // close screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        title: const Text('Create New Bill', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: Bill No and Date
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _billNoController,
                      decoration: InputDecoration(
                        labelText: 'Bill Number',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Color(0xFFEF4444)),
                            Text(DateFormat('dd MMM, yyyy').format(_selectedDate)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Party
              InkWell(
                onTap: _selectParty,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE6EAF2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedParty != null ? _selectedParty!.name : 'Add Party',
                        style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Add Items
              InkWell(
                onTap: _addItems,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE6EAF2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Items',
                        style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ),
              
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(
                      children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('ITEM', style: TextStyle(color: Colors.grey))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Qty', style: TextStyle(color: Colors.grey))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('RATE', style: TextStyle(color: Colors.grey))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('AMOUNT', style: TextStyle(color: Colors.grey))),
                      ],
                    ),
                    for (var item in _items)
                      TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item.name)),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${item.quantity}')),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${item.price}')),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${item.quantity * item.price}')),
                        ],
                      ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Disc and Tax
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Disc. %',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _taxController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Tax (Fixed)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Invoice Amount
              Row(
                children: [
                  const Text('Invoice Amount', style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'Poppins')),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE6EAF2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Rs ${_invoiceAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE6EAF2)),
              const SizedBox(height: 16),

              // Payment Mode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPaymentRadio('Unpaid'),
                  _buildPaymentRadio('Cash'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285CCC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveBill,
                  child: const Text('SAVE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentRadio(String mode) {
    return InkWell(
      onTap: () => setState(() => _paymentMode = mode),
      child: Row(
        children: [
          Radio<String>(
            value: mode,
            groupValue: _paymentMode,
            activeColor: const Color(0xFFEF4444),
            onChanged: (val) {
              if (val != null) setState(() => _paymentMode = val);
            },
          ),
          Text(mode, style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
