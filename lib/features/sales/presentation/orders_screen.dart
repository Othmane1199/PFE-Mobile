import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/models/order.dart';
import '../../../core/models/client.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_theme.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  void _showOrderDialog(List<Client> clients, List<Product> products) {
    if (clients.isEmpty || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez ajouter au moins un client et un produit', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String selectedClientId = clients.first.id;
    String selectedProductId = products.first.id;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final selectedProduct = products.firstWhere((p) => p.id == selectedProductId);
            final double totalPrice = selectedProduct.salePrice * quantity;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shopping_cart_rounded, color: AppTheme.successColor),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Nouvelle Vente',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: selectedClientId,
                        decoration: const InputDecoration(
                          labelText: 'Client',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                        items: clients.map((client) {
                          return DropdownMenuItem(
                            value: client.id,
                            child: Text(client.nameOrCompany, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setStateDialog(() => selectedClientId = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedProductId,
                        decoration: const InputDecoration(
                          labelText: 'Produit',
                          prefixIcon: Icon(Icons.inventory_2_rounded),
                        ),
                        items: products.map((prod) {
                          return DropdownMenuItem(
                            value: prod.id,
                            child: Text('${prod.name} (Stock: ${prod.stockQuantity})', style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setStateDialog(() => selectedProductId = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Quantité: $quantity', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (quantity > 1) setStateDialog(() => quantity--);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (quantity < selectedProduct.stockQuantity) {
                                setStateDialog(() => quantity++);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Total: ${totalPrice.toStringAsFixed(0)} DH',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final order = Order(
                                  id: '',
                                  clientId: selectedClientId,
                                  totalAmount: totalPrice,
                                  status: 'Payé',
                                  items: [
                                    OrderItem(
                                      id: '',
                                      orderId: '',
                                      productId: selectedProductId,
                                      quantity: quantity,
                                      unitPrice: selectedProduct.salePrice,
                                    ),
                                  ],
                                );
                                final service = ref.read(supabaseServiceProvider);
                                try {
                                  await service.createOrder(order);
                                  if (context.mounted) Navigator.pop(context);
                                  ref.invalidate(ordersProvider);
                                  ref.invalidate(productsProvider); // Refresh stock
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur: $e', style: GoogleFonts.inter()),
                                        backgroundColor: AppTheme.dangerColor,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Valider'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(Order order, String clientName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppTheme.dangerColor),
              const SizedBox(width: 8),
              const Text('Supprimer'),
            ],
          ),
          content: Text(
            'Supprimer la commande pour $clientName ?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
              onPressed: () async {
                final service = ref.read(supabaseServiceProvider);
                try {
                  await service.deleteOrder(order.id);
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(ordersProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e', style: GoogleFonts.inter()),
                        backgroundColor: AppTheme.dangerColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final productsAsync = ref.watch(productsProvider);

    final clients = clientsAsync.value ?? [];
    final products = productsAsync.value ?? [];

    return Scaffold(
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.07),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_cart_outlined, size: 48, color: AppTheme.primaryColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aucune commande',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Réalisez votre première vente !',
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.slateGrey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ordersProvider);
              ref.invalidate(productsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final clientName = clients.firstWhere((c) => c.id == order.clientId, orElse: () => Client(id: '', nameOrCompany: 'Inconnu')).nameOrCompany;
                final dateStr = order.createdAt != null ? DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(order.createdAt!) : '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppTheme.successColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commande #${order.id.length > 5 ? order.id.substring(0, 5) : order.id}',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_rounded, size: 13, color: AppTheme.slateGrey),
                                  const SizedBox(width: 4),
                                  Text(clientName, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.slateGrey, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.slateGrey),
                                  const SizedBox(width: 4),
                                  Text(dateStr, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${order.totalAmount.toStringAsFixed(0)} DH',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _confirmDelete(order, clientName),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(Icons.delete_rounded, color: AppTheme.dangerColor, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 350.ms, delay: (index * 50).ms).slideY(begin: 0.05, duration: 350.ms, delay: (index * 50).ms);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOrderDialog(clients, products),
        child: const Icon(Icons.add_shopping_cart_rounded),
      ),
    );
  }
}
