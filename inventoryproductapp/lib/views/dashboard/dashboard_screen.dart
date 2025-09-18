import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/topsellingcard.dart';
import '../../viewmodels/dashboard/dashboard_notifier.dart';
import '../../viewmodels/theme/theme_provider.dart';
import '../chart/monthly_chart_screen.dart';
import '../order/order_list_screen.dart';
import '../product/product_list_screen.dart';
import '../purchase/purchase_list_screen.dart';
import '../../core/constants/app_constants.dart'as appconstant;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(dashboardNotifierProvider.notifier);
      notifier.fetchTodaysSales();
      notifier.fetchMonthlyOverview();
      notifier.fetchLowStockProducts();
      notifier.fetchTopSellingProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Colors based on theme
    final backgroundColor = isDark ? Colors.grey[900] : appconstant.themeGreen.shade50;
    final cardColor = isDark ? Colors.grey[800] : Colors.white;
    final titleTextColor = isDark ? Colors.green[300] : const Color(0xFF1D612F);
    final valueTextColor = isDark ? Colors.white : Colors.black87;
    final appBarGradientColors = isDark
        ? [Colors.green[700]!, Colors.green[400]!]
        : [const Color(0xFF1D612F), const Color(0xFF4CAF50)];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📊 Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag, color: isDark ? Colors.white : Colors.white),
        tooltip: 'products'.tr(),

            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProductsListScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.receipt_long, color: isDark ? Colors.white : Colors.white),
            tooltip: "Orders",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrdersListScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: isDark ? Colors.white : Colors.white),
            tooltip: "Purchases",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PurchaseListScreen()));
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                onPressed: () => ref.read(themeNotifierProvider.notifier).toggleTheme(),
              );
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            _buildDashboardCard(
              icon: Icons.attach_money,
              gradientColors: isDark
                  ? [Colors.green[400]!, Colors.green[700]!]
                  : [const Color(0xFF66BB6A), const Color(0xFF1D612F)],
              title: "Today's Sales",
              value: dashboardState.isLoading
                  ? "Loading..."
                  : "₹${dashboardState.todaysSales.toStringAsFixed(2)}",
              cardColor: cardColor!,
              titleColor: titleTextColor!,
              valueColor: valueTextColor,
            ),
            GestureDetector(
              onTap: () {
                if (!dashboardState.isLoading) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>MonthlySalesChartScreen(monthlySales: appconstant.demoMonthlySales),
                    ),
                  );
                }
              },
              child: _buildDashboardCard(
                icon: Icons.calendar_month,
                gradientColors: isDark
                    ? [Colors.green[300]!, Colors.green[700]!]
                    : [const Color(0xFF81C784), const Color(0xFF1D612F)],
                title: "Monthly Overview",
                value: dashboardState.isLoading
                    ? "Loading..."
                    : "Sales: ₹${dashboardState.monthlySales.toStringAsFixed(2)}\nOrders: ${dashboardState.monthlyOrders}",
                cardColor: cardColor,
                titleColor: titleTextColor,
                valueColor: valueTextColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (!dashboardState.isLoadingLowStock &&
                    dashboardState.lowStockProducts.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent, // makes outer corners rounded nicely
                      child: Container(
                        decoration: BoxDecoration(
                          color: appconstant.themeGreen.shade50, // light green background
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Low Stock Products",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: appconstant.themeGreen.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(color: appconstant.themeGreen.shade200, thickness: 1.5),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: dashboardState.lowStockProducts.length,
                                itemBuilder: (context, index) {
                                  final product = dashboardState.lowStockProducts[index];
                                  return Card(
                                    elevation: 2,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      leading: Icon(Icons.warning_amber_rounded,
                                          color: Colors.orangeAccent),
                                      title: Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text("Qty: ${product.availableQuantity}"),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appconstant.themeGreen.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Close",
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );

                }
              },
              child: _buildDashboardCard(
                icon: Icons.warning_amber,
                gradientColors: isDark
                    ? [Colors.green[300]!, Colors.green[600]!]
                    : [const Color(0xFFA5D6A7), const Color(0xFF1D612F)],
                title: "Low Stock Alerts",
                value: dashboardState.isLoadingLowStock
                    ? "Loading..."
                    : dashboardState.lowStockProducts.isEmpty
                    ? "No alerts"
                    : "${dashboardState.lowStockProducts.length} products low in stock",
                cardColor: cardColor,
                titleColor: titleTextColor,
                valueColor: valueTextColor,
              ),
            ),

            dashboardState.isLoadingTopSelling
                ? _buildDashboardCard(
              icon: Icons.star,
              gradientColors: isDark
                  ? [Colors.green[400]!, Colors.green[700]!]
                  : [const Color(0xFF66BB6A), const Color(0xFF1D612F)],
              title: "Top-Selling",
              value: "Loading...",
              cardColor: cardColor,
              titleColor: titleTextColor,
              valueColor: valueTextColor,
            )
                : TopSellingCard(
              topSellingProducts: dashboardState.topSellingProducts,
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String value,
    required Color cardColor,
    required Color titleColor,
    required Color valueColor,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 14, color: valueColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
