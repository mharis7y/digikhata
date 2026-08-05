import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../../party/providers/party_provider.dart';
import '../../party/models/party_model.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';

class StockTransactionScreen extends StatefulWidget {
  final StockItem item;
  final String transactionType; // 'in' or 'out'

  const StockTransactionScreen({super.key, required this.item, required this.transactionType});

  @override
  State<StockTransactionScreen> createState() => _StockTransactionScreenState();
}

class _StockTransactionScreenState extends State<StockTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  final _billNoController = TextEditingController();
  
  PartyModel? _selectedParty;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _rateController.text = widget.item.sellingPrice.toStringAsFixed(0);
    _qtyController.addListener(_calculateAmount);
    _rateController.addListener(_calculateAmount);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _amountController.dispose();
    _detailsController.dispose();
    _billNoController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    _amountController.text = (qty * rate).toStringAsFixed(0);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final stockProvider = context.read<StockProvider>();
    final partyProvider = context.read<PartyProvider>();

    final qty = double.parse(_qtyController.text);
    final rate = double.parse(_rateController.text);
    final amount = qty * rate;

    final transaction = StockTransaction(
      id: '',
      ownerId: '',
      stockItemId: widget.item.id,
      transactionType: widget.transactionType,
      quantity: qty,
      rate: rate,
      amount: amount,
      details: _detailsController.text.isNotEmpty ? _detailsController.text : null,
      billNo: _billNoController.text.isNotEmpty ? _billNoController.text : null,
      partyId: _selectedParty?.id,
      createdAt: DateTime.now(),
    );

    await stockProvider.addStockTransaction(
      transaction: transaction,
      partyProvider: partyProvider,
    );

    setState(() => _isSaving = false);

    if (stockProvider.errorMessage == null) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(stockProvider.errorMessage!)));
      }
    }
  }

  void _selectParty() {
    final partyProvider = context.read<PartyProvider>();
    final isOut = widget.transactionType == 'out';
    final parties = isOut ? partyProvider.customers : partyProvider.suppliers;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(isOut ? 'Select Customer' : 'Select Supplier', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: parties.length,
                itemBuilder: (ctx, idx) {
                  final party = parties[idx];
                  return ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF285CCC)),
                    title: Text(party.name),
                    onTap: () {
                      setState(() => _selectedParty = party);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOut = widget.transactionType == 'out';
    final mainColor = isOut ? const Color(0xFFEF4444) : const Color(0xFF22C55E); // Red for out, Green for in
    final title = isOut ? '${widget.item.name} - Out' : '${widget.item.name} - In';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Qty',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Rate',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      readOnly: true,
                      style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _detailsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Enter details...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE6EAF2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.calendar_today, size: 20, color: Color(0xFF6B7280)),
                          SizedBox(width: 8),
                          Text('Today'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE6EAF2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.access_time, size: 20, color: Color(0xFF6B7280)),
                          SizedBox(width: 8),
                          Text('Now'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.attach_file),
                      label: const Text('PDF/Photos'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _billNoController,
                      decoration: InputDecoration(
                        labelText: 'Add Bill No.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: _selectParty,
                icon: const Icon(Icons.person),
                label: Text(_selectedParty?.name ?? 'Select Party', style: const TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
