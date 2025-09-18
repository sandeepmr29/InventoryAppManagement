import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(DashboardState());
  Map<String, double> monthlySalesMap = {
    "Jan": 1500,
    "Feb": 2000,
    "Mar": 1800,
    "Apr": 2500,
    "May": 3000,
    "Jun": 2200,
    "Jul": 2700,
    "Aug": 3100,
    "Sep": 2800,
    "Oct": 3300,
    "Nov": 3500,
    "Dec": 4000,
  };

  /// ✅ Fetch today's sales
  Future<void> fetchTodaysSales() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final total = await _repository.fetchTodaysSales();
      state = state.copyWith(todaysSales: total, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  /// ✅ Fetch monthly overview (sales + orders)
  Future<void> fetchMonthlyOverview() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repository.getMonthlyOverview();

      state = state.copyWith(
        monthlySales: data['totalSales'] as double,
        monthlyOrders: data['totalOrders'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchLowStockProducts() async {
    state = state.copyWith(isLoadingLowStock: true);

    try {
      final products = await _repository.getLowStockProducts();
      state = state.copyWith(
        lowStockProducts: products,
        isLoadingLowStock: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLowStock: false,
        lowStockError: e.toString(),
      );
    }
  }

  Future<void> fetchTopSellingProducts() async {
    state = state.copyWith(isLoadingTopSelling: true, topSellingError: null);
    try {
      final topProducts = await _repository.fetchTopSellingProducts();
      if (topProducts.isEmpty) {
      } else {}

      state = state.copyWith(
        topSellingProducts: topProducts,
        isLoadingTopSelling: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingTopSelling: false,
        topSellingError: e.toString(),
      );
    }
  }
}

/// ✅ Provider for DashboardNotifier
final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier(DashboardRepository());
    });
