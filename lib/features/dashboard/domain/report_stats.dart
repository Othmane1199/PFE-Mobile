class ReportStats {
  final double totalRevenue;
  final double totalProfit;
  final double salesRevenue;
  final double servicesRevenue;
  final int totalSalesCount;
  final int totalServicesCount;
  final double inventoryValue;
  final List<MonthlyRevenue> monthlyData;
  final List<TopProduct> topProducts;

  ReportStats({
    required this.totalRevenue,
    required this.totalProfit,
    required this.salesRevenue,
    required this.servicesRevenue,
    required this.totalSalesCount,
    required this.totalServicesCount,
    required this.inventoryValue,
    required this.monthlyData,
    required this.topProducts,
  });
}

class MonthlyRevenue {
  final String month;
  final double revenue;
  MonthlyRevenue(this.month, this.revenue);
}

class TopProduct {
  final String name;
  final int quantity;
  final double revenue;
  TopProduct(this.name, this.quantity, this.revenue);
}
