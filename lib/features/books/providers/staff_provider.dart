import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff.dart';

class StaffProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Staff> _staffList = [];
  List<StaffAttendance> _attendanceList = [];
  List<StaffPayroll> _payrollList = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Staff> get staffList => _staffList;
  List<StaffAttendance> get attendanceList => _attendanceList;
  List<StaffPayroll> get payrollList => _payrollList;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalPresent => _attendanceList.where((a) => a.status == 'present').length;
  int get totalAbsent => _attendanceList.where((a) => a.status == 'absent').length;

  Future<void> loadStaffData() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final staffData = await _supabase
          .from('staff')
          .select()
          .eq('owner_id', userId)
          .order('name', ascending: true);
      _staffList = staffData.map((json) => Staff.fromJson(json)).toList();

      final attData = await _supabase
          .from('staff_attendance')
          .select()
          .eq('owner_id', userId)
          .order('date', ascending: false);
      _attendanceList = attData.map((json) => StaffAttendance.fromJson(json)).toList();

      final payData = await _supabase
          .from('staff_payroll')
          .select()
          .eq('owner_id', userId)
          .order('date', ascending: false);
      _payrollList = payData.map((json) => StaffPayroll.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addStaff(Staff staff) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('staff').insert({
        'owner_id': userId,
        'name': staff.name,
        'phone': staff.phone,
        'cnic': staff.cnic,
        'salary_type': staff.salaryType,
        'salary_amount': staff.salaryAmount,
        'working_hours': staff.workingHours,
        'joining_date': staff.joiningDate?.toIso8601String().split('T')[0],
      }).select().single();

      _staffList.add(Staff.fromJson(data));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAttendance(String staffId, DateTime date, String status) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('staff_attendance').upsert({
        'owner_id': userId,
        'staff_id': staffId,
        'date': date.toIso8601String().split('T')[0],
        'status': status,
      }, onConflict: 'staff_id, date').select().single();

      final updated = StaffAttendance.fromJson(data);
      final index = _attendanceList.indexWhere((a) => a.staffId == staffId && a.date.year == date.year && a.date.month == date.month && a.date.day == date.day);
      if (index != -1) {
        _attendanceList[index] = updated;
      } else {
        _attendanceList.insert(0, updated);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addPayroll(String staffId, double amount, DateTime date, String? note) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('staff_payroll').insert({
        'owner_id': userId,
        'staff_id': staffId,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'note': note,
      }).select().single();

      _payrollList.insert(0, StaffPayroll.fromJson(data));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  int getWorkingDaysForMonth(String staffId, int year, int month) {
    return _attendanceList.where((a) => 
      a.staffId == staffId && 
      a.date.year == year && 
      a.date.month == month && 
      a.status == 'present'
    ).length;
  }

  double calculateNetSalary(Staff staff, int year, int month) {
    if (staff.salaryType == 'monthly') {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final workingDays = getWorkingDaysForMonth(staff.id, year, month);
      return (staff.salaryAmount / daysInMonth) * workingDays;
    }
    // For other types (weekly, daily, hourly), a different logic would apply.
    // For simplicity, falling back to basic calculation based on attendance
    if (staff.salaryType == 'daily') {
      final workingDays = getWorkingDaysForMonth(staff.id, year, month);
      return staff.salaryAmount * workingDays;
    }
    
    return staff.salaryAmount;
  }
}
