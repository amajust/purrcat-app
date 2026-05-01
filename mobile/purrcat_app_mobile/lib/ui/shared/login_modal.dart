import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view_models/auth_provider.dart';

class LoginModal extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const LoginModal({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          // Logo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFA03A57),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to PurrCat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your profile and connect with cat lovers',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          // Google Sign In
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final success = await auth.signInWithGoogle();
                      if (success && context.mounted) {
                        onLoginSuccess?.call();
                        Navigator.of(context, rootNavigator: true).pop();
                      } else if (context.mounted && auth.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(auth.error!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              icon: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Image.asset(
                      'assets/images/google_logo.png',
                      width: 24,
                      height: 24,
                    ),
              label: Text(
                auth.isLoading ? 'Signing in...' : 'Sign in with Google',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color(0xFFDADCE0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Email Sign In
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : () {
                      Navigator.of(context, rootNavigator: true).pop();
                      context.push('/login');
                    },
              icon: const Icon(Icons.email_outlined, size: 20),
              label: const Text('Continue with Email'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFFA03A57),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.grey[600]),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  context.push('/register');
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFFA03A57),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
