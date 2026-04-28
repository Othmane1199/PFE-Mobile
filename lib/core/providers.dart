import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/supabase_service.dart';
import 'models/product.dart';
import 'models/client.dart';
import 'models/service.dart';
import 'models/order.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Theme Mode
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggle(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// Products
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  return await service.getProducts();
});

// Clients
final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  return await service.getClients();
});

// Services
final servicesProvider = FutureProvider<List<ServiceTask>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  return await service.getServices();
});

// Orders
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  return await service.getOrders();
});

// Navigation
class DashboardIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final dashboardIndexProvider = NotifierProvider<DashboardIndexNotifier, int>(() {
  return DashboardIndexNotifier();
});
