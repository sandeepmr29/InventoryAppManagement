import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class DashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<double> fetchTodaysSales() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await _db
          .collection("orders")
          .where("createdAt", isGreaterThanOrEqualTo: startOfDay)
          .where("createdAt", isLessThan: endOfDay)
          .where("paymentStatus", isEqualTo: "Paid") // optional
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc["totalAmount"] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ Fetch monthly overview (total sales + total orders)
  Future<Map<String, dynamic>> getMonthlyOverview() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfNextMonth = (now.month == 12)
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);

      final querySnapshot = await _db
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('createdAt', isLessThan: startOfNextMonth)
          .get();

      double totalSales = 0;
      int totalOrders = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('totalAmount')) {
          totalSales += (data['totalAmount'] as num).toDouble();
        }
      }

      return {"totalSales": totalSales, "totalOrders": totalOrders};
    } catch (e) {
      return {"totalSales": 0.0, "totalOrders": 0};
    }
  }

  // Fetch products with low stock (< 5)
  Future<List<Product>> getLowStockProducts({int threshold = 5}) async {
    try {
      final querySnapshot = await _db
          .collection('products')
          .where('availableQuantity', isLessThan: threshold)
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();

      return products;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTopSellingProducts() async {
    final snapshot = await _db.collection('orders').get();

    Map<String, int> productSales = {}; // productId -> total quantity sold
    Map<String, String> productNames = {}; // productId -> productName

    for (var doc in snapshot.docs) {
      final order = doc.data();
      final List<dynamic> items = order['items'] ?? [];
      for (var item in items) {
        final pid = item['productId'] as String;
        final qty = (item['quantity'] ?? 0) as int;
        final pname = item['productName'] as String;

        productSales[pid] = (productSales[pid] ?? 0) + qty;
        productNames[pid] = pname;
      }
    }

    final topSelling =
        productSales.entries
            .map(
              (e) => {
                'productId': e.key,
                'productName': productNames[e.key] ?? '',
                'quantitySold': e.value,
              },
            )
            .toList()
          ..sort(
            (a, b) =>
                (b['quantitySold'] as int).compareTo(a['quantitySold'] as int),
          );

    return topSelling.take(3).toList(); // return top 3 products
  }
}
