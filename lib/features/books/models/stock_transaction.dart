class StockTransaction {
  final String id;
  final String ownerId;
  final String stockItemId;
  final String transactionType; // 'in' or 'out'
  final double quantity;
  final double rate;
  final double amount;
  final String? details;
  final String? partyId;
  final String? partyName; // Optional, might be populated when joining with parties table
  final String? billNo;
  final DateTime createdAt;

  StockTransaction({
    required this.id,
    required this.ownerId,
    required this.stockItemId,
    required this.transactionType,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.details,
    this.partyId,
    this.partyName,
    this.billNo,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'],
      ownerId: json['owner_id'],
      stockItemId: json['stock_item_id'],
      transactionType: json['transaction_type'],
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      details: json['details'],
      partyId: json['party_id'],
      // Supabase join notation logic if included:
      partyName: json['parties'] != null ? json['parties']['name'] : null,
      billNo: json['bill_no'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'stock_item_id': stockItemId,
      'transaction_type': transactionType,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'details': details,
      'party_id': partyId,
      'bill_no': billNo,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
