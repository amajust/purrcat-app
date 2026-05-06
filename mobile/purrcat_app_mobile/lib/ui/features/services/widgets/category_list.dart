import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/core/theme.dart';
import '../../../../data/models/services_model.dart';
import '../../../../data/services/mock_services_data.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: serviceCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = serviceCategories[index];
          return _CategoryCard(category: cat);
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ServiceCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: category.bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Icon top-left
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: brandPink,
                  size: 22,
                ),
              ),
            ),

            // Text bottom-left
            Positioned(
              left: 14,
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: headingColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.subLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: bodyColor,
                    ),
                  ),
                ],
              ),
            ),

            // Paw-print watermark bottom-right
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.pets,
                  size: 80,
                  color: headingColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
