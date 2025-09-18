import '../../data/models/product.dart';

class DashboardState {
  final double todaysSales;
  final double monthlySales;
  final int monthlyOrders;
  final bool isLoading;
  final String? errorMessage;

  final List<Product> lowStockProducts;
  final bool isLoadingLowStock;
  final String? lowStockError;

  final List<Map<String, dynamic>> topSellingProducts;
  final bool isLoadingTopSelling;
  final String? topSellingError;

  /// Monthly sales map for charting (key: month, value: sales amount)
  final Map<String, double> monthlySalesMap;

  DashboardState({
    this.todaysSales = 0.0,
    this.monthlySales = 0.0,
    this.monthlyOrders = 0,
    this.isLoading = false,
    this.errorMessage,
    this.lowStockProducts = const [],
    this.isLoadingLowStock = false,
    this.lowStockError,
    this.topSellingProducts = const [],
    this.isLoadingTopSelling = false,
    this.topSellingError,
    this.monthlySalesMap = const {}, // default empty map
  });

  DashboardState copyWith({
    double? todaysSales,
    double? monthlySales,
    int? monthlyOrders,
    bool? isLoading,
    String? errorMessage,
    List<Product>? lowStockProducts,
    bool? isLoadingLowStock,
    String? lowStockError,
    List<Map<String, dynamic>>? topSellingProducts,
    bool? isLoadingTopSelling,
    String? topSellingError,
    Map<String, double>? monthlySalesMap,
  }) {
    return DashboardState(
      todaysSales: todaysSales ?? this.todaysSales,
      monthlySales: monthlySales ?? this.monthlySales,
      monthlyOrders: monthlyOrders ?? this.monthlyOrders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      isLoadingLowStock: isLoadingLowStock ?? this.isLoadingLowStock,
      lowStockError: lowStockError ?? this.lowStockError,
      topSellingProducts: topSellingProducts ?? this.topSellingProducts,
      isLoadingTopSelling: isLoadingTopSelling ?? this.isLoadingTopSelling,
      topSellingError: topSellingError ?? this.topSellingError,
      monthlySalesMap: monthlySalesMap ?? this.monthlySalesMap,
    );
  }

  /// Factory constructor for initial/default state
  factory DashboardState.initial() {
    return DashboardState(
      monthlySalesMap: {
        "Jan": 0.0,
        "Feb": 0.0,
        "Mar": 0.0,
        "Apr": 0.0,
        "May": 0.0,
        "Jun": 0.0,
        "Jul": 0.0,
        "Aug": 0.0,
        "Sep": 0.0,
        "Oct": 0.0,
        "Nov": 0.0,
        "Dec": 0.0,
      },
    );
  }
}


