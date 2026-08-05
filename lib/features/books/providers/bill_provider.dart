import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bill.dart';
import 'cash_provider.dart';
import 'stock_provider.dart';
import '../../party/providers/party_provider.dart';
import '../../party/models/ledger_entry_model.dart';

class BillProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalSaleAmount => _bills.where((b) => b.type == 'sale').fold(0.0, (sum, b) => sum + b.totalAmount);
  double get totalPurchaseAmount => _bills.where((b) => b.type == 'purchase').fold(0.0, (sum, b) => sum + b.totalAmount);

  Future<void> loadBills() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('bills')
          .select()
          .eq('owner_id', userId)
          .order('bill_date', ascending: false);

      _bills = data.map((json) => Bill.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createBill(Bill bill, CashProvider cashProvider, StockProvider stockProvider, PartyProvider partyProvider) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await _supabase.from('bills').insert({
        'owner_id': userId,
        'type': bill.type,
        'bill_no': bill.billNo,
        'party_id': bill.partyId,
        'party_name': bill.partyName,
        'party_phone': bill.partyPhone,
        'items': bill.items.map((i) => i.toJson()).toList(),
        'total_amount': bill.totalAmount,
        'received_amount': bill.receivedAmount,
        'bill_date': bill.billDate.toIso8601String(),
      }).select().single();

      final createdBill = Bill.fromJson(data);
      _bills.insert(0, createdBill);
      notifyListeners();

      // Automatically generate Cash Entry if receivedAmount > 0
      if (createdBill.receivedAmount > 0) {
        await cashProvider.addCashEntry(
          type: createdBill.type == 'sale' ? 'cash_in' : 'cash_out',
          amount: createdBill.receivedAmount,
          note: 'Bill',
          linkedBillId: createdBill.id,
        );
      }
      
      // Automatically update Stock Quantities
      for (var item in createdBill.items) {
        if (item.stockItemId != null) {
           final change = createdBill.type == 'sale' ? -item.quantity : item.quantity;
           await stockProvider.updateStockQuantity(item.stockItemId!, change);
        }
      }

      // Automatically update Party Ledger
      if (createdBill.partyId != null) {
        // You Gave goods
        await partyProvider.addLedgerEntry(
          partyId: createdBill.partyId!,
          entryType: EntryType.youGave,
          amount: createdBill.totalAmount,
          note: 'Bill #${createdBill.billNo ?? ""}',
        );

        // If cash received, You Got cash
        if (createdBill.receivedAmount > 0) {
           await partyProvider.addLedgerEntry(
             partyId: createdBill.partyId!,
             entryType: EntryType.youGot,
             amount: createdBill.receivedAmount,
             note: 'Payment for Bill #${createdBill.billNo ?? ""}',
           );
        }
      }

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
