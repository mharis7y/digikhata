import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ExpenseAccount> _expenseAccounts = [];
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseAccount> get expenseAccounts => _expenseAccounts;
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double getTotalForAccount(String accountId) {
    return _expenses.where((e) => e.expenseAccountId == accountId).fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final accountsData = await _supabase
          .from('expense_accounts')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      _expenseAccounts = accountsData.map((json) => ExpenseAccount.fromJson(json)).toList();

      final expensesData = await _supabase
          .from('expenses')
          .select()
          .eq('owner_id', userId)
          .order('date', ascending: false);

      _expenses = expensesData.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createExpenseAccount(String name) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('expense_accounts').insert({
        'owner_id': userId,
        'name': name,
      }).select().single();

      _expenseAccounts.insert(0, ExpenseAccount.fromJson(data));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('expenses').insert({
        'owner_id': userId,
        'expense_account_id': expense.expenseAccountId,
        'category': expense.category,
        'amount': expense.amount,
        'note': expense.note,
        'date': expense.date.toIso8601String().split('T')[0],
        'party_id': expense.partyId,
        'bill_no': expense.billNo,
        'is_cash': expense.isCash,
        'image_url': expense.imageUrl,
        'voice_note_url': expense.voiceNoteUrl,
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
