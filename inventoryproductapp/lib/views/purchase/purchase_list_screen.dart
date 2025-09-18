import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/purchase/purchase_notifier.dart';
import 'purchase_add_edit_screen.dart';

/// Light green theme (reuse same as ProductAddEditScreen)
const MaterialColor themeGreen = MaterialColor(
  0xFF4CAF50,
  <int, Color>{
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
  },
);

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final purchaseNotifier = ref.watch(purchaseNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: themeGreen.shade50, // light green background
      appBar: AppBar(
        backgroundColor: themeGreen.shade700,
        title: const Text(
          "Purchases",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeGreen.shade700,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PurchaseAddEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: purchaseState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchaseState.purchases.isEmpty
          ? Center(
        child: Text(
          "No purchases found",
          style: TextStyle(
              fontSize: 16, color: themeGreen.shade700),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: purchaseState.purchases.length,
        itemBuilder: (context, index) {
          final purchase = purchaseState.purchases[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: themeGreen.shade50, // subtle light green card
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Supplier Name + Menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        purchase.supplierName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PurchaseAddEditScreen(
                                  purchase: purchase,
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text(
                                    "Are you sure you want to delete this purchase?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await purchaseNotifier
                                  .deletePurchase(purchase.id!);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                    content: Text("Purchase deleted")),
                              );
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'edit', child: Text("Edit")),
                          PopupMenuItem(
                              value: 'delete', child: Text("Delete")),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date Row
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: themeGreen.shade700),
                      const SizedBox(width: 6),
                      Text(
                        "${purchase.purchaseDate.day.toString().padLeft(2, '0')}-"
                            "${purchase.purchaseDate.month.toString().padLeft(2, '0')}-"
                            "${purchase.purchaseDate.year}",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Items & Cost Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          "Items: ${purchase.items.length}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: themeGreen.shade100,
                      ),
                      Text(
                        "₹${purchase.totalCost.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: themeGreen.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
