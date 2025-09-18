import '../../data/models/product.dart';

import '../../data/models/product.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  ProductState({
    required this.products,
    required this.isLoading,
    this.error,
  });

  /// Factory constructor for initial/default state
  factory ProductState.initial() {
    return ProductState(
      products: [],
      isLoading: false,
      error: null,
    );
  }

  /// CopyWith to update fields
  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

