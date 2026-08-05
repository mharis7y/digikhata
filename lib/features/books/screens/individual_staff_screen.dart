import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/staff.dart';
import '../providers/staff_provider.dart';
import 'staff_payment_slip_screen.dart';

class IndividualStaffScreen extends StatefulWidget {
  final Staff staff;

  const IndividualStaffScreen({super.key, required this.staff});

  @override
  State<IndividualStaffScreen> createState() => _IndividualStaffScreenState();
}

class _IndividualStaffScreenState extends State<IndividualStaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final provider = context.watch<StaffProvider>();
    final workingDays = provider.getWorkingDaysForMonth(widget.staff.id, _selectedDate.year, _selectedDate.month);
    final netSalary = provider.calculateNetSalary(widget.staff, _selectedDate.year, _selectedDate.month);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.staff.name, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            color: const Color(0xFF285CCC),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Working Days', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('$workingDays Days', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Net Salary', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('Rs ${netSalary.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF285CCC),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Attendance'),
                Tab(text: 'Payments'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAttendanceTab(provider),
                _buildPaymentsTab(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(StaffProvider provider) {
    // Calculate summary for selected month
    int present = 0;
    int halfDay = 0;
    int absent = 0;
    int late = 0;

    for (var a in provider.attendanceList) {
      if (a.staffId == widget.staff.id && a.date.year == _selectedDate.year && a.date.month == _selectedDate.month) {
        if (a.status == 'present') present++;
        else if (a.status == 'half_day') halfDay++;
        else if (a.status == 'absent') absent++;
        else if (a.status == 'late') late++;
      }
    }

    return Column(
      children: [
        // Month Selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: InkWell(
            onTap: () => _selectDate(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF285CCC)),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF285CCC), fontFamily: 'Poppins'),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF285CCC)),
              ],
            ),
          ),
        ),
        // Summary Cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _buildSummaryCard('Present', present, const Color(0xFF22C55E))),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Half Day', halfDay, const Color(0xFFF59E0B))),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Absent', absent, const Color(0xFFEF4444))),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Late', late, const Color(0xFF3B82F6))),
            ],
          ),
        ),
        const Spacer(),
        // Mark Attendance Card for Today
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mark Attendance - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBigAttendanceButton(provider, 'present', 'Present', const Color(0xFF22C55E)),
                  _buildBigAttendanceButton(provider, 'half_day', 'Half Day', const Color(0xFFF59E0B)),
                  _buildBigAttendanceButton(provider, 'absent', 'Absent', const Color(0xFFEF4444)),
                  _buildBigAttendanceButton(provider, 'late', 'Late', const Color(0xFF3B82F6)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(count.toString(), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBigAttendanceButton(StaffProvider provider, String status, String label, Color color) {
    final today = DateTime.now();
    final isSelected = provider.attendanceList.any((a) => a.staffId == widget.staff.id && a.status == status && a.date.year == today.year && a.date.month == today.month && a.date.day == today.day);
    
    return InkWell(
      onTap: () {
        provider.markAttendance(widget.staff.id, today, status);
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              border: Border.all(color: isSelected ? color : const Color(0xFFE6EAF2)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getIconForStatus(status),
                color: isSelected ? Colors.white : color,
              )
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: isSelected ? color : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'present': return Icons.check;
      case 'half_day': return Icons.timelapse;
      case 'absent': return Icons.close;
      case 'late': return Icons.access_time;
      default: return Icons.check;
    }
  }

  Widget _buildPaymentsTab(StaffProvider provider) {
    final payments = provider.payrollList.where((p) => p.staffId == widget.staff.id).toList();

    return Column(
      children: [
        Expanded(
          child: payments.isEmpty
              ? const Center(child: Text('No payments recorded yet', style: TextStyle(color: Colors.black54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE6EAF2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(payment.note ?? 'Salary Payment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                          Text(
                            'Rs ${payment.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444), fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final netSalary = provider.calculateNetSalary(widget.staff, _selectedDate.year, _selectedDate.month);
              Navigator.push(context, MaterialPageRoute(builder: (_) => StaffPaymentSlipScreen(staff: widget.staff, initialAmount: netSalary)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF285CCC),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('GIVE SALARY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ),
        )
      ],
    );
  }
}
