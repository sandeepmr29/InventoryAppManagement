import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';

class OrderRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> addOrder(Order order) async {
    try {
      DocumentReference docRef = await _db
          .collection("orders")
          .add(order.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      await _db.collection("orders").doc(order.id).update(order.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _db.collection("orders").doc(orderId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Order>> getOrders() {
    return _db
        .collection("orders")
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Order.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<Map<String, dynamic>> fetchMonthlyOverview() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final snapshot = await _db
          .collection("orders")
          .where("createdAt", isGreaterThanOrEqualTo: startOfMonth)
          .where("createdAt", isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalSales = 0;
      int totalOrders = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalSales += (data["totalAmount"] ?? 0).toDouble();
      }

      return {"totalSales": totalSales, "totalOrders": totalOrders};
    } catch (e) {
      throw Exception("Error fetching monthly overview: $e");
    }
  }
}
