class CashEntry {
  final String id;
  final String ownerId;
  final String type; // 'cash_in' or 'cash_out'
  final double amount;
  final String? note;
  final String? linkedBillId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CashEntry({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.amount,
    this.note,
    this.linkedBillId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashEntry.fromJson(Map<String, dynamic> json) {
    return CashEntry(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      linkedBillId: json['linked_bill_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      if (note != null) 'note': note,
      if (linkedBillId != null) 'linked_bill_id': linkedBillId,
    };
  }
}
