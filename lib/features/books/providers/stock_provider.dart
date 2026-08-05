import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../../party/providers/party_provider.dart';
import '../../party/models/ledger_entry_model.dart';

class StockProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<StockItem> _items = [];
  List<StockTransaction> _currentTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StockItem> get items => _items;
  List<StockTransaction> get currentTransactions => _currentTransactions;
  List<StockItem> get lowStockItems => _items.where((i) => i.lowStockWarning != null && i.quantity <= i.lowStockWarning!).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalStockValue => _items.fold(0.0, (sum, item) => sum + (item.quantity * item.sellingPrice));

  Future<void> loadStockItems() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('stock_items')
          .select()
          .eq('owner_id', userId)
          .order('name', ascending: true);

      _items = data.map((json) => StockItem.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addStockItem(StockItem item) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('stock_items').insert({
        'owner_id': userId,
        'name': item.name,
        'selling_price': item.sellingPrice,
        'purchase_price': item.purchasePrice,
        'quantity': item.quantity,
        'low_stock_warning': item.lowStockWarning,
      }).select().single();

      _items.add(StockItem.fromJson(data));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> updateStockQuantity(String id, double changeAmount) async {
    try {
      final itemIndex = _items.indexWhere((i) => i.id == id);
      if (itemIndex == -1) return;
      
      final currentItem = _items[itemIndex];
      final newQuantity = currentItem.quantity + changeAmount;

      final data = await _supabase.from('stock_items').update({
        'quantity': newQuantity,
      }).eq('id', id).select().single();

      _items[itemIndex] = StockItem.fromJson(data);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStockTransactions(String itemId) async {
    _setLoading(true);
    _clearError();
    try {
      final data = await _supabase
          .from('stock_transactions')
          .select('*, parties(name)')
          .eq('stock_item_id', itemId)
          .order('created_at', ascending: false);

      _currentTransactions = data.map((json) => StockTransaction.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addStockTransaction({
    required StockTransaction transaction,
    PartyProvider? partyProvider,
  }) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // 1. Insert transaction
      final data = await _supabase.from('stock_transactions').insert({
        'owner_id': userId,
        'stock_item_id': transaction.stockItemId,
        'transaction_type': transaction.transactionType,
        'quantity': transaction.quantity,
        'rate': transaction.rate,
        'amount': transaction.amount,
        'details': transaction.details,
        'party_id': transaction.partyId,
        'bill_no': transaction.billNo,
      }).select('*, parties(name)').single();

      final newTransaction = StockTransaction.fromJson(data);
      _currentTransactions.insert(0, newTransaction);

      // 2. Update stock quantity
      final changeAmount = transaction.transactionType == 'in' ? transaction.quantity : -transaction.quantity;
      await updateStockQuantity(transaction.stockItemId, changeAmount);

      // 3. Update party ledger if applicable
      if (transaction.partyId != null && partyProvider != null) {
        // According to user feedback:
        // Stock In (Buy from Supplier) -> We pay cash -> You Gave
        // Stock Out (Sell to Customer) -> We receive cash -> You Got
        final entryType = transaction.transactionType == 'in' ? EntryType.youGave : EntryType.youGot;
        await partyProvider.addLedgerEntry(
          partyId: transaction.partyId!,
          entryType: entryType,
          amount: transaction.amount,
          note: 'Stock ${transaction.transactionType.toUpperCase()} - ${transaction.details ?? ""}',
        );
      }

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
