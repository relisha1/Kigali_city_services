import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.userProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ─── Profile card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:        AppColors.navyCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Avatar circle
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color:        AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        _initials(profile?.displayName ?? 'U'),
                        style: const TextStyle(
                          color:      AppColors.gold,
                          fontSize:   22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? 'User',
                          style: const TextStyle(
                            color:      AppColors.white,
                            fontSize:   17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile?.email ?? auth.firebaseUser?.email ?? '',
                          style: const TextStyle(color: AppColors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Bookmarks toggle (notifications) ─────────────────────────
            _SettingsSection(
              title: 'Preferences',
              children: [
                _ToggleTile(
                  icon:    Icons.notifications_outlined,
                  label:   'Location Notifications',
                  subtitle: 'Get alerts for new places near you',
                  value:   profile?.notificationsEnabled ?? true,
                  onChanged: (v) => auth.toggleNotifications(v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Account section ───────────────────────────────────────────
            _SettingsSection(
              title: 'Account',
              children: [
                _InfoTile(
                  icon:     Icons.verified_user_outlined,
                  label:    'Email Verification',
                  subtitle: 'Verified',
                  iconColor: AppColors.success,
                ),
                _InfoTile(
                  icon:     Icons.calendar_today_outlined,
                  label:    'Member Since',
                  subtitle: profile != null
                      ? '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}'
                      : '—',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── App section ───────────────────────────────────────────────
            _SettingsSection(
              title: 'App',
              children: [
                _InfoTile(
                  icon:     Icons.info_outline,
                  label:    'Version',
                  subtitle: '1.0.0',
                ),
                _InfoTile(
                  icon:     Icons.location_city_outlined,
                  label:    'Region',
                  subtitle: 'Kigali, Rwanda',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Sign out ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'U';
  }
}

// ─── Section container ────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color:          AppColors.grey,
              fontSize:       11,
              fontWeight:     FontWeight.w600,
              letterSpacing:  1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color:        AppColors.navyCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ─── Read-only info row ───────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   subtitle;
  final Color    iconColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.iconColor = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title:   Text(label,    style: const TextStyle(color: AppColors.white, fontSize: 14)),
      trailing: Text(subtitle, style: const TextStyle(color: AppColors.grey,  fontSize: 13)),
    );
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final String     subtitle;
  final bool       value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary:   Icon(icon, color: AppColors.gold, size: 22),
      title: Text(label,    style: const TextStyle(color: AppColors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.grey,  fontSize: 12)),
      value:       value,
      onChanged:   onChanged,
      activeColor: AppColors.gold,
    );
  }
}
