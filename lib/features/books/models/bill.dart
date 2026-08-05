class BillItem {
  final String? stockItemId; // optional linkage to stock
  final String name;
  final double quantity;
  final double price;

  BillItem({
    this.stockItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      stockItemId: json['stock_item_id'] as String?,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (stockItemId != null) 'stock_item_id': stockItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Bill {
  final String id;
  final String ownerId;
  final String type; // 'sale' or 'purchase'
  final String? billNo;
  final String? partyId;
  final String? partyName;
  final String? partyPhone;
  final List<BillItem> items;
  final double totalAmount;
  final double receivedAmount;
  final DateTime billDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    required this.id,
    required this.ownerId,
    required this.type,
    this.billNo,
    this.partyId,
    this.partyName,
    this.partyPhone,
    required this.items,
    required this.totalAmount,
    required this.receivedAmount,
    required this.billDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<BillItem> parsedItems = itemsList.map((i) => BillItem.fromJson(i)).toList();

    return Bill(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      type: json['type'] as String,
      billNo: json['bill_no'] as String?,
      partyId: json['party_id'] as String?,
      partyName: json['party_name'] as String?,
      partyPhone: json['party_phone'] as String?,
      items: parsedItems,
      totalAmount: (json['total_amount'] as num).toDouble(),
      receivedAmount: (json['received_amount'] as num).toDouble(),
      billDate: DateTime.parse(json['bill_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (billNo != null) 'bill_no': billNo,
      if (partyId != null) 'party_id': partyId,
      if (partyName != null) 'party_name': partyName,
      if (partyPhone != null) 'party_phone': partyPhone,
      'items': items.map((i) => i.toJson()).toList(),
      'total_amount': totalAmount,
      'received_amount': receivedAmount,
      'bill_date': billDate.toIso8601String(),
    };
  }
}
