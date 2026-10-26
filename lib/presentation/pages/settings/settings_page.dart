import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/layout/main_layout.dart';

/// Optimized settings page with const constructors
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      key: const ValueKey('settings-page'),
      title: 'Settings',
      showBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildSection(
              title: 'Profile',
              children: const [
                _SettingsListTile(
                  leading: Icon(Icons.person_outline),
                  title: 'Edit Profile',
                ),
              ],
            ),
            
            // Account Section
            _buildSection(
              title: 'Account',
              children: const [
                _SettingsListTile(
                  leading: Icon(Icons.password_outlined),
                  title: 'Change Password',
                ),
                _SettingsListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: 'Notifications',
                ),
              ],
            ),
            
            // Appearance Section
            _buildSection(
              title: 'Appearance',
              children: [
                const _SettingsListTile(
                  leading: Icon(Icons.dark_mode_outlined),
                  title: 'Dark Mode',
                  trailing: _DarkModeToggle(),
                ),
                const _SettingsListTile(
                  leading: Icon(Icons.text_increase_outlined),
                  title: 'Text Size',
                ),
              ],
            ),
            
            // About Section
            _buildSection(
              title: 'About',
              children: const [
                _SettingsListTile(
                  leading: Icon(Icons.info_outline),
                  title: 'About Medium Clone',
                ),
                _SettingsListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: 'Privacy Policy',
                ),
                _SettingsListTile(
                  leading: Icon(Icons.description_outlined),
                  title: 'Terms of Service',
                ),
              ],
            ),
            
            // Sign Out
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButtonSecondary(
                text: 'Sign Out',
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                fullWidth: true,
              ),
            ),
            
            // Version
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Version 1.0.0',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AppCard(
          hasBorder: true,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

/// Settings list tile with const constructor
class _SettingsListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const _SettingsListTile({
    super.key,
    required this.leading,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      minLeadingWidth: 0,
    );
  }
}

/// Dark mode toggle widget
class _DarkModeToggle extends ConsumerStatefulWidget {
  const _DarkModeToggle({super.key});

  @override
  ConsumerState<_DarkModeToggle> createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends ConsumerState<_DarkModeToggle> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isDarkMode,
      onChanged: (value) => setState(() => _isDarkMode = value),
    );
  }
}
