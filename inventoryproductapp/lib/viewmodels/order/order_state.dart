import '../../data/models/order.dart';


class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrderState({
    required this.orders,
    required this.isLoading,
    this.error,
  });

  factory OrderState.initial() {
    return OrderState(
      orders: [],
      isLoading: false,
      error: null,
    );
  }

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
