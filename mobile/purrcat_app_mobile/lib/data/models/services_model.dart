import 'package:flutter/material.dart';

class Expert {
  final String id;
  final String name;
  final String designation;
  final String specialty;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double distanceKm;
  final String? profileImageUrl;
  final List<String> availableSlots;

  const Expert({
    required this.id,
    required this.name,
    required this.designation,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.distanceKm,
    this.profileImageUrl,
    required this.availableSlots,
  });
}

class ServiceCategory {
  final String id;
  final String label;
  final String subLabel;
  final IconData icon;
  final Color bgColor;

  const ServiceCategory({
    required this.id,
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.bgColor,
  });
}
