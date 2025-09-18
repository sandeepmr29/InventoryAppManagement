import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _db
          .collection("products")
          .add(product.toMap());
    } catch (e) {
      throw e; // rethrow if you want to handle it elsewhere
    }
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection("products").doc(product.id).update(product.toMap());
  }

  Stream<List<Product>> getProducts() {
    return _db
        .collection("products")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Delete product by ID
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection("products").doc(productId).delete();
    } catch (e) {
      throw e;
    }
  }
}
