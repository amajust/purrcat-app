import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;

  const AppLogo({
    super.key,
    this.iconSize = 32,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: brandPink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.pets,
            color: Colors.white,
            size: iconSize * 0.56,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Purrfect',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: brandPink,
          ),
        ),
      ],
    );
  }
}
