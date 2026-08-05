/// PartyType — distinguishes Customers from Suppliers.
enum PartyType { customer, supplier }

/// Party represents a Customer or Supplier record in the user's ledger.
/// Linked to a business (owner_id) via Supabase RLS.
class PartyModel {
  final String id;
  final String ownerId; // auth.uid() of the business user
  final String name;
  final String? phone;
  final String? countryCode;
  final PartyType type;
  final double balance; // positive = you will get; negative = you will give
  final DateTime createdAt;
  final DateTime updatedAt;

  const PartyModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.phone,
    this.countryCode,
    required this.type,
    this.balance = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCustomer => type == PartyType.customer;
  bool get isSupplier => type == PartyType.supplier;

  /// Amount the business will GET from this party (receivable).
  double get youWillGet => balance > 0 ? balance : 0;

  /// Amount the business will GIVE to this party (payable).
  double get youWillGive => balance < 0 ? balance.abs() : 0;

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      countryCode: json['country_code'] as String?,
      type: (json['type'] as String) == 'supplier'
          ? PartyType.supplier
          : PartyType.customer,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'name': name,
        'phone': phone,
        'country_code': countryCode,
        'type': type == PartyType.supplier ? 'supplier' : 'customer',
        'balance': balance,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  PartyModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? phone,
    String? countryCode,
    PartyType? type,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
