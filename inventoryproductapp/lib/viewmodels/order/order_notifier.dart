import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';

import 'order_state.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final orderNotifierProvider =
StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repo);
});

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(OrderState.initial()) {
    fetchOrders();
  }

  void fetchOrders() {
    state = state.copyWith(isLoading: true);
    try {
      _repository.getOrders().listen((ordersList) {
        state = state.copyWith(orders: ordersList, isLoading: false);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addOrder(Order order) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.addOrder(order);
      state = state.copyWith(isLoading: false);
      fetchOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateOrder(Order order) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateOrder(order);
      state = state.copyWith(isLoading: false);
      fetchOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteOrder(String orderId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteOrder(orderId);
      state = state.copyWith(isLoading: false);
      fetchOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
