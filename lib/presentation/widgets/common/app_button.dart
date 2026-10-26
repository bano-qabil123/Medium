import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final bool disabled;
  
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        style: style ?? ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          disabledForegroundColor: AppColors.onPrimary.withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.iconSmall,
                height: AppDimensions.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    const SizedBox(width: AppDimensions.spacingSmall),
                  ],
                  Text(text),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: AppDimensions.spacingSmall),
                    trailingIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

class AppButtonSecondary extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final bool disabled;
  
  const AppButtonSecondary({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        style: style ?? OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          side: BorderSide(color: AppColors.primary),
          textStyle: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          disabledForegroundColor: AppColors.primary.withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.iconSmall,
                height: AppDimensions.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    const SizedBox(width: AppDimensions.spacingSmall),
                  ],
                  Text(text),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: AppDimensions.spacingSmall),
                    trailingIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

class AppButtonText extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool disabled;
  
  const AppButtonText({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall,
        ),
        disabledForegroundColor: AppColors.primary.withOpacity(0.5),
      ),
      child: isLoading
          ? const SizedBox(
              width: AppDimensions.iconSmall,
              height: AppDimensions.iconSmall,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: AppDimensions.spacingSmall),
                ],
                Text(
                  text,
                  style: style ?? AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppDimensions.spacingSmall),
                  trailingIcon!,
                ],
              ],
            ),
    );
  }
}

class AppButtonIcon extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final bool fullWidth;
  final bool disabled;
  
  const AppButtonIcon({
    super.key,
    required this.icon,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        style: style ?? ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          disabledForegroundColor: AppColors.onPrimary.withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.iconSmall,
                height: AppDimensions.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              )
            : icon,
      ),
    );
  }
}
