import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id; // Firestore doc id
  final String name;
  final double price;
  final double costPrice;
  final int availableQuantity;
  final List<String> categories; // tags / categories
  final String? imageUrl; // Firebase Storage URL
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.costPrice,
    required this.availableQuantity,
    required this.categories,
    this.imageUrl,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Firestore Document to Product
  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      availableQuantity: (map['availableQuantity'] ?? 0) as int,
      categories: List<String>.from(map['categories'] ?? []),
      imageUrl: map['imageUrl'],
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert Product to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'costPrice': costPrice,
      'availableQuantity': availableQuantity,
      'categories': categories,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create a copy with modifications
  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? costPrice,
    int? availableQuantity,
    List<String>? categories,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

