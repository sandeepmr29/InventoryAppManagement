import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../viewmodels/product/product_notifier.dart';
import '../../viewmodels/theme/theme_provider.dart';
import 'product_add_edit_screen.dart';
import '../../core/constants/app_constants.dart';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final productState = ref.watch(productNotifierProvider);

    final filteredProducts = productState.products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final backgroundColor = isDark ? Colors.grey[900] : themeGreen.shade50;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white54 : themeGreen.shade700;
    final fabColor = isDark ? Colors.green[700] : themeGreen.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: fabColor,
        title: Text(
          "📦 Products",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: fabColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductAddEditScreen()),
          );
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: const Text("Add Product", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search product...",
                  hintStyle: TextStyle(color: subtitleColor),
                  prefixIcon: Icon(Icons.search, color: borderColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
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

          // Product List
          Expanded(
            child: productState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    color: fabColor,
                    onRefresh: () async {
                      ref
                          .read(productNotifierProvider.notifier)
                          .fetchProducts();
                    },
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(
                                fontSize: 16,
                                color: subtitleColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return _buildProductCard(
                                context,
                                product,
                                cardColor!,
                                textColor,
                                subtitleColor,
                                borderColor,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Custom Product Card
  Widget _buildProductCard(
    BuildContext context,
    Product product,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shadowColor: Colors.black26,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ? Image.network(
                  product.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  "https://picsum.photos/200",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "₹${product.price} • Qty: ${product.availableQuantity}",
            style: TextStyle(fontSize: 13, color: subtitleColor),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit
            IconButton(
              icon: Icon(Icons.edit, color: borderColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductAddEditScreen(product: product),
                  ),
                );
              },
            ),
            // Delete
            // Delete
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.green.shade50,
                    // light green background
                    title: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Delete Product",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      "Are you sure you want to delete '${product.name}'?",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  // Call ProductNotifier delete
                  if (product.id != null) {
                    await ref
                        .read(productNotifierProvider.notifier)
                        .deleteProduct(product.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product.name} deleted successfully"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
