import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_card.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;
    
    return MainLayout(
      title: 'Settings',
      showBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildSection(
              title: 'Profile',
              children: [
                _buildListTile(
                  leading: const Icon(Icons.person_outline),
                  title: 'Edit Profile',
                  onTap: () {
                    // TODO: Navigate to edit profile
                  },
                ),
              ],
            ),
            
            // Account Section
            _buildSection(
              title: 'Account',
              children: [
                _buildListTile(
                  leading: const Icon(Icons.password_outlined),
                  title: 'Change Password',
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                ),
                _buildListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: 'Notifications',
                  onTap: () {
                    // TODO: Navigate to notifications settings
                  },
                ),
              ],
            ),
            
            // Appearance Section
            _buildSection(
              title: 'Appearance',
              children: [
                _buildListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: true, // TODO: Get from theme
                    onChanged: (value) {
                      // TODO: Toggle dark mode
                    },
                  ),
                ),
                _buildListTile(
                  leading: const Icon(Icons.text_increase_outlined),
                  title: 'Text Size',
                  onTap: () {
                    // TODO: Show text size options
                  },
                ),
              ],
            ),
            
            // About Section
            _buildSection(
              title: 'About',
              children: [
                _buildListTile(
                  leading: const Icon(Icons.info_outline),
                  title: 'About Medium Clone',
                  onTap: () {
                    // TODO: Show about dialog
                  },
                ),
                _buildListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
                _buildListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: 'Terms of Service',
                  onTap: () {
                    // TODO: Show terms of service
                  },
                ),
              ],
            ),
            
            // Sign Out
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingLarge),
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
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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

  Widget _buildListTile({
    required Widget leading,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: AppDimensions.iconSmall),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
    );
  }
}
