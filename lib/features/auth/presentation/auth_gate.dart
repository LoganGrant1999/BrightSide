import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/features/auth/providers/auth_provider.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/core/utils/ui.dart';

class AuthGate extends ConsumerWidget {
  final Widget child;

  const AuthGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.signedIn => child,
      AuthStatus.signedOut => const SignInScreen(),
      AuthStatus.loading => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
    };
  }
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailSignIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show error if present
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UIHelpers.showErrorSnackBar(context, authState.error!);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Title
                Icon(
                  Icons.wb_sunny,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'BrightSide',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                  'Your local stories, amplified',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.paddingXLarge),

                if (_isEmailSignIn) ...[
                  // Email sign in form
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _handleEmailSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    ),
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEmailSignIn = false;
                      });
                    },
                    child: const Text('Back to other options'),
                  ),
                ] else ...[
                  // Social sign in buttons
                  _SignInButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _handleGoogleSignIn,
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _SignInButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _handleAppleSignIn,
                    icon: Icons.apple,
                    label: 'Continue with Apple',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _SignInButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () {
                            setState(() {
                              _isEmailSignIn = true;
                            });
                          },
                    icon: Icons.email,
                    label: 'Email sign in',
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ],

                const SizedBox(height: AppTheme.paddingXLarge),

                // Terms and privacy
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    await ref.read(authProvider.notifier).signInWithApple();
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      UIHelpers.showErrorSnackBar(context, 'Please enter email and password');
      return;
    }

    await ref.read(authProvider.notifier).signInWithEmail(email, password);
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _SignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        elevation: 2,
        side: backgroundColor == Colors.white
            ? BorderSide(color: Colors.grey.shade300)
            : null,
      ),
    );
  }
}
