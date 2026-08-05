import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../books/models/bill.dart';
import '../../books/models/expense.dart';
import '../../books/models/staff.dart';

class DashboardProvider extends ChangeNotifier {
  String _selectedPeriod = 'Lifetime';

  String get selectedPeriod => _selectedPeriod;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  /// Generates chart data for Income and Expense.
  /// Returns a map with 'income' and 'expense' lists of FlSpots.
  Map<String, List<FlSpot>> generateChartData(
    List<Bill> bills,
    List<Expense> expenses,
    List<StaffPayroll> payrolls,
  ) {
    // For simplicity, we'll always show the last 6 months trend.
    // If _selectedPeriod is 'This Month', we could filter, but let's stick to last 6 months for trend line.
    
    final now = DateTime.now();
    final Map<int, double> incomeByMonth = {};
    final Map<int, double> expenseByMonth = {};

    // Initialize last 6 months (0 to 5)
    for (int i = 0; i < 6; i++) {
      incomeByMonth[i] = 0;
      expenseByMonth[i] = 0;
    }

    // Helper to get month index (0 = oldest, 5 = current month)
    int getMonthIndex(DateTime date) {
      final diffMonths = (now.year - date.year) * 12 + now.month - date.month;
      if (diffMonths >= 0 && diffMonths < 6) {
        return 5 - diffMonths;
      }
      return -1;
    }

    // Process Income (Bill Sales)
    for (var bill in bills.where((b) => b.type == 'sale')) {
      final idx = getMonthIndex(bill.billDate);
      if (idx != -1) {
        incomeByMonth[idx] = (incomeByMonth[idx] ?? 0) + bill.totalAmount;
      }
    }

    // Process Expense (Bill Purchases)
    for (var bill in bills.where((b) => b.type == 'purchase')) {
      final idx = getMonthIndex(bill.billDate);
      if (idx != -1) {
        expenseByMonth[idx] = (expenseByMonth[idx] ?? 0) + bill.totalAmount;
      }
    }

    // Process Expense (Expenses)
    for (var expense in expenses) {
      final idx = getMonthIndex(expense.date);
      if (idx != -1) {
        expenseByMonth[idx] = (expenseByMonth[idx] ?? 0) + expense.amount;
      }
    }

    // Process Expense (Payrolls)
    for (var payroll in payrolls) {
      final idx = getMonthIndex(payroll.date);
      if (idx != -1) {
        expenseByMonth[idx] = (expenseByMonth[idx] ?? 0) + payroll.amount;
      }
    }

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int i = 0; i < 6; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), incomeByMonth[i] ?? 0));
      expenseSpots.add(FlSpot(i.toDouble(), expenseByMonth[i] ?? 0));
    }

    return {
      'income': incomeSpots,
      'expense': expenseSpots,
    };
  }

  /// Get month labels for the X-axis of the chart.
  List<String> getMonthLabels() {
    final now = DateTime.now();
    final labels = <String>[];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    for (int i = 5; i >= 0; i--) {
      int month = now.month - i;
      if (month <= 0) month += 12;
      labels.add(monthNames[month - 1]);
    }
    return labels;
  }
}
