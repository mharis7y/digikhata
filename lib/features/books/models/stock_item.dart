class StockItem {
  final String id;
  final String ownerId;
  final String name;
  final double sellingPrice;
  final double? purchasePrice;
  final double quantity;
  final double? lowStockWarning;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockItem({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.sellingPrice,
    this.purchasePrice,
    required this.quantity,
    this.lowStockWarning,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      sellingPrice: (json['selling_price'] as num).toDouble(),
      purchasePrice: json['purchase_price'] != null ? (json['purchase_price'] as num).toDouble() : null,
      quantity: (json['quantity'] as num).toDouble(),
      lowStockWarning: json['low_stock_warning'] != null ? (json['low_stock_warning'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'selling_price': sellingPrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      'quantity': quantity,
      if (lowStockWarning != null) 'low_stock_warning': lowStockWarning,
    };
  }

  StockItem copyWith({
    String? name,
    double? sellingPrice,
    double? purchasePrice,
    double? quantity,
    double? lowStockWarning,
  }) {
    return StockItem(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
      lowStockWarning: lowStockWarning ?? this.lowStockWarning,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
