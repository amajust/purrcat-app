import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../ui/core/theme.dart';

class ServicesHeader extends StatelessWidget {
  const ServicesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sub-header + View All ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEARBY EXPERTS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8B1A4A),
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: brandPink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // ── Main Title ──
          Text(
            'Premium Services',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: headingColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
