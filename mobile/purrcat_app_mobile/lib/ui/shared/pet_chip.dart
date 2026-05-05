import 'package:flutter/material.dart';

import '../core/theme.dart';

class PetChip extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const PetChip({
    super.key,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? brandPink : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: color,
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? brandPink : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
