import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../feed/views/feed_screen.dart';
import '../../marketplace/views/marketplace_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../cat_registry/views/cat_registry_screen.dart';
import '../../../../ui/shared/bottom_nav_component.dart';
import '../../../../ui/shared/login_modal.dart';
import '../../../../ui/core/theme.dart';
import '../../auth/view_models/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const MarketplaceScreen(),
    const CatRegistryScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2 || index == 3) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        setState(() => _currentIndex = index);
      } else {
        showLoginModal(context, onLoginSuccess: () {
          setState(() => _currentIndex = index);
        });
        return;
      }
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _onFabPressed() {
    if (FirebaseAuth.instance.currentUser == null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => LoginModal(
          onLoginSuccess: () => context.push('/feed/create'),
        ),
      );
    } else {
      context.push('/feed/create');
    }
  }

  void showLoginModal(BuildContext context, {VoidCallback? onLoginSuccess}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoginModal(onLoginSuccess: onLoginSuccess),
    );
  }

  Widget? _buildFab() {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: brandPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
      );
    }
    if (_currentIndex == 1) {
      // Marketplace FAB — filter/settings
      return FloatingActionButton(
        onPressed: () {
          if (FirebaseAuth.instance.currentUser == null) {
            showLoginModal(context);
          } else {
            context.push('/marketplace/add');
          }
        },
        backgroundColor: brandPink,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavComponent(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
