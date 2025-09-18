import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/order/order_notifier.dart';
import 'order_add_edit_screen.dart';

/// Light green theme
const MaterialColor themeGreen = MaterialColor(0xFF4CAF50, <int, Color>{
  50: Color(0xFFE8F5E9),
  100: Color(0xFFC8E6C9),
  200: Color(0xFFA5D6A7),
  300: Color(0xFF81C784),
  400: Color(0xFF66BB6A),
  500: Color(0xFF4CAF50),
  600: Color(0xFF43A047),
  700: Color(0xFF388E3C),
  800: Color(0xFF2E7D32),
  900: Color(0xFF1B5E20),
});

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    final orderNotifier = ref.watch(orderNotifierProvider.notifier);

    final filteredOrders = orderState.orders
        .where(
          (order) => order.customerName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeGreen.shade700,
        title: const Text(
          "Customer Orders",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeGreen.shade700,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderAddEditScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Order"),
      ),
      body: Container(
        color: themeGreen.shade50, // light green background
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by customer name...",
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeGreen.shade700),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),

            // Orders List
            Expanded(
              child: orderState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                  ? const Center(
                      child: Text(
                        "No orders found",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      order.customerName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: themeGreen.shade800,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: themeGreen.shade700,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    OrderAddEditScreen(
                                                      order: order,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text(
                                                  "Confirm Delete",
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to delete this order?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text("Delete"),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              await orderNotifier.deleteOrder(
                                                order.id!,
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      "Order deleted",
                                                    ),
                                                    backgroundColor:
                                                        themeGreen.shade700,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "📞 ${order.customerContact}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeGreen.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "📦 Status: ${order.orderStatus} • Payment: ${order.paymentStatus}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: themeGreen.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "🛒 Products: ${order.items.length}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: themeGreen.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "🚚 Delivery: ${order.deliveryDate.day.toString().padLeft(2, '0')}-"
                                  "${order.deliveryDate.month.toString().padLeft(2, '0')}-"
                                  "${order.deliveryDate.year}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: themeGreen.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
