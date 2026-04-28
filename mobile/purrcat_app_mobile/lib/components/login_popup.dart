import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Reusable LoginPopup widget that appears as a modal bottom sheet
/// when unauthenticated users try to access auth-required features.
class LoginPopup {
  /// Show the login popup. Returns `true` if user logged in successfully.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LoginPopupSheet(),
    );
    return result ?? false;
  }
}

class _LoginPopupSheet extends StatefulWidget {
  const _LoginPopupSheet();

  @override
  State<_LoginPopupSheet> createState() => _LoginPopupSheetState();
}

class _LoginPopupSheetState extends State<_LoginPopupSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Lock icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFA03A57).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 36,
              color: Color(0xFFA03A57),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sign in to continue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Login to like, comment, and interact with the community',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Google Sign-In button
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: auth.isLoading ? null : () => _handleGoogleSignIn(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  icon: Image.asset(
                    'assets/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  label: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Continue with Google',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Email login option
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                // Navigate to login screen
                Navigator.of(context).pushNamed('/login');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFA03A57),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign in with Email',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle();

    if (success && context.mounted) {
      Navigator.of(context).pop(true);
    } else if (context.mounted) {
      final error = auth.error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
