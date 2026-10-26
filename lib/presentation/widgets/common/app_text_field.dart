import 'package:flutter/material.dart';
import 'package:medium_clone/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.placeholder,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.style,
    this.decoration,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      focusNode: focusNode,
      style: style ?? AppTypography.bodyLarge.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: decoration ?? InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.onSurface.withOpacity(0.5),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefix: prefix,
        suffix: suffix,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}

class AppTextFieldSearch extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onClearPressed;
  final bool autofocus;
  final bool readOnly;
  
  const AppTextFieldSearch({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onSearchPressed,
    this.onClearPressed,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: hintText ?? 'Search...',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      autofocus: autofocus,
      readOnly: readOnly,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.search, color: AppColors.grey),
      suffixIcon: controller != null && controller!.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.grey),
              onPressed: () {
                controller?.clear();
                onClearPressed?.call();
              },
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          : null,
    );
  }
}

class AppTextFieldPassword extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool showVisibilityToggle;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  
  const AppTextFieldPassword({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.showVisibilityToggle = true,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppTextFieldPassword> createState() => _AppTextFieldPasswordState();
}

class _AppTextFieldPasswordState extends State<AppTextFieldPassword> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: widget.onChanged,
      validator: widget.validator,
      suffixIcon: widget.showVisibilityToggle
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.grey,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          : null,
    );
  }
}

class AppTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  
  const AppTextArea({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.maxLines = 5,
    this.minLines = 3,
    this.maxLength,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      autocorrect: true,
      enableSuggestions: true,
    );
  }
}
