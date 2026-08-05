import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../models/staff.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _salaryController = TextEditingController();
  DateTime _joiningDate = DateTime.now();
  String _salaryType = 'Monthly';
  bool _isSaving = false;

  final List<String> _salaryTypes = ['Monthly', 'Weekly', 'Daily', 'Hourly'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final provider = context.read<StaffProvider>();
    final staff = Staff(
      id: '',
      ownerId: '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      cnic: _cnicController.text.trim().isNotEmpty ? _cnicController.text.trim() : null,
      salaryType: _salaryType.toLowerCase(),
      salaryAmount: double.parse(_salaryController.text.trim()),
      joiningDate: _joiningDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await provider.addStaff(staff);
    setState(() => _isSaving = false);

    if (provider.errorMessage == null) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Staff', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
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
                  labelText: 'Staff Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cnicController,
                decoration: InputDecoration(
                  labelText: 'CNIC Number (Optional)',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Select Salary Type', style: TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _salaryTypes.map((type) => ChoiceChip(
                  label: Text(type),
                  selected: _salaryType == type,
                  onSelected: (selected) {
                    if (selected) setState(() => _salaryType = type);
                  },
                  selectedColor: const Color(0xFF285CCC).withOpacity(0.1),
                  labelStyle: TextStyle(color: _salaryType == type ? const Color(0xFF285CCC) : Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: _salaryType == type ? const Color(0xFF285CCC) : const Color(0xFFE6EAF2))
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Staff Salary',
                  prefixText: 'Rs ',
                  suffixText: '/$_salaryType',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Joining Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _joiningDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _joiningDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Joining Date',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('${_joiningDate.day}/${_joiningDate.month}/${_joiningDate.year}'),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF2BD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('SAVE', style: TextStyle(color: Color(0xFF285CCC), fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
