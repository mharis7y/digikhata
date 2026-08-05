class ExpenseAccount {
  final String id;
  final String ownerId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseAccount({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseAccount.fromJson(Map<String, dynamic> json) {
    return ExpenseAccount(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Expense {
  final String id;
  final String ownerId;
  final String? expenseAccountId;
  final String? category;
  final double amount;
  final String? note;
  final DateTime date;
  final String? partyId;
  final String? billNo;
  final bool isCash;
  final String? imageUrl;
  final String? voiceNoteUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.ownerId,
    this.expenseAccountId,
    this.category,
    required this.amount,
    this.note,
    required this.date,
    this.partyId,
    this.billNo,
    this.isCash = true,
    this.imageUrl,
    this.voiceNoteUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      expenseAccountId: json['expense_account_id'] as String?,
      category: json['category'] as String?,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      partyId: json['party_id'] as String?,
      billNo: json['bill_no'] as String?,
      isCash: json['is_cash'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      voiceNoteUrl: json['voice_note_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (expenseAccountId != null) 'expense_account_id': expenseAccountId,
      if (category != null) 'category': category,
      'amount': amount,
      if (note != null) 'note': note,
      'date': date.toIso8601String().split('T')[0],
      if (partyId != null) 'party_id': partyId,
      if (billNo != null) 'bill_no': billNo,
      'is_cash': isCash,
      if (imageUrl != null) 'image_url': imageUrl,
      if (voiceNoteUrl != null) 'voice_note_url': voiceNoteUrl,
    };
  }
}
