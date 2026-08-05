import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> loadExpenses() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('expenses')
          .select()
          .eq('owner_id', userId)
          .order('date', ascending: false);

      _expenses = data.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('expenses').insert({
        'owner_id': userId,
        'category': expense.category,
        'amount': expense.amount,
        'note': expense.note,
        'date': expense.date.toIso8601String().split('T')[0],
      }).select().single();

      _expenses.insert(0, Expense.fromJson(data));
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
}
