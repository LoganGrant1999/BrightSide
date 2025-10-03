import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import '../providers/auth_provider.dart';

class AuthGatePage extends ConsumerWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show error if exists
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.red,
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // App logo/icon
              Icon(
                Icons.wb_sunny,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to BrightSide',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Apple Sign In (iOS only)
              if (Platform.isIOS) ...[
                _SignInButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authProvider.notifier).signInWithApple(),
                  icon: Icons.apple,
                  label: 'Continue with Apple',
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
              ],

              // Google Sign In
              _SignInButton(
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).signInWithGoogle(),
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                hasBorder: true,
              ),
              const SizedBox(height: 12),

              // Email Sign In
              _SignInButton(
                onPressed: authState.isLoading
                    ? null
                    : () => context.push('/auth/email'),
                icon: Icons.email,
                label: 'Continue with Email',
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),

              const SizedBox(height: 24),

              // Loading indicator
              if (authState.isLoading)
                const Center(child: CircularProgressIndicator()),

              const Spacer(),

              // Terms and privacy
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool hasBorder;

  const _SignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: hasBorder ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: hasBorder
                ? BorderSide(color: Colors.grey[300]!, width: 1)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
