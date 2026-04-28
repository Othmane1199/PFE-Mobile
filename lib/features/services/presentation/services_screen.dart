import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/models/service.dart';
import '../../../core/models/client.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/presentation/widgets/ordex_drawer.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final List<String> _types = [
    'Installation',
    'Réparation',
    'Maintenance',
    'Autre',
  ];

  String? _filterType;

  void _showServiceDialog(List<Client> clients, [ServiceTask? serviceTask]) {
    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez d\'abord créer un client', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final isEditing = serviceTask != null;
    String? selectedClientId =
        serviceTask?.clientId ?? (clients.isNotEmpty ? clients.first.id : null);
    if (selectedClientId != null &&
        !clients.any((c) => c.id == selectedClientId)) {
      selectedClientId = clients.isNotEmpty ? clients.first.id : null;
    }
    String selectedType =
        serviceTask != null && _types.contains(serviceTask.type)
            ? serviceTask.type
            : _types.first;
    String selectedStatus = serviceTask?.status ?? 'En attente';

    final descCtrl = TextEditingController(text: serviceTask?.description ?? '');
    final durationCtrl = TextEditingController(text: serviceTask?.duration ?? '');
    final priceCtrl = TextEditingController(
        text: serviceTask?.totalPrice != 0
            ? serviceTask?.totalPrice.toString() ?? ''
            : '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                              color: AppTheme.maintenanceColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.build_rounded,
                                color: AppTheme.maintenanceColor),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? 'Modifier le service' : 'Nouveau service',
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
                            child: Text(client.nameOrCompany,
                                style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setStateDialog(() => selectedClientId = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type d\'intervention',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setStateDialog(() => selectedType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.flag_rounded),
                        ),
                        items: ServiceTask.validStatuses.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setStateDialog(() => selectedStatus = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: durationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Durée (ex: 2 heures)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Prix total (DH)',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                                final newService = ServiceTask(
                                  id: serviceTask?.id ?? '',
                                  clientId: selectedClientId ?? '',
                                  type: selectedType,
                                  description: descCtrl.text.isEmpty
                                      ? null
                                      : descCtrl.text,
                                  duration: durationCtrl.text.isEmpty
                                      ? null
                                      : durationCtrl.text,
                                  totalPrice:
                                      double.tryParse(priceCtrl.text) ?? 0.0,
                                  status: selectedStatus,
                                );
                                final service =
                                    ref.read(supabaseServiceProvider);
                                try {
                                  if (isEditing) {
                                    await service.updateService(newService);
                                  } else {
                                    await service.addService(newService);
                                  }
                                  if (context.mounted) Navigator.pop(context);
                                  ref.invalidate(servicesProvider);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur: $e',
                                            style: GoogleFonts.inter()),
                                        backgroundColor: AppTheme.dangerColor,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
      },
    );
  }

  void _confirmDelete(ServiceTask serviceTask, String clientName) {
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
            'Supprimer cette intervention "${serviceTask.type}" pour $clientName ?',
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
                  await service.deleteService(serviceTask.id);
                  if (context.mounted) Navigator.pop(context);
                  ref.invalidate(servicesProvider);
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
    final servicesAsync = ref.watch(servicesProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final clients = clientsAsync.value ?? [];

    return Scaffold(
      drawer: const OrdexDrawer(isAdmin: true),
      appBar: AppBar(
        title: const Text('Services & Interventions'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(servicesProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: _filterType == null,
                  color: AppTheme.primaryColor,
                  onTap: () => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                ..._types.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: type,
                      selected: _filterType == type,
                      color: AppTheme.serviceTypeColor(type),
                      onTap: () =>
                          setState(() => _filterType = _filterType == type ? null : type),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: servicesAsync.when(
              data: (services) {
                final filtered = _filterType == null
                    ? services
                    : services.where((s) => s.type == _filterType).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(
                    icon: Icons.build_circle_outlined,
                    title: 'Aucune intervention trouvée',
                    subtitle: _filterType != null
                        ? 'Aucun service de type "$_filterType"'
                        : 'Ajoutez votre première intervention',
                    showAction: _filterType == null,
                    onAction: () => _showServiceDialog(clients),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(servicesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final service = filtered[index];
                      final clientName = clients
                              .firstWhere(
                                (c) => c.id == service.clientId,
                                orElse: () => Client(
                                    id: '', nameOrCompany: 'Client inconnu'),
                              )
                              .nameOrCompany;

                      return _ServiceCard(
                        service: service,
                        clientName: clientName,
                        onEdit: () => _showServiceDialog(clients, service),
                        onDelete: () => _confirmDelete(service, clientName),
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
        onPressed: () => _showServiceDialog(clients),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.slateGrey,
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceTask service;
  final String clientName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.clientName,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (service.status) {
      case 'En cours':
        return AppTheme.installationColor;
      case 'Terminé':
        return AppTheme.maintenanceColor;
      default:
        return AppTheme.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.serviceTypeColor(service.type);
    final dateStr = service.createdAt != null
        ? DateFormat('dd MMM yyyy', 'fr_FR').format(service.createdAt!)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.build_rounded, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              service.type,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              service.status,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded,
                              size: 13, color: AppTheme.slateGrey),
                          const SizedBox(width: 4),
                          Text(
                            clientName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.slateGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${service.totalPrice.toStringAsFixed(0)} DH',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            if (service.description != null) ...[
              const SizedBox(height: 10),
              Text(
                service.description!,
                 style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                if (service.duration != null) ...[
                  const Icon(Icons.timer_outlined,
                      size: 13, color: AppTheme.slateGrey),
                  const SizedBox(width: 4),
                  Text(
                    service.duration!,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.slateGrey),
                  ),
                  const SizedBox(width: 12),
                ],
                if (dateStr != null) ...[
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppTheme.slateGrey),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.slateGrey),
                  ),
                ],
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
