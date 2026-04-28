import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/presentation/profile_screen.dart';
import '../../../core/providers.dart';
import '../../../core/models/service.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/presentation/widgets/ordex_drawer.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _ClientRequestsView(),
    const _NewRequestView(),
    const _SupportView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OrdexDrawer(isAdmin: false),
      appBar: AppBar(
        title: const Text('Espace Client'),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Mes Demandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Nouvelle',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_rounded),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------
// TAB 1: My Requests View
// ------------------------------------------------------------------------
class _ClientRequestsView extends ConsumerWidget {
  const _ClientRequestsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final serviceProvider = ref.read(supabaseServiceProvider);
    final clientId = serviceProvider.currentUser?.userMetadata?['client_id'] as String?;

    return servicesAsync.when(
      data: (allServices) {
        // Filter services for this specific client
        final myServices = allServices.where((s) => s.clientId == clientId).toList();

        if (myServices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 60, color: AppTheme.slateGrey.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'Aucune demande pour le moment',
                  style: GoogleFonts.inter(color: AppTheme.slateGrey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(servicesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myServices.length,
            itemBuilder: (context, index) {
              final s = myServices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.type,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: s.status == 'Terminé' 
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.status,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: s.status == 'Terminé' ? AppTheme.successColor : AppTheme.warningColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (s.description != null && s.description!.isNotEmpty)
                        Text(
                          s.description!,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (s.createdAt != null) ...[
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.slateGrey),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy', 'fr_FR').format(s.createdAt!),
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.slateGrey),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '${s.totalPrice.toStringAsFixed(0)} DH',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

// ------------------------------------------------------------------------
// TAB 2: New Request View
// ------------------------------------------------------------------------
class _NewRequestView extends ConsumerStatefulWidget {
  const _NewRequestView();

  @override
  ConsumerState<_NewRequestView> createState() => _NewRequestViewState();
}

class _NewRequestViewState extends ConsumerState<_NewRequestView> {
  final _descController = TextEditingController();
  String _selectedType = 'Installation';
  bool _isSubmitting = false;

  final List<String> _types = [
    'Installation',
    'Réparation',
    'Maintenance',
    'Autre',
  ];

  Future<void> _submitRequest() async {
    final service = ref.read(supabaseServiceProvider);
    final clientId = service.currentUser?.userMetadata?['client_id'] as String?;

    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Profil client non configuré.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final newTask = ServiceTask(
        id: '',
        clientId: clientId,
        type: _selectedType,
        description: _descController.text.isEmpty ? null : _descController.text,
        totalPrice: 0.0, // Fixed by admin later
        status: 'En attente',
      );

      await service.addService(newTask);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Votre demande a bien été envoyée !', style: GoogleFonts.inter()),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _descController.clear();
        ref.invalidate(servicesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e', style: GoogleFonts.inter()),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formulaire de Demande',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Décrivez-nous votre besoin, notre équipe vous contactera sous peu.',
            style: GoogleFonts.inter(color: AppTheme.slateGrey),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Type de service',
            ),
            items: _types.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type, style: GoogleFonts.inter()),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description du problème ou besoin',
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitRequest,
              icon: const Icon(Icons.send_rounded),
              label: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Envoyer la demande'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }
}

// ------------------------------------------------------------------------
// TAB 3: Support View
// ------------------------------------------------------------------------
class _SupportView extends StatelessWidget {
  const _SupportView();

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.headset_mic_rounded, size: 64, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Besoin d\'aide ?',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notre équipe de support est là pour vous accompagner.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.slateGrey, fontSize: 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl('tel:+21300000000'),
                icon: const Icon(Icons.phone_rounded),
                label: const Text('Appeler l\'assistance'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.successColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl('mailto:support@ordex.dz?subject=Demande%20Support%20Client'),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Envoyer un email', style: TextStyle(color: AppTheme.primaryColor)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }
}
