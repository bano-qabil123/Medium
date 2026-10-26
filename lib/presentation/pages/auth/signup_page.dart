import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/core/utils/validators.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:medium_clone/presentation/widgets/common/app_text_field.dart';
import 'package:medium_clone/presentation/widgets/layout/auth_layout.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(authControllerProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.isNotEmpty 
            ? _displayNameController.text.trim() 
            : null,
        username: _usernameController.text.isNotEmpty 
            ? _usernameController.text.trim() 
            : null,
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

  Future<void> _handleGoogleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      
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

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create an account',
      subtitle: 'Join Medium Clone to start reading and writing',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Display Name
              AppTextField(
                controller: _displayNameController,
                labelText: 'Display Name',
                hintText: 'Enter your display name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.validateDisplayName(value, minLength: 2),
                autofocus: true,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Username
              AppTextField(
                controller: _usernameController,
                labelText: 'Username',
                hintText: 'Enter your username',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.validateUsername(value, minLength: 3),
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Email
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              
              // Password
              AppTextFieldPassword(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                validator: (value) => Validators.validatePassword(value, minLength: 8),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSignup(),
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
              
              // Sign Up Button
              AppButton(
                text: 'Sign Up',
                onPressed: _isLoading ? null : _handleSignup,
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
              
              // Google Sign Up
              AppButtonSecondary(
                text: 'Continue with Google',
                onPressed: _isLoading ? null : _handleGoogleSignup,
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
                    'Already have an account?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text(
                      'Sign In',
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
      ),
    );
  }
}
