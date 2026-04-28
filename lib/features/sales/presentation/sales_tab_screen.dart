import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';
import '../../dashboard/presentation/widgets/ordex_drawer.dart';

class SalesTabScreen extends StatelessWidget {
  const SalesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const OrdexDrawer(isAdmin: true),
        appBar: AppBar(
          title: const Text('Ventes & Inventaire'),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppTheme.accentGold,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Commandes', icon: Icon(Icons.shopping_cart_rounded)),
              Tab(text: 'Inventaire', icon: Icon(Icons.inventory_2_rounded)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersScreen(),
            InventoryScreen(),
          ],
        ),
      ),
    );
  }
}
