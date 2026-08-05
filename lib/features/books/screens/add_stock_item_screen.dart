import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';

class AddStockItemScreen extends StatefulWidget {
  const AddStockItemScreen({super.key});

  @override
  State<AddStockItemScreen> createState() => _AddStockItemScreenState();
}

class _AddStockItemScreenState extends State<AddStockItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    _quantityController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    final provider = context.read<StockProvider>();
    final item = StockItem(
      id: '', // Will be assigned by backend
      ownerId: '', // Will be assigned by backend
      name: _nameController.text.trim(),
      sellingPrice: double.parse(_sellingPriceController.text.trim()),
      purchasePrice: _purchasePriceController.text.isNotEmpty ? double.parse(_purchasePriceController.text.trim()) : null,
      quantity: _quantityController.text.isNotEmpty ? double.parse(_quantityController.text.trim()) : 0,
      lowStockWarning: _lowStockController.text.isNotEmpty ? double.parse(_lowStockController.text.trim()) : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await provider.addStockItem(item);

    setState(() => _isSaving = false);

    if (provider.errorMessage == null) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Item', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Selling Price',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixText: 'Rs ',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purchasePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Purchase Price (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixText: 'Rs ',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Opening Quantity (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lowStockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Low Stock Warning (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285CCC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
