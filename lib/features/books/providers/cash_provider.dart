import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cash_entry.dart';

class CashProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<CashEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CashEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get cashInHand {
    return _entries.fold(0.0, (sum, entry) {
      if (entry.type == 'cash_in') return sum + entry.amount;
      if (entry.type == 'cash_out') return sum - entry.amount;
      return sum;
    });
  }

  double get totalCashIn => _entries.where((e) => e.type == 'cash_in').fold(0.0, (s, e) => s + e.amount);
  double get totalCashOut => _entries.where((e) => e.type == 'cash_out').fold(0.0, (s, e) => s + e.amount);

  Future<void> loadCashEntries() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('cash_entries')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      _entries = data.map((json) => CashEntry.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCashEntry({
    required String type,
    required double amount,
    String? note,
    String? linkedBillId,
  }) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('cash_entries').insert({
        'owner_id': userId,
        'type': type,
        'amount': amount,
        'note': note,
        'linked_bill_id': linkedBillId,
      }).select().single();

      _entries.insert(0, CashEntry.fromJson(data));
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
