import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final bool showLogo;
  
  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.footer,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.spacingXXLarge),
              
              if (showLogo) ...[
                const FlutterLogo(size: AppDimensions.iconXLarge),
                const SizedBox(height: AppDimensions.spacingLarge),
              ],
              
              Text(
                title,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.spacingSmall),
                Text(
                  subtitle!,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: AppDimensions.spacingXLarge),
              
              child,
              
              if (footer != null) ...[
                const SizedBox(height: AppDimensions.spacingLarge),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLogo;
  
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo) ...[
          const FlutterLogo(size: AppDimensions.iconXLarge),
          const SizedBox(height: AppDimensions.spacingLarge),
        ],
        Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (subtitle != null) ...[
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            subtitle!,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class AuthFooter extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onActionPressed;
  
  const AuthFooter({
    super.key,
    required this.text,
    required this.actionText,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionText,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
