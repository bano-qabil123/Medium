import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/settings_provider.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/common/app_divider.dart';
import 'package:medium_clone/presentation/widgets/layout/main_layout.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return MainLayout(
      title: 'Settings',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User section
            if (user != null) ...[
              _buildUserSection(context, user),
              const SizedBox(height: AppDimensions.spacingLarge),
              const AppDivider(),
              const SizedBox(height: AppDimensions.spacingLarge),
            ],

            // Appearance section
            _buildSectionHeader('Appearance'),
            const SizedBox(height: AppDimensions.spacingSmall),
            
            _buildSettingCard(
              title: 'Theme',
              child: _buildThemeSelector(),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            
            _buildSettingCard(
              title: 'Font Size',
              child: _buildFontSizeSlider(),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            
            _buildSettingCard(
              title: 'Font Family',
              child: _buildFontFamilySelector(),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            
            _buildSettingCard(
              title: 'Line Height',
              child: _buildLineHeightSlider(),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // Account section
            _buildSectionHeader('Account'),
            const SizedBox(height: AppDimensions.spacingSmall),
            
            if (user != null) ...[
              _buildSettingCard(
                title: 'Profile',
                child: _buildProfileButton(),
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              
              _buildSettingCard(
                title: 'Sign Out',
                child: _buildSignOutButton(),
              ),
            ] else ...[
              _buildSettingCard(
                title: 'Sign In',
                child: _buildSignInButton(),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // About section
            _buildSectionHeader('About'),
            const SizedBox(height: AppDimensions.spacingSmall),
            
            _buildSettingCard(
              title: 'App Version',
              child: _buildVersionInfo(),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            
            _buildSettingCard(
              title: 'Open Source',
              child: _buildOpenSourceInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signed in as',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXSmall),
        Row(
          children: [
            // Avatar
            Container(
              width: AppDimensions.avatarSizeMedium,
              height: AppDimensions.avatarSizeMedium,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.displayName?.isNotEmpty == true 
                    ? user.displayName![0].toUpperCase() 
                    : 'U',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingCard({required String title, required Widget child}) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('System'),
          value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (value) => notifier.updateThemeMode(value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (value) => notifier.updateThemeMode(value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          value: ThemeMode.dark,
          groupValue: themeMode,
          onChanged: (value) => notifier.updateThemeMode(value!),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider() {
    final fontSize = ref.watch(fontSizeProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: fontSize,
          min: 12,
          max: 24,
          divisions: 12,
          label: 'Font Size: ${fontSize.toInt()}',
          onChanged: (value) => notifier.updateFontSize(value),
        ),
        Text(
          'Current: ${fontSize.toInt()}px',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector() {
    final fontFamily = ref.watch(fontFamilyProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile<FontFamily>(
          title: const Text('Merriweather (Serif)'),
          subtitle: const Text('Best for reading long articles'),
          value: FontFamily.merriweather,
          groupValue: fontFamily,
          onChanged: (value) => notifier.updateFontFamily(value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<FontFamily>(
          title: const Text('Inter (Sans-Serif)'),
          subtitle: const Text('Clean and modern'),
          value: FontFamily.inter,
          groupValue: fontFamily,
          onChanged: (value) => notifier.updateFontFamily(value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<FontFamily>(
          title: const Text('System'),
          subtitle: const Text('Use device default font'),
          value: FontFamily.system,
          groupValue: fontFamily,
          onChanged: (value) => notifier.updateFontFamily(value!),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildLineHeightSlider() {
    final lineHeight = ref.watch(lineHeightProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: lineHeight,
          min: 1.2,
          max: 2.0,
          divisions: 16,
          label: 'Line Height: ${lineHeight.toStringAsFixed(1)}',
          onChanged: (value) => notifier.updateLineHeight(value),
        ),
        Text(
          'Current: ${lineHeight.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButtonSecondary(
        text: 'View Profile',
        onPressed: () => context.push('/profile'),
      ),
    );
  }

  Widget _buildSignOutButton() {
    final authNotifier = ref.read(authProvider.notifier);

    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: 'Sign Out',
        onPressed: () => authNotifier.signOut(),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: 'Sign In',
        onPressed: () => context.push('/login'),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      '1.0.0',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildOpenSourceInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This app is open source.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppDimensions.spacingXSmall),
        Text(
          'Built with Flutter and Supabase',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
