import '../../data/models/purchase.dart';


class PurchaseState {
  final List<Purchase> purchases;
  final bool isLoading;
  final String? error;

  PurchaseState({
    required this.purchases,
    required this.isLoading,
    this.error,
  });

  factory PurchaseState.initial() {
    return PurchaseState(
      purchases: [],
      isLoading: false,
      error: null,
    );
  }

  PurchaseState copyWith({
    List<Purchase>? purchases,
    bool? isLoading,
    String? error,
  }) {
    return PurchaseState(
      purchases: purchases ?? this.purchases,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
