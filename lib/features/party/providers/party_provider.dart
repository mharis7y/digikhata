import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/party_model.dart';
import '../models/ledger_entry_model.dart';
import '../models/bank_account_model.dart';

/// PartyProvider manages the state for the entire Party module per agents.md:
/// - Customers list, Suppliers list, Bank Accounts list
/// - Ledger entries per party
/// - Balance totals (you will get / you will give)
/// Uses Provider (ChangeNotifier) — no Bloc per project rules.
class PartyProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── State ──────────────────────────────────────────────────────────────
  List<PartyModel> _customers = [];
  List<PartyModel> _suppliers = [];
  List<BankAccountModel> _banks = [];
  List<LedgerEntryModel> _currentLedgerEntries = [];

  bool _isLoading = false;
  bool _isLedgerLoading = false;
  String? _errorMessage;

  // ─── Getters ─────────────────────────────────────────────────────────────
  List<PartyModel> get customers => _customers;
  List<PartyModel> get suppliers => _suppliers;
  List<BankAccountModel> get banks => _banks;
  List<PartyModel> get allParties => [..._customers, ..._suppliers];
  List<LedgerEntryModel> get currentLedgerEntries => _currentLedgerEntries;

  bool get isLoading => _isLoading;
  bool get isLedgerLoading => _isLedgerLoading;
  String? get errorMessage => _errorMessage;

  // ─── Customer summary totals ─────────────────────────────────────────────
  double get customerTotalGive =>
      _customers.fold(0.0, (sum, p) => sum + p.youWillGive);
  double get customerTotalGet =>
      _customers.fold(0.0, (sum, p) => sum + p.youWillGet);

  // ─── Supplier summary totals ──────────────────────────────────────────────
  double get supplierTotalGive =>
      _suppliers.fold(0.0, (sum, p) => sum + p.youWillGive);
  double get supplierTotalGet =>
      _suppliers.fold(0.0, (sum, p) => sum + p.youWillGet);

  // ─── Load all parties for the current user ────────────────────────────────
  Future<void> loadParties() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('parties')
          .select()
          .eq('owner_id', userId)
          .order('name', ascending: true);

      final parties =
          (data as List).map((e) => PartyModel.fromJson(e)).toList();

      _customers =
          parties.where((p) => p.type == PartyType.customer).toList();
      _suppliers =
          parties.where((p) => p.type == PartyType.supplier).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load parties.');
      if (kDebugMode) debugPrint('PartyProvider.loadParties: $e');
    }
  }

  // ─── Load bank accounts ───────────────────────────────────────────────────
  Future<void> loadBanks() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('bank_accounts')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      _banks = (data as List).map((e) => BankAccountModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('PartyProvider.loadBanks: $e');
    }
  }

  // ─── Add a new party (customer or supplier) ───────────────────────────────
  Future<bool> addParty({
    required String name,
    String? phone,
    String? countryCode,
    required PartyType type,
  }) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('parties')
          .insert({
            'owner_id': userId,
            'name': name,
            'phone': phone,
            'country_code': countryCode,
            'type': type == PartyType.supplier ? 'supplier' : 'customer',
            'balance': 0.0,
          })
          .select()
          .single();

      final newParty = PartyModel.fromJson(response);

      if (type == PartyType.customer) {
        _customers = [..._customers, newParty]
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        _suppliers = [..._suppliers, newParty]
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add party.');
      if (kDebugMode) debugPrint('PartyProvider.addParty: $e');
      return false;
    }
  }

  // ─── Add a bank account ────────────────────────────────────────────────────
  Future<bool> addBankAccount({
    required String bankName,
    required String accountTitle,
    required String accountNumber,
  }) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('bank_accounts')
          .insert({
            'owner_id': userId,
            'bank_name': bankName,
            'account_title': accountTitle,
            'account_number': accountNumber,
          })
          .select()
          .single();

      _banks = [BankAccountModel.fromJson(response), ..._banks];
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add bank account.');
      if (kDebugMode) debugPrint('PartyProvider.addBankAccount: $e');
      return false;
    }
  }

  // ─── Load ledger entries for a specific party ─────────────────────────────
  Future<void> loadLedgerEntries(String partyId) async {
    _isLedgerLoading = true;
    notifyListeners();
    try {
      final data = await _supabase
          .from('ledger_entries')
          .select()
          .eq('party_id', partyId)
          .order('created_at', ascending: false);

      _currentLedgerEntries =
          (data as List).map((e) => LedgerEntryModel.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('PartyProvider.loadLedgerEntries: $e');
    } finally {
      _isLedgerLoading = false;
      notifyListeners();
    }
  }

  // ─── Add a ledger entry (You Gave / You Got) ─────────────────────────────
  Future<bool> addLedgerEntry({
    required String partyId,
    required EntryType entryType,
    required double amount,
    String? note,
    List<LinkedItem> items = const [],
  }) async {
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Fetch current party balance
      final partyData = await _supabase
          .from('parties')
          .select('balance')
          .eq('id', partyId)
          .single();

      final currentBalance = (partyData['balance'] as num).toDouble();

      // For Customers: You Got = credit (+), You Gave = debit (-)
      // For Suppliers: You Got = payment received (-), You Gave = purchase (+)
      // However the field perspective is from the BUSINESS:
      //   youGot (credit) = party paid you → balance goes up (positive)
      //   youGave (debit) = you gave to party → balance goes down (negative)
      final delta = entryType == EntryType.youGot ? amount : -amount;
      final newBalance = currentBalance + delta;

      // Insert ledger entry
      final response = await _supabase
          .from('ledger_entries')
          .insert({
            'party_id': partyId,
            'owner_id': userId,
            'entry_type': entryType == EntryType.youGot ? 'you_got' : 'you_gave',
            'amount': amount,
            'note': note,
            'items': items.map((e) => e.toJson()).toList(),
            'balance_after': newBalance,
          })
          .select()
          .single();

      // Update the party's running balance
      await _supabase
          .from('parties')
          .update({'balance': newBalance, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', partyId);

      // Update local state
      final newEntry = LedgerEntryModel.fromJson(response);
      _currentLedgerEntries = [newEntry, ..._currentLedgerEntries];

      // Update party balance locally
      _updatePartyBalance(partyId, newBalance);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to save entry.');
      if (kDebugMode) debugPrint('PartyProvider.addLedgerEntry: $e');
      return false;
    }
  }

  // ─── Delete a party ────────────────────────────────────────────────────────
  Future<bool> deleteParty(String partyId, PartyType type) async {
    try {
      await _supabase.from('parties').delete().eq('id', partyId);
      if (type == PartyType.customer) {
        _customers = _customers.where((p) => p.id != partyId).toList();
      } else {
        _suppliers = _suppliers.where((p) => p.id != partyId).toList();
      }
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('PartyProvider.deleteParty: $e');
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  void _updatePartyBalance(String partyId, double newBalance) {
    _customers = _customers
        .map((p) => p.id == partyId ? p.copyWith(balance: newBalance) : p)
        .toList();
    _suppliers = _suppliers
        .map((p) => p.id == partyId ? p.copyWith(balance: newBalance) : p)
        .toList();
  }

  void clearCurrentLedger() {
    _currentLedgerEntries = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
