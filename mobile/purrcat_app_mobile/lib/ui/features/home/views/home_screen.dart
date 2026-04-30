import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../feed/views/feed_screen.dart';
import '../../marketplace/views/marketplace_screen.dart';
import '../../../../ui/shared/bottom_nav_component.dart';
import '../../../../ui/shared/login_modal.dart';
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
    const Center(child: Text('Services Screen')),
    const Center(child: Text('Profile Screen')),
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        setState(() => _currentIndex = 3);
      } else {
        showLoginModal(context);
        return;
      }
    }
    setState(() => _currentIndex = index);
  }

  void showLoginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LoginModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavComponent(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
