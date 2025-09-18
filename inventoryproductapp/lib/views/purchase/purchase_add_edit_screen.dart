import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/purchase.dart';
import '../../viewmodels/purchase/purchase_notifier.dart';
import '../../viewmodels/product/product_notifier.dart';
import '../../core/constants/app_constants.dart';

/// Light green theme (same as other screens)

class PurchaseAddEditScreen extends ConsumerStatefulWidget {
  final Purchase? purchase;

  const PurchaseAddEditScreen({super.key, this.purchase});

  @override
  ConsumerState<PurchaseAddEditScreen> createState() =>
      _PurchaseAddEditScreenState();
}

class _PurchaseAddEditScreenState extends ConsumerState<PurchaseAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _supplierController;
  late TextEditingController _notesController;
  DateTime? _purchaseDate;
  List<PurchaseItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _supplierController = TextEditingController(
      text: widget.purchase?.supplierName ?? '',
    );
    _notesController = TextEditingController(
      text: widget.purchase?.notes ?? '',
    );
    _purchaseDate = widget.purchase?.purchaseDate;
    _selectedItems = widget.purchase?.items ?? [];
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: themeGreen.shade700) : null,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: themeGreen.shade700),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseNotifier = ref.watch(purchaseNotifierProvider.notifier);
    final products = ref.watch(productNotifierProvider).products;

    return Scaffold(
      backgroundColor: themeGreen.shade50, // light green background
      appBar: AppBar(
        backgroundColor: themeGreen.shade700,
        title: Text(
          widget.purchase != null ? "Edit Purchase" : "Add Purchase",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Supplier Name
                TextFormField(
                  controller: _supplierController,
                  decoration: _inputDecoration(
                    "Supplier Name",
                    icon: Icons.store,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter supplier name" : null,
                ),
                const SizedBox(height: 16),

                // Purchase Date Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _purchaseDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: themeGreen.shade200),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: themeGreen.shade700,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _purchaseDate == null
                              ? "Select Purchase Date"
                              : "${_purchaseDate!.day.toString().padLeft(2, '0')}-"
                                    "${_purchaseDate!.month.toString().padLeft(2, '0')}-"
                                    "${_purchaseDate!.year}",
                          style: TextStyle(
                            fontSize: 15,
                            color: _purchaseDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Products & Quantity
                Text(
                  "Products Purchased",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: themeGreen.shade700,
                  ),
                ),
                const SizedBox(height: 8),

                ...products.map((p) {
                  final selectedItem = _selectedItems.firstWhere(
                    (e) => e.productId == p.id,
                    orElse: () => PurchaseItem(
                      productId: p.id!,
                      productName: p.name,
                      quantity: 0,
                      cost: p.costPrice,
                    ),
                  );

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: themeGreen.shade100,
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Cost: ₹${p.costPrice}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              initialValue: selectedItem.quantity > 0
                                  ? selectedItem.quantity.toString()
                                  : "",
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Qty",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: themeGreen.shade700,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              onChanged: (v) {
                                final qty = int.tryParse(v) ?? 0;
                                if (qty > 0) {
                                  final index = _selectedItems.indexWhere(
                                    (e) => e.productId == p.id,
                                  );
                                  if (index >= 0) {
                                    _selectedItems[index] = PurchaseItem(
                                      productId: p.id!,
                                      productName: p.name,
                                      quantity: qty,
                                      cost: p.costPrice,
                                    );
                                  } else {
                                    _selectedItems.add(
                                      PurchaseItem(
                                        productId: p.id!,
                                        productName: p.name,
                                        quantity: qty,
                                        cost: p.costPrice,
                                      ),
                                    );
                                  }
                                } else {
                                  _selectedItems.removeWhere(
                                    (e) => e.productId == p.id,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: _inputDecoration("Notes", icon: Icons.notes),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeGreen.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      if (_selectedItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Select at least one product"),
                          ),
                        );
                        return;
                      }

                      double totalCost = 0;
                      for (var item in _selectedItems) {
                        totalCost += item.quantity * item.cost;
                      }

                      final purchase = Purchase(
                        id: widget.purchase?.id,
                        supplierName: _supplierController.text.trim(),
                        purchaseDate: _purchaseDate ?? DateTime.now(),
                        items: _selectedItems,
                        totalCost: totalCost,
                        notes: _notesController.text.trim(),
                        createdAt: widget.purchase?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      if (widget.purchase == null) {
                        await purchaseNotifier.addPurchase(purchase);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Purchase added successfully"),
                            ),
                          );
                        }
                      } else {
                        await purchaseNotifier.updatePurchase(purchase);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Purchase updated successfully"),
                            ),
                          );
                        }
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Save Purchase",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
