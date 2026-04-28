import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../domain/report_stats.dart';
import 'package:intl/intl.dart';

final reportsProvider = Provider<AsyncValue<ReportStats>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final servicesAsync = ref.watch(servicesProvider);
  final ordersAsync = ref.watch(ordersProvider);

  if (productsAsync is AsyncData &&
      servicesAsync is AsyncData &&
      ordersAsync is AsyncData) {
    final products = productsAsync.value!;
    final services = servicesAsync.value!;
    final orders = ordersAsync.value!;

    double salesRev = orders.fold(0, (sum, item) => sum + item.totalAmount);
    double servicesRev = services.fold(0, (sum, item) => sum + item.totalPrice);
    double totalRev = salesRev + servicesRev;

    // Calculate profit (rough estimate: sales revenue minus cost of products sold)
    // For simplicity, we assume all items in orders are found in products
    double totalCost = 0;
    for (var order in orders) {
      for (var item in order.items) {
        final product = products.firstWhere((p) => p.id == item.productId,
            orElse: () => products.first); // Fallback to first if not found
        totalCost += product.purchasePrice * item.quantity;
      }
    }
    double totalProfit = totalRev - totalCost;

    double invValue = products.fold(
        0, (sum, p) => sum + (p.purchasePrice * p.stockQuantity));

    // Monthly data (last 6 months)
    Map<String, double> monthlyMap = {};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMM', 'fr_FR').format(date);
      monthlyMap[monthName] = 0;
    }

    for (var order in orders) {
      if (order.createdAt != null) {
        final monthName = DateFormat('MMM', 'fr_FR').format(order.createdAt!);
        if (monthlyMap.containsKey(monthName)) {
          monthlyMap[monthName] = monthlyMap[monthName]! + order.totalAmount;
        }
      }
    }
    
    for (var service in services) {
      if (service.createdAt != null) {
        final monthName = DateFormat('MMM', 'fr_FR').format(service.createdAt!);
        if (monthlyMap.containsKey(monthName)) {
          monthlyMap[monthName] = monthlyMap[monthName]! + service.totalPrice;
        }
      }
    }

    final monthlyData = monthlyMap.entries
        .map((e) => MonthlyRevenue(e.key, e.value))
        .toList();

    // Top Products
    Map<String, int> productSales = {};
    Map<String, double> productRev = {};
    for (var order in orders) {
      for (var item in order.items) {
        final product = products.firstWhere((p) => p.id == item.productId,
            orElse: () => products.first);
        productSales[product.name] = (productSales[product.name] ?? 0) + item.quantity;
        productRev[product.name] = (productRev[product.name] ?? 0) + (item.unitPrice * item.quantity);
      }
    }

    final topProducts = productSales.entries.map((e) {
      return TopProduct(e.key, e.value, productRev[e.key] ?? 0);
    }).toList();
    topProducts.sort((a, b) => b.revenue.compareTo(a.revenue));

    return AsyncData(ReportStats(
      totalRevenue: totalRev,
      totalProfit: totalProfit,
      salesRevenue: salesRev,
      servicesRevenue: servicesRev,
      totalSalesCount: orders.length,
      totalServicesCount: services.length,
      inventoryValue: invValue,
      monthlyData: monthlyData,
      topProducts: topProducts.take(5).toList(),
    ));
  }

  return const AsyncLoading();
});
