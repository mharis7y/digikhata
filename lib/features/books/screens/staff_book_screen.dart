import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import 'add_staff_screen.dart';

class StaffBookScreen extends StatefulWidget {
  final bool isNested;
  const StaffBookScreen({super.key, this.isNested = false});

  @override
  State<StaffBookScreen> createState() => _StaffBookScreenState();
}

class _StaffBookScreenState extends State<StaffBookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadStaffData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: widget.isNested ? null : AppBar(
        backgroundColor: const Color(0xFF285CCC),
        elevation: 0,
        title: const Text('Staff Book', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (widget.isNested)
            Container(
              color: const Color(0xFF285CCC),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Attendance'),
                  Tab(text: 'Payroll'),
                ],
              ),
            ),
          Expanded(
            child: staffProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAttendanceTab(staffProvider),
                      _buildPayrollTab(staffProvider),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(StaffProvider provider) {
    if (provider.staffList.isEmpty) {
      return _buildEmptyState(
        'Manage your staff easily',
        '1. Add staff\n2. Mark daily attendance\n3. Manage salaries',
      );
    }

    return Column(
      children: [
        // Date Selector & Counters
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF285CCC)),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF285CCC), fontFamily: 'Poppins'),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF285CCC)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCounterCard('Total Present', provider.totalPresent, const Color(0xFF22C55E)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounterCard('Total Absent', provider.totalAbsent, const Color(0xFFEF4444)),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Staff List for Attendance
        Expanded(
          child: ListView.builder(
            itemCount: provider.staffList.length,
            itemBuilder: (context, index) {
              final staff = provider.staffList[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                    Row(
                      children: [
                        _buildAttendanceButton(provider, staff.id, 'present', 'P', const Color(0xFF22C55E)),
                        const SizedBox(width: 8),
                        _buildAttendanceButton(provider, staff.id, 'absent', 'A', const Color(0xFFEF4444)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
        // Add Staff Button
        _buildBottomAddButton('ADD STAFF'),
      ],
    );
  }

  Widget _buildAttendanceButton(StaffProvider provider, String staffId, String status, String label, Color color) {
    // Check current status for the selected date
    final isSelected = provider.attendanceList.any((a) => a.staffId == staffId && a.status == status && a.date.year == _selectedDate.year && a.date.month == _selectedDate.month && a.date.day == _selectedDate.day);
    return InkWell(
      onTap: () {
        provider.markAttendance(staffId, _selectedDate, status);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: isSelected ? color : const Color(0xFFE6EAF2)),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(count.toString(), style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPayrollTab(StaffProvider provider) {
    if (provider.staffList.isEmpty) {
      return _buildEmptyState('No Staff', 'Add staff to manage payroll.');
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: provider.staffList.length,
            itemBuilder: (context, index) {
              final staff = provider.staffList[index];
              return ListTile(
                title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${staff.salaryType} - Rs ${staff.salaryAmount}'),
                trailing: ElevatedButton(
                  onPressed: () {
                     // Simple dialog to add payroll
                     provider.addPayroll(staff.id, staff.salaryAmount, DateTime.now(), 'Salary');
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salary paid')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF285CCC)),
                  child: const Text('PAY', style: TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildBottomAddButton(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStaffScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.people_outline, size: 64, color: Color(0xFFE6EAF2)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStaffScreen()));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
          child: const Text('ADD STAFF', style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
