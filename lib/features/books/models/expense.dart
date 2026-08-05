class Expense {
  final String id;
  final String ownerId;
  final String category;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.ownerId,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      if (note != null) 'note': note,
      'date': date.toIso8601String().split('T')[0],
    };
  }
}
