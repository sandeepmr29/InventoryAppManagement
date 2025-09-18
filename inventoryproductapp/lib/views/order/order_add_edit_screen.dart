import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order.dart';
import '../../viewmodels/order/order_notifier.dart';
import '../../viewmodels/product/product_notifier.dart';
import '../../viewmodels/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';

class OrderAddEditScreen extends ConsumerStatefulWidget {
  final Order? order;

  const OrderAddEditScreen({super.key, this.order});

  @override
  ConsumerState<OrderAddEditScreen> createState() => _OrderAddEditScreenState();
}

class _OrderAddEditScreenState extends ConsumerState<OrderAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _customerContactController;
  List<OrderItem> _selectedItems = [];

  String _orderStatus = 'Pending';
  String _paymentStatus = 'Pending';
  final List<String> orderStatusOptions = ['Pending', 'Delivered', 'Cancelled'];
  final List<String> paymentStatusOptions = ['Paid', 'Pending'];
  DateTime? _deliveryDate;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.order?.customerName ?? '',
    );
    _customerContactController = TextEditingController(
      text: widget.order?.customerContact ?? '',
    );
    _deliveryDate = widget.order?.deliveryDate;
    _selectedItems = widget.order?.items ?? [];
    _orderStatus = widget.order?.orderStatus ?? 'Pending';
    _paymentStatus = widget.order?.paymentStatus ?? 'Pending';
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerContactController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    String label,
    Color primaryColor, {
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final orderNotifier = ref.watch(orderNotifierProvider.notifier);
    final products = ref.watch(productNotifierProvider).products;

    final bgColor = isDark ? Colors.grey[900] : themeGreen.shade50;
    final cardColor = isDark ? Colors.grey[850] : themeGreen.shade100;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final primaryColor = isDark ? Colors.green[400]! : themeGreen.shade700;
    final buttonColor = isDark ? Colors.green[700]! : themeGreen.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: Text(
          widget.order != null ? "Edit Order" : "Add Order",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info Card
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _customerNameController,
                        decoration: _inputDecoration(
                          "Customer Name",
                          primaryColor,
                          icon: Icons.person,
                        ),
                        style: TextStyle(color: textColor),
                        validator: (v) => v == null || v.isEmpty
                            ? "Enter customer name"
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customerContactController,
                        decoration: _inputDecoration(
                          "Customer Contact",
                          primaryColor,
                          icon: Icons.phone,
                        ),
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Products Card
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    "Ordered Products",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  children: [
                    ...products.map((p) {
                      final selectedItem = _selectedItems.firstWhere(
                        (e) => e.productId == p.id,
                        orElse: () => OrderItem(
                          productId: p.id!,
                          productName: p.name,
                          quantity: 0,
                          price: p.price,
                        ),
                      );
                      return ListTile(
                        title: Text(p.name, style: TextStyle(color: textColor)),
                        subtitle: Text(
                          "Price: ₹${p.price}",
                          style: TextStyle(color: subtitleColor),
                        ),
                        trailing: SizedBox(
                          width: 70,
                          child: TextFormField(
                            initialValue: selectedItem.quantity > 0
                                ? selectedItem.quantity.toString()
                                : '',
                            decoration: InputDecoration(
                              hintText: "Qty",
                              hintStyle: TextStyle(color: subtitleColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor),
                            onChanged: (v) {
                              final qty = int.tryParse(v) ?? 0;
                              if (qty > 0) {
                                final index = _selectedItems.indexWhere(
                                  (e) => e.productId == p.id,
                                );
                                if (index >= 0) {
                                  _selectedItems[index] = OrderItem(
                                    productId: p.id!,
                                    productName: p.name,
                                    quantity: qty,
                                    price: p.price,
                                  );
                                } else {
                                  _selectedItems.add(
                                    OrderItem(
                                      productId: p.id!,
                                      productName: p.name,
                                      quantity: qty,
                                      price: p.price,
                                    ),
                                  );
                                }
                              } else {
                                _selectedItems.removeWhere(
                                  (e) => e.productId == p.id,
                                );
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    }),
                    if (_selectedItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Total: ₹${_selectedItems.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Order & Payment Status Card
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _orderStatus,
                        decoration: InputDecoration(
                          labelText: "Order Status",
                          labelStyle: TextStyle(color: primaryColor),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        dropdownColor: cardColor,
                        style: TextStyle(color: textColor),
                        items: orderStatusOptions
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null)
                            setState(() => _orderStatus = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _paymentStatus,
                        decoration: InputDecoration(
                          labelText: "Payment Status",
                          labelStyle: TextStyle(color: primaryColor),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        dropdownColor: cardColor,
                        style: TextStyle(color: textColor),
                        items: paymentStatusOptions
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null)
                            setState(() => _paymentStatus = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Date Card
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: primaryColor),
                  title: Text(
                    _deliveryDate == null
                        ? "Select Delivery Date"
                        : "Delivery Date: ${_deliveryDate!.day.toString().padLeft(2, '0')}-"
                              "${_deliveryDate!.month.toString().padLeft(2, '0')}-"
                              "${_deliveryDate!.year}",
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _deliveryDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: isDark
                              ? ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: primaryColor,
                                    onPrimary: Colors.white,
                                    surface: Colors.grey[800]!,
                                  ),
                                )
                              : ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: primaryColor,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                  ),
                                ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _deliveryDate = date;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save Order",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    final totalAmount = _selectedItems.fold<double>(
                      0.0,
                      (sum, item) => sum + (item.price * item.quantity),
                    );
                    final order = Order(
                      id: widget.order?.id,
                      customerName: _customerNameController.text.trim(),
                      customerContact: _customerContactController.text.trim(),
                      items: _selectedItems,
                      orderStatus: _orderStatus,
                      paymentStatus: _paymentStatus,
                      deliveryDate: _deliveryDate!,
                      createdAt: widget.order?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      totalAmount: totalAmount,
                    );

                    if (widget.order == null) {
                      await orderNotifier.addOrder(order);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order added successfully"),
                          ),
                        );
                      }
                    } else {
                      await orderNotifier.updateOrder(order);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order updated successfully"),
                          ),
                        );
                      }
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
