import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/validators.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_text_field.dart';
import 'package:medium_clone/presentation/widgets/common/app_loading.dart';
import 'package:medium_clone/presentation/widgets/layout/auth_layout.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(authControllerProvider.notifier).signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Navigate to home on success
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to Medium Clone',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email
            AppTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.validateEmail,
              autofocus: true,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            
            // Password
            AppTextFieldPassword(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              validator: (value) => Validators.validatePassword(value, minLength: 8),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: AppDimensions.spacingMedium),
              Text(
                _errorMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // Sign In Button
            AppButton(
              text: 'Sign In',
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              fullWidth: true,
            ),
            
            const SizedBox(height: AppDimensions.spacingMedium),
            
            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMedium),
                  child: Text(
                    'or',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spacingMedium),
            
            // Google Sign In
            AppButtonSecondary(
              text: 'Continue with Google',
              onPressed: _isLoading ? null : _handleGoogleLogin,
              isLoading: _isLoading,
              fullWidth: true,
              leadingIcon: const Icon(Icons.g_mobiledata, size: AppDimensions.iconSmall),
            ),
            
            const SizedBox(height: AppDimensions.spacingLarge),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text(
                    'Sign Up',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
