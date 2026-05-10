import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;
import '../../../../ui/core/theme.dart';
import '../../../../data/models/services_model.dart';

class ExpertCard extends StatefulWidget {
  final Expert expert;

  const ExpertCard({super.key, required this.expert});

  @override
  State<ExpertCard> createState() => _ExpertCardState();
}

class _ExpertCardState extends State<ExpertCard> {
  String? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final expert = widget.expert;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Image ──
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: expert.profileImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: expert.profileImageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, stack) => _fallbackAvatar(),
                        placeholder: (ctx, i) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 56,
                            height: 56,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : _fallbackAvatar(),
              ),
              const SizedBox(width: 12),

              // ── Info Section ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Distance
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expert.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: headingColor,
                            ),
                          ),
                        ),
                        // Distance badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${expert.distanceKm} KM',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: bodyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Star Rating + Reviews
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${expert.rating}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${expert.reviewCount} reviews)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: bodyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Designation + YoE
                    Text(
                      expert.designation,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: bodyColor,
                      ),
                    ),
                    Text(
                      '${expert.specialty} · ${expert.experienceYears} yr exp',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: bodyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── AVAILABLE TODAY + Time Slots ──
          Text(
            'AVAILABLE TODAY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: brandPink,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: expert.availableSlots.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final slot = expert.availableSlots[index];
                final isSelected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSlot = slot);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? brandPink : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                    ),
                    child: Text(
                      slot,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : headingColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: brandPink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.person, color: brandPink, size: 28),
    );
  }
}
