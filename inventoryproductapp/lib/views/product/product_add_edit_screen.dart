import 'dart:typed_data';
import 'dart:io' show File;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/product.dart';
import '../../viewmodels/product/product_notifier.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/theme/theme_provider.dart';

class ProductAddEditScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductAddEditScreen({super.key, this.product});

  @override
  ConsumerState<ProductAddEditScreen> createState() =>
      _ProductAddEditScreenState();
}

class _ProductAddEditScreenState extends ConsumerState<ProductAddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costpriceController;
  late TextEditingController _qtyController;
  late TextEditingController _descController;
  late TextEditingController _tagController;

  List<String> _categories = [];
  Uint8List? _imageBytes;
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _costpriceController = TextEditingController(
      text: widget.product?.costPrice.toString() ?? '',
    );
    _qtyController = TextEditingController(
      text: widget.product?.availableQuantity.toString() ?? '',
    );
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _tagController = TextEditingController();

    _categories = widget.product?.categories ?? [];
    _imageUrl = widget.product?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costpriceController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imageBytes = result.files.first.bytes;
          _imageUrl = null;
          _imageFile = null;
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
          _imageUrl = null;
        });
      }
    }
  }

  Future<void> _shareProduct() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Sharing not supported on Web"),
          backgroundColor: themeGreen.shade700,
        ),
      );
      return;
    }
    if (widget.product == null) return;

    String productInfo =
        '''
Product: ${widget.product!.name}
Price: ₹${widget.product!.price.toStringAsFixed(2)}
Quantity: ${widget.product!.availableQuantity}
Description: ${widget.product!.description}
''';

    if (_imageUrl != null) {
      productInfo += "\nImage: $_imageUrl";
    }

    await Share.share(productInfo, subject: "Check out this product!");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final isEditing = widget.product != null;
    final productNotifier = ref.watch(productNotifierProvider);

    final backgroundColor = isDark ? Colors.grey[900] : themeGreen.shade50;

    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white54 : themeGreen.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : themeGreen.shade700,
        title: Text(
          isEditing ? 'edit_product_text'.tr() : "Add Product",
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.share, color: textColor),
              onPressed: () => _shareProduct(),
              tooltip: "Share Product",
            ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                _nameController,
                'product_name_text'.tr(),
                textColor: textColor,
                labelColor: labelColor,
                borderColor: borderColor,
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _priceController,
                "Price",
                textColor: textColor,
                labelColor: labelColor,
                borderColor: borderColor,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _costpriceController,
                'costprice_text'.tr(),
                textColor: textColor,
                labelColor: labelColor,
                borderColor: borderColor,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _qtyController,
                'availablequantity_text'.tr(),
                textColor: textColor,
                labelColor: labelColor,
                borderColor: borderColor,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _descController,
                'description_text'.tr(),
                textColor: textColor,
                labelColor: labelColor,
                borderColor: borderColor,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Tags
              Text(
                "Categories / Tags",
                style: TextStyle(
                  color: borderColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'enter_text'.tr(),
                        hintStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                        border: OutlineInputBorder(),
                        filled: isDark,
                        fillColor: isDark ? Colors.grey[800] : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: borderColor),
                    onPressed: () {
                      final tag = _tagController.text.trim();
                      if (tag.isNotEmpty) {
                        setState(() => _categories.add(tag));
                        _tagController.clear();
                      }
                    },
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _categories
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: TextStyle(color: textColor)),
                        backgroundColor: isDark
                            ? Colors.green[700]
                            : themeGreen.shade100,
                        deleteIconColor: borderColor,
                        onDeleted: () =>
                            setState(() => _categories.remove(tag)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),

              // Image Picker
              Text(
                "Product Image",
                style: TextStyle(
                  color: borderColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_imageBytes != null)
                Image.memory(_imageBytes!, height: 150)
              else if (_imageFile != null)
                Image.file(_imageFile!, height: 150)
              else if (_imageUrl != null)
                Image.network(_imageUrl!, height: 150)
              else
                Container(
                  height: 150,
                  color: isDark ? Colors.grey[800] : themeGreen.shade100,
                  child: Center(
                    child: Text(
                      "No Image Selected",
                      style: TextStyle(color: labelColor),
                    ),
                  ),
                ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image, color: borderColor),
                label: Text(
                  'select_fromgallery_text'.tr(),
                  style: TextStyle(color: borderColor),
                ),
              ),
              const SizedBox(height: 20),

              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: borderColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: productNotifier.isLoading ? null : _saveProduct,
                child: productNotifier.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? "Update" : "Add"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Color textColor,
    required Color labelColor,
    required Color borderColor,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        border: const OutlineInputBorder(),
        filled: false,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(productNotifierProvider.notifier);

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      costPrice: double.tryParse(_priceController.text.trim()) ?? 0,
      availableQuantity: int.tryParse(_qtyController.text.trim()) ?? 0,
      categories: _categories,
      imageUrl: _imageUrl,
      description: _descController.text.trim(),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.product == null) {
      await notifier.addProduct(product);
    } else {
      await notifier.updateProduct(product);
    }

    if (mounted) Navigator.pop(context);
  }
}
