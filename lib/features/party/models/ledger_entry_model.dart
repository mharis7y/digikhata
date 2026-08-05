/// EntryType — You Gave (debit, red) or You Got (credit, green).
enum EntryType { youGave, youGot }

/// LedgerEntryModel represents a single transaction entry in a party's ledger.
/// Supports amount, optional notes, and optional linked stock items.
class LedgerEntryModel {
  final String id;
  final String partyId;
  final String ownerId;
  final EntryType type;
  final double amount;
  final String? note;
  final List<LinkedItem> items; // linked stock items (optional)
  final double balanceAfter; // running balance after this entry
  final DateTime createdAt;

  const LedgerEntryModel({
    required this.id,
    required this.partyId,
    required this.ownerId,
    required this.type,
    required this.amount,
    this.note,
    this.items = const [],
    required this.balanceAfter,
    required this.createdAt,
  });

  bool get isCredit => type == EntryType.youGot;
  bool get isDebit => type == EntryType.youGave;

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return LedgerEntryModel(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      ownerId: json['owner_id'] as String,
      type: (json['entry_type'] as String) == 'you_got'
          ? EntryType.youGot
          : EntryType.youGave,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      items: rawItems
          .map((e) => LinkedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'party_id': partyId,
        'owner_id': ownerId,
        'entry_type': type == EntryType.youGot ? 'you_got' : 'you_gave',
        'amount': amount,
        'note': note,
        'items': items.map((e) => e.toJson()).toList(),
        'balance_after': balanceAfter,
        'created_at': createdAt.toIso8601String(),
      };
}

/// LinkedItem represents a stock item linked to a ledger entry.
class LinkedItem {
  final String? stockItemId;
  final String name;
  final double quantity;
  final double? rate;

  const LinkedItem({
    this.stockItemId,
    required this.name,
    required this.quantity,
    this.rate,
  });

  factory LinkedItem.fromJson(Map<String, dynamic> json) {
    return LinkedItem(
      stockItemId: json['stock_item_id'] as String?,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'stock_item_id': stockItemId,
        'name': name,
        'quantity': quantity,
        'rate': rate,
      };
}
