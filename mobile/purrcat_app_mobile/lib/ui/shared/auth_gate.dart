import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/theme.dart';
import 'login_modal.dart';

/// A wrapper widget that gates the [child] behind an authentication check.
///
/// If the user is **not** signed in, an overlay with a login prompt is shown
/// instead of [child]. An optional [onLoginRequired] callback fires whenever
/// an unauthenticated user hits the gate (useful for analytics or custom
/// redirects).
class AuthGate extends StatelessWidget {
  /// The widget to display when the user is authenticated.
  final Widget child;

  /// Optional callback invoked when an unauthenticated user attempts to
  /// access the gated content.
  final VoidCallback? onLoginRequired;

  const AuthGate({
    super.key,
    required this.child,
    this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return child;
    }

    // Fire the callback (only once per build cycle is fine; it's a
    // functional callback, not a side-effect in build itself).
    onLoginRequired?.call();

    return _LoginPrompt(
      onSignIn: () => _showLoginModal(context),
    );
  }

  // ── Static helper ───────────────────────────────────────────────────

  /// Checks whether the current user is authenticated. If yes, [action] is
  /// executed immediately. If not, the login modal is shown. After a
  /// successful login the [action] **is not** automatically retried —
  /// callers should listen to auth state changes to react accordingly.
  static void requireAuth(BuildContext context, VoidCallback action) {
    if (FirebaseAuth.instance.currentUser != null) {
      action();
      return;
    }
    _showLoginModal(context);
  }

  static void _showLoginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LoginModal(),
    );
  }
}

/// Inline prompt shown when a user is not authenticated.
class _LoginPrompt extends StatelessWidget {
  final VoidCallback onSignIn;

  const _LoginPrompt({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cat icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: brandPink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pets, size: 40, color: brandPink),
              ),
              const SizedBox(height: 24),
              Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access this feature and connect with fellow cat lovers.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: bodyColor, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
