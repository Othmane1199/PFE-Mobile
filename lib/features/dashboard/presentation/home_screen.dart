import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../sales/presentation/sales_tab_screen.dart';
import '../../services/presentation/services_screen.dart';
import '../../clients/presentation/clients_screen.dart';
import 'widgets/ordex_drawer.dart';
import '../../../core/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _previousIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      label: 'Ventes',
    ),
    _NavItem(
      icon: Icons.build_outlined,
      selectedIcon: Icons.build_rounded,
      label: 'Services',
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      label: 'Clients',
    ),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    SalesTabScreen(),
    ServicesScreen(),
    ClientsScreen(),
  ];

  void _onNavTap(int index) {
    final currentIndex = ref.read(dashboardIndexProvider);
    if (index == currentIndex) return;
    setState(() => _previousIndex = currentIndex);
    ref.read(dashboardIndexProvider.notifier).setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardIndexProvider);
    
    return Scaffold(
      drawer: const OrdexDrawer(isAdmin: true),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 350),
        reverse: currentIndex < _previousIndex,
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: _screens[currentIndex],
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(currentIndex),
    );
  }

  Widget _buildNavigationBar(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onNavTap,
        animationDuration: const Duration(milliseconds: 400),
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
