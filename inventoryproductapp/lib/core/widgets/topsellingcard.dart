import 'package:flutter/material.dart';

class TopSellingCard extends StatelessWidget {
  final List<Map<String, dynamic>> topSellingProducts;
  final bool isLoading;

  const TopSellingCard({
    super.key,
    required this.topSellingProducts,
    this.isLoading = false,
  });

  Color get themeGreen => Colors.green;

  void _showTopProductsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.star, color: themeGreen),
            const SizedBox(width: 8),
            Text(
              "Top-Selling Products",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeGreen,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: topSellingProducts.isEmpty
              ? const Center(
            child: Text(
              "No sales yet",
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            itemCount: topSellingProducts.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.green.shade100,
            ),
            itemBuilder: (context, index) {
              final product = topSellingProducts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child:
                  Icon(Icons.shopping_bag, color: themeGreen),
                ),
                title: Text(
                  product['productName'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Text(
                  "${product['quantitySold']} sold",
                  style: TextStyle(
                    color: Color(0xFF1D612F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: themeGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isLoading || topSellingProducts.isEmpty
          ? null
          : () => _showTopProductsDialog(context),
      child: Card(
        color: Colors.green.shade50,
        elevation: 4,
        shadowColor: Colors.green.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.star, color: themeGreen),
              ),
              const SizedBox(height: 12),
              Text(
                "Top-Selling Products",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeGreen,
                ),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Text("Loading...",
                    style: TextStyle(color: Colors.grey))
              else if (topSellingProducts.isEmpty)
                const Text("No sales yet",
                    style: TextStyle(color: Colors.grey))
              else
                Text(
                  "Tap to view details",
                  style: TextStyle(color: themeGreen),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
