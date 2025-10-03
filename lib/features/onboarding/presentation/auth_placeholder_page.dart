import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_gate_page.dart';

/// Auth page during onboarding - redirects to auth gate
class AuthPlaceholderPage extends ConsumerWidget {
  const AuthPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show the auth gate page
    return const AuthGatePage();
  }
}
