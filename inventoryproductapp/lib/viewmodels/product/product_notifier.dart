import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'product_state.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'product_state.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super(ProductState.initial()) {
    fetchProducts(); // fetch products on init
  }

  /// Fetch all products from Firestore
  void fetchProducts() {
    state = state.copyWith(isLoading: true);
    try {
      _repository.getProducts().listen((productsList) {
        state = state.copyWith(products: productsList, isLoading: false);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add product
  Future<void> addProduct(Product product) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.addProduct(product);
      state = state.copyWith(isLoading: false);
      fetchProducts(); // refresh list after add
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update product
  Future<void> updateProduct(Product product) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateProduct(product);
      state = state.copyWith(isLoading: false);
      fetchProducts(); // refresh list after update
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteProduct(productId);
      state = state.copyWith(isLoading: false);
      fetchProducts(); // refresh list after delete
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// StateNotifierProvider for Riverpod
final productNotifierProvider =
StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductNotifier(repo);
});


