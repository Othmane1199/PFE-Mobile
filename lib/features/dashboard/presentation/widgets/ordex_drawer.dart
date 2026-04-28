import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/profile_screen.dart';
import '../../../../core/widgets/ordex_logo.dart';
import '../reports_screen.dart';

class OrdexDrawer extends ConsumerWidget {
  final bool isAdmin;
  const OrdexDrawer({super.key, this.isAdmin = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(supabaseServiceProvider);
    final user = service.currentUser;
    final metadata = user?.userMetadata ?? {};
    final userEmail = user?.email ?? 'utilisateur@ordex.dz';
    final userName = metadata['name'] ?? userEmail.split('@').first;
    final userRole = metadata['role'] ?? (isAdmin ? 'Administrateur' : 'Client');

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 32,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const OrdexLogo(
                    size: 50,
                    showText: false,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    userRole,
                    style: GoogleFonts.inter(
                      color: AppTheme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                if (isAdmin) ...[
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(dashboardIndexProvider.notifier).setIndex(0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_rounded,
                    label: 'Ventes',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(dashboardIndexProvider.notifier).setIndex(1);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.build_rounded,
                    label: 'Services',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(dashboardIndexProvider.notifier).setIndex(2);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people_rounded,
                    label: 'Clients',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(dashboardIndexProvider.notifier).setIndex(3);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.analytics_rounded,
                    label: 'Rapports',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(),
                  ),
                ],
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                const _ThemeSwitchTile(),
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(supabaseServiceProvider).signOut();
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerColor),
                label: Text(
                  'Se déconnecter',
                  style: GoogleFonts.inter(
                    color: AppTheme.dangerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.dangerColor.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _ThemeSwitchTile extends ConsumerStatefulWidget {
  const _ThemeSwitchTile();

  @override
  ConsumerState<_ThemeSwitchTile> createState() => _ThemeSwitchTileState();
}

class _ThemeSwitchTileState extends ConsumerState<_ThemeSwitchTile> {
  bool? _localValue;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = _localValue ?? (themeMode == ThemeMode.dark);

    return SwitchListTile(
      title: Text(
        'Mode Sombre',
        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
      secondary: Icon(
        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
      )
          .animate(key: ValueKey(isDark))
          .scale(duration: const Duration(milliseconds: 300), curve: Curves.easeOutBack)
          .rotate(begin: isDark ? -0.5 : 0.5, end: 0, duration: const Duration(milliseconds: 300)),
      value: isDark,
      onChanged: (val) {
        // Toggle UI locally immediately
        setState(() => _localValue = val);
        
        // Wait just enough to not stutter the initial native switch thumb
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            ref.read(themeModeProvider.notifier).toggle(val);
            setState(() => _localValue = null); // re-sync
          }
        });
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(icon, color: isDark ? AppTheme.accentColor : AppTheme.primaryColor),
      title: Text(
        label,
        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
