import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_theme.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDialog([Product? product]) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final specCtrl = TextEditingController(text: product?.specifications ?? '');
    final purchaseCtrl = TextEditingController(
        text: product?.purchasePrice != 0
            ? product?.purchasePrice.toString() ?? ''
            : '');
    final saleCtrl = TextEditingController(
        text: product?.salePrice != 0
            ? product?.salePrice.toString() ?? ''
            : '');
    final stockCtrl = TextEditingController(
        text: product?.stockQuantity.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
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
                          color: AppTheme.installationColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_rounded,
                            color: AppTheme.installationColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Modifier le produit' : 'Nouveau produit',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit',
                      prefixIcon: Icon(Icons.label_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: specCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Spécifications',
                      prefixIcon: Icon(Icons.description_rounded),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: purchaseCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Prix achat (DH)',
                            prefixIcon: Icon(Icons.arrow_downward_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: saleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Prix vente (DH)',
                            prefixIcon: Icon(Icons.arrow_upward_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: stockCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Quantité en stock',
                      prefixIcon: Icon(Icons.warehouse_rounded),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newProduct = Product(
                              id: product?.id ?? '',
                              name: nameCtrl.text,
                              specifications: specCtrl.text.isEmpty
                                  ? null
                                  : specCtrl.text,
                              purchasePrice:
                                  double.tryParse(purchaseCtrl.text) ?? 0.0,
                              salePrice:
                                  double.tryParse(saleCtrl.text) ?? 0.0,
                              stockQuantity:
                                  int.tryParse(stockCtrl.text) ?? 0,
                            );
                            final service = ref.read(supabaseServiceProvider);
                            try {
                              if (isEditing) {
                                await service.updateProduct(newProduct);
                              } else {
                                await service.addProduct(newProduct);
                              }
                              if (context.mounted) Navigator.pop(context);
                              ref.invalidate(productsProvider);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: $e'),
                                    backgroundColor: AppTheme.dangerColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(isEditing ? 'Modifier' : 'Enregistrer'),
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
  }

  void _confirmDelete(Product product) {
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
            'Supprimer "${product.name}" de l\'inventaire ?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerColor),
              onPressed: () async {
                final service = ref.read(supabaseServiceProvider);
                try {
                  await service.deleteProduct(product.id);
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(productsProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppTheme.dangerColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: GoogleFonts.inter(color: AppTheme.slateGrey),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.slateGrey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Stock summary
          productsAsync.when(
            data: (products) {
              final lowStockCount =
                  products.where((p) => p.isLowStock).length;
              if (lowStockCount > 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.dangerColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppTheme.dangerColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '$lowStockCount produit(s) en stock faible',
                          style: GoogleFonts.inter(
                            color: AppTheme.dangerColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // List
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = _searchQuery.isEmpty
                    ? products
                    : products
                        .where((p) =>
                            p.name.toLowerCase().contains(_searchQuery) ||
                            (p.specifications
                                    ?.toLowerCase()
                                    .contains(_searchQuery) ??
                                false))
                        .toList();

                if (filtered.isEmpty) {
                  return _EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: _searchQuery.isEmpty
                        ? 'Inventaire vide'
                        : 'Aucun résultat pour "$_searchQuery"',
                    subtitle: _searchQuery.isEmpty
                        ? 'Ajoutez vos premiers produits ou équipements'
                        : 'Essayez un autre terme de recherche',
                    showAction: _searchQuery.isEmpty,
                    onAction: () => _showProductDialog(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(productsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return _ProductCard(
                        product: product,
                        onEdit: () => _showProductDialog(product),
                        onDelete: () => _confirmDelete(product),
                      )
                          .animate()
                          .fadeIn(
                              duration: 350.ms,
                              delay: (index * 50).ms)
                          .slideY(
                              begin: 0.05,
                              duration: 350.ms,
                              delay: (index * 50).ms);
                    },
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  Color _stockColor(int qty) {
    if (qty == 0) return AppTheme.dangerColor;
    if (qty < 5) return AppTheme.warningColor;
    return AppTheme.maintenanceColor;
  }

  @override
  Widget build(BuildContext context) {
    final stockColor = _stockColor(product.stockQuantity);
    final stockPercent = (product.stockQuantity / 20).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.installationColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.videocam_rounded,
                      color: AppTheme.installationColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (product.isLowStock)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.dangerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.dangerColor.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_rounded,
                                      color: AppTheme.dangerColor, size: 11),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Stock faible',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (product.specifications != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          product.specifications!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.slateGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stock indicator
            Row(
              children: [
                Text(
                  'Stock: ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.slateGrey,
                  ),
                ),
                Text(
                  '${product.stockQuantity} unité(s)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: stockColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stockPercent,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 14),

            // Prices row
            Row(
              children: [
                _PriceChip(
                  label: 'Achat',
                  value: '${product.purchasePrice.toStringAsFixed(0)} DH',
                  color: AppTheme.slateGrey,
                ),
                const SizedBox(width: 8),
                _PriceChip(
                  label: 'Vente',
                  value: '${product.salePrice.toStringAsFixed(0)} DH',
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                if (product.profitMargin > 0)
                  _PriceChip(
                    label: 'Marge',
                    value: '+${product.profitMargin.toStringAsFixed(0)} DH',
                    color: AppTheme.maintenanceColor,
                  ),
                const Spacer(),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.edit_rounded,
                        color: AppTheme.installationColor, size: 20),
                  ),
                ),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.delete_rounded,
                        color: AppTheme.dangerColor, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PriceChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showAction;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showAction = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.slateGrey),
              textAlign: TextAlign.center,
            ),
            if (showAction && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter'),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
