import 'package:cloud_firestore/cloud_firestore.dart';


class Order {
  final String? id;
  final String customerName;
  final String customerContact;
  final List<OrderItem> items;
  final String orderStatus; // Pending / Delivered / Cancelled
  final String paymentStatus; // Paid / Pending
  final DateTime deliveryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalAmount;

  Order({
    this.id,
    required this.customerName,
    required this.customerContact,
    required this.items,
    this.orderStatus = 'Pending',
    this.paymentStatus = 'Pending',
    required this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    required this.totalAmount
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerContact': customerContact,
      'items': items.map((i) => i.toMap()).toList(),
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'deliveryDate': deliveryDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'totalAmount': totalAmount,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      customerName: map['customerName'] ?? '',
      customerContact: map['customerContact'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((i) => OrderItem.fromMap(i))
          .toList(),
      orderStatus: map['orderStatus'] ?? 'Pending',
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      deliveryDate: (map['deliveryDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      totalAmount: map['totalAmount'] ?? '',
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
    );
  }
}
