import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/nearby_service_model.dart';
import '../../../../ui/core/theme.dart';

/// Floating mini-card that slides up when a map marker is tapped.
class ServiceMiniCard extends StatelessWidget {
  final NearbyService service;
  final VoidCallback onClose;

  const ServiceMiniCard({
    super.key,
    required this.service,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final color = service.type == ServiceType.vet
        ? const Color(0xFF8B1A4A)
        : brandPink;
    final icon = service.type == ServiceType.vet
        ? Icons.medical_services_rounded
        : Icons.content_cut_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icon badge ────────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),

          // ── Info ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: headingColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  service.typeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFFFB800)),
                    const SizedBox(width: 3),
                    Text(
                      service.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: headingColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${service.reviewCount})',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: bodyColor),
                    ),
                    const Spacer(),
                    Icon(Icons.near_me_rounded,
                        size: 12, color: bodyColor),
                    const SizedBox(width: 3),
                    Text(
                      '${service.distanceKm} km',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: bodyColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Close ─────────────────────────────────────────────────────
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: bodyColor),
            ),
          ),
        ],
      ),
    );
  }
}
