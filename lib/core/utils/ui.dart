import 'package:flutter/material.dart';
import 'package:brightside/core/theme/app_theme.dart';

/// Centralized UI utilities and helpers
class UIHelpers {
  UIHelpers._();

  /// Show a success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show an info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a warning snackbar
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.black87),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade300,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle errors with consistent UI feedback
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final message = customMessage ?? _getErrorMessage(error);

    showErrorSnackBar(
      context,
      message,
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
  }

  /// Extract user-friendly message from error
  static String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    final errorStr = error.toString();

    // Common error patterns
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Failed host lookup')) {
      return 'No internet connection';
    }
    if (errorStr.contains('TimeoutException')) {
      return 'Request timed out';
    }
    if (errorStr.contains('FormatException')) {
      return 'Invalid data format';
    }

    return 'Something went wrong: ${errorStr.length > 100 ? '${errorStr.substring(0, 100)}...' : errorStr}';
  }

  /// Show a loading dialog
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// Dismiss any active dialogs
  static void dismissDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
