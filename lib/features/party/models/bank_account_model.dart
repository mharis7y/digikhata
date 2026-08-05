/// BankAccountModel represents a bank account linked to the user's business.
class BankAccountModel {
  final String id;
  final String ownerId;
  final String bankName;
  final String accountTitle;
  final String accountNumber;
  final DateTime createdAt;

  const BankAccountModel({
    required this.id,
    required this.ownerId,
    required this.bankName,
    required this.accountTitle,
    required this.accountNumber,
    required this.createdAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      bankName: json['bank_name'] as String,
      accountTitle: json['account_title'] as String,
      accountNumber: json['account_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'bank_name': bankName,
        'account_title': accountTitle,
        'account_number': accountNumber,
        'created_at': createdAt.toIso8601String(),
      };
}
