import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/purchase.dart';

class PurchaseRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> addPurchase(Purchase purchase) async {
    try {
      DocumentReference docRef = await _db
          .collection("purchases")
          .add(purchase.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePurchase(Purchase purchase) async {
    if (purchase.id == null) return;
    await _db.collection("purchases").doc(purchase.id).update(purchase.toMap());
  }

  Future<void> deletePurchase(String id) async {
    await _db.collection("purchases").doc(id).delete();
  }

  Stream<List<Purchase>> getPurchases() {
    try {
      return _db
          .collection("purchases")
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Purchase.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      return Stream.value([]);
    }
  }
}
