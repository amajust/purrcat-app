import 'package:flutter/material.dart';

// Global Theme Colors (corrected to match Figma design)
const Color brandPink = Color(0xFFA03A57);
const Color headingColor = Color(0xFF1A1A1A);
const Color bodyColor = Color(0xFF757575);
const Color backgroundColor = Colors.white;

class BottomNavComponent extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavComponent({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandPink,
        unselectedItemColor: bodyColor,
        backgroundColor: backgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: currentIndex == 0 ? brandPink.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                currentIndex == 0 ? Icons.dynamic_feed : Icons.dynamic_feed,
                size: 24,
              ),
            ),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: currentIndex == 1 ? brandPink.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                currentIndex == 1 ? Icons.storefront : Icons.storefront_outlined,
                size: 24,
              ),
            ),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: currentIndex == 2 ? brandPink.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                currentIndex == 2 ? Icons.miscellaneous_services : Icons.miscellaneous_services_outlined,
                size: 24,
              ),
            ),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: currentIndex == 3 ? brandPink.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                currentIndex == 3 ? Icons.person : Icons.person_outline,
                size: 24,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
