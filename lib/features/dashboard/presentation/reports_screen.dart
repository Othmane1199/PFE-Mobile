import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/reports_provider.dart';
import '../domain/report_stats.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rapports & Analyses', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: reportsAsync.when(
        data: (stats) => _ReportsContent(stats: stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final ReportStats stats;
  const _ReportsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Metrics Row
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Profit Net',
                  value: '${stats.totalProfit.toStringAsFixed(0)} DH',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SummaryCard(
                  title: 'Valeur Stock',
                  value: '${stats.inventoryValue.toStringAsFixed(0)} DH',
                  icon: Icons.inventory_2_rounded,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // 2. Revenue Chart
          Text(
            'Activité (6 derniers mois)',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _ChartContainer(
            height: 260,
            child: _RevenueLineChart(data: stats.monthlyData, isDark: isDark),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // 3. Revenue Distribution
          Text(
            'Répartition Revenus',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _ChartContainer(
                  height: 200,
                  child: _RevenuePieChart(
                    sales: stats.salesRevenue,
                    services: stats.servicesRevenue,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _LegendItem(color: AppTheme.primaryColor, label: 'Ventes'),
                    const SizedBox(height: 8),
                    _LegendItem(color: AppTheme.accentColor, label: 'Services'),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),

          // 4. Top Products
          Text(
            'Produits Vedettes',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...stats.topProducts.map((p) => _TopProductTile(product: p)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.slateGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final Widget child;
  final double height;
  const _ChartContainer({required this.child, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: child,
    );
  }
}

class _RevenueLineChart extends StatelessWidget {
  final List<MonthlyRevenue> data;
  final bool isDark;
  const _RevenueLineChart({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[val.toInt()].month,
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.slateGrey),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.revenue)).toList(),
            isCurved: true,
            color: AppTheme.accentColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withOpacity(0.3),
                  AppTheme.accentColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenuePieChart extends StatelessWidget {
  final double sales;
  final double services;
  final bool isDark;
  const _RevenuePieChart({required this.sales, required this.services, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total = sales + services;
    if (total == 0) return const Center(child: Text('Pas de données'));

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: sales,
            color: AppTheme.primaryColor,
            title: '${(sales / total * 100).toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          PieChartSectionData(
            value: services,
            color: AppTheme.accentColor,
            title: '${(services / total * 100).toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final TopProduct product;
  const _TopProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${product.quantity} vendus', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGrey)),
              ],
            ),
          ),
          Text(
            '${product.revenue.toStringAsFixed(0)} DH',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
