import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/service.dart';
import '../../auth/presentation/profile_screen.dart';
import 'widgets/ordex_drawer.dart';
import 'reports_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final service = ref.read(supabaseServiceProvider);
    final metadata = service.currentUser?.userMetadata ?? {};
    final userEmail = service.currentUser?.email ?? '';
    final userName = metadata['name'] ?? (userEmail.isNotEmpty ? userEmail.split('@').first : 'Admin');
    final greeting = _getGreeting();

    return Scaffold(
      drawer: const OrdexDrawer(isAdmin: true),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/ordex.png', height: 30),
            const SizedBox(width: 10),
            Text(
              'ORDEX',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(clientsProvider);
          ref.invalidate(servicesProvider);
          ref.invalidate(ordersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '$greeting,',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.slateGrey,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 500.ms),
              Text(
                userName,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05),
              const SizedBox(height: 6),
              Text(
                'Voici un aperçu de votre activité',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.slateGrey,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

              const SizedBox(height: 24),

              // Revenue Banner
              servicesAsync.when(
                data: (services) {
                  return ordersAsync.when(
                    data: (orders) {
                      final sRev = services.fold<double>(0, (sum, s) => sum + s.totalPrice);
                      final oRev = orders.fold<double>(0, (sum, o) => sum + o.totalAmount);
                      final revenue = sRev + oRev;
                      return _RevenueBanner(revenue: revenue)
                          .animate()
                          .fadeIn(delay: 150.ms, duration: 500.ms)
                          .slideY(begin: 0.1);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              Text(
                'Vue d\'ensemble',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 14),

              // Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                childAspectRatio: 1.05,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MetricCard(
                    title: 'Produits',
                    subtitle: 'En stock',
                    icon: Icons.inventory_2_rounded,
                    color: AppTheme.installationColor,
                    asyncValue: productsAsync,
                    delay: 100,
                  ),
                  _MetricCard(
                    title: 'Clients',
                    subtitle: 'Enregistrés',
                    icon: Icons.people_rounded,
                    color: AppTheme.reparationColor,
                    asyncValue: clientsAsync,
                    delay: 200,
                  ),
                  _MetricCard(
                    title: 'Services',
                    subtitle: 'Total',
                    icon: Icons.build_rounded,
                    color: AppTheme.maintenanceColor,
                    asyncValue: servicesAsync,
                    delay: 300,
                  ),
                  _QuickActionCard(
                    title: 'Rapports',
                    subtitle: 'Bientôt',
                    icon: Icons.analytics_rounded,
                    color: const Color(0xFF8338EC),
                    delay: 400,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Recent services preview
              servicesAsync.when(
                data: (services) {
                  if (services.isEmpty) return const SizedBox.shrink();
                  final recent = services.take(3).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services récents',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recent.asMap().entries.map(
                        (e) => _RecentServiceRow(service: e.value)
                            .animate()
                            .fadeIn(
                              delay: (e.key * 80 + 400).ms,
                              duration: 400.ms,
                            )
                            .slideX(begin: 0.05),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }
}

class _RevenueBanner extends StatelessWidget {
  final double revenue;
  const _RevenueBanner({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chiffre d\'affaires total',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${revenue.toStringAsFixed(0)} DH',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Basé sur les interventions et ventes',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final AsyncValue<List<dynamic>> asyncValue;
  final int delay;

  const _MetricCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.asyncValue,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            asyncValue.when(
              data: (list) => Text(
                '${list.length}',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              loading: () => SizedBox(
                height: 34,
                width: 34,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
              ),
              error: (_, __) => Icon(Icons.error_outline, color: AppTheme.dangerColor),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.slateGrey,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          delay: delay.ms,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        ).fadeIn(delay: delay.ms);
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.85), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
          delay: delay.ms,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        ).fadeIn(delay: delay.ms);
  }
}

class _RecentServiceRow extends StatelessWidget {
  final ServiceTask service;
  const _RecentServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.serviceTypeColor(service.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.build_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.type,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (service.description != null)
                  Text(
                    service.description!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.slateGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${service.totalPrice.toStringAsFixed(0)} DH',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
