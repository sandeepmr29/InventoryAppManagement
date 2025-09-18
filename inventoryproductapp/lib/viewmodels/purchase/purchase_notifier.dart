import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/purchase.dart';
import '../../data/repositories/purchase_repository.dart';
import 'purchase_state.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository();
});

final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
      final repo = ref.watch(purchaseRepositoryProvider);
      return PurchaseNotifier(repo);
    });

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final PurchaseRepository _repository;

  PurchaseNotifier(this._repository) : super(PurchaseState.initial()) {
    fetchPurchases();
  }

  void fetchPurchases() {
    state = state.copyWith(isLoading: true);
    try {
      _repository.getPurchases().listen((purchaseList) {
        state = state.copyWith(purchases: purchaseList, isLoading: false);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addPurchase(Purchase purchase) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.addPurchase(purchase);
      state = state.copyWith(isLoading: false);
      fetchPurchases();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePurchase(Purchase purchase) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updatePurchase(purchase);
      state = state.copyWith(isLoading: false);
      fetchPurchases();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      await _repository.deletePurchase(id);
      fetchPurchases();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
