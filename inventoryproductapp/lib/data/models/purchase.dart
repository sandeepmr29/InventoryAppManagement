import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseItem {
  final String productId;
  final String productName;
  final int quantity;
  final double cost;

  PurchaseItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'cost': cost,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      cost: (map['cost'] as num).toDouble(),
    );
  }
}

class Purchase {
  final String? id;
  final String supplierName;
  final DateTime purchaseDate;
  final List<PurchaseItem> items;
  final double totalCost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Purchase({
    this.id,
    required this.supplierName,
    required this.purchaseDate,
    required this.items,
    required this.totalCost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'supplierName': supplierName,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'items': items.map((e) => e.toMap()).toList(),
      'totalCost': totalCost,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map, String id) {
    return Purchase(
      id: id,
      supplierName: map['supplierName'],
      purchaseDate: (map['purchaseDate'] as Timestamp).toDate(),
      items: (map['items'] as List)
          .map((e) => PurchaseItem.fromMap(e))
          .toList(),
      totalCost: (map['totalCost'] as num).toDouble(),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
