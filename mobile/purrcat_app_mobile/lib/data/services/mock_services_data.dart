import 'package:flutter/material.dart';
import '../../../data/models/services_model.dart';

const List<ServiceCategory> serviceCategories = [
  ServiceCategory(
    id: 'vaccinations',
    label: 'Vaccinations',
    subLabel: '12 Vets available',
    icon: Icons.vaccines,
    bgColor: Color(0xFFFCE4EC),
  ),
  ServiceCategory(
    id: 'grooming',
    label: 'Grooming',
    subLabel: '8 Groomers nearby',
    icon: Icons.shower,
    bgColor: Color(0xFFE3F2FD),
  ),
];

const List<Expert> mockExperts = [
  Expert(
    id: 'expert-1',
    name: 'Dr. Sarah Chen',
    designation: 'Senior Veterinarian',
    specialty: 'Feline Internal Medicine',
    rating: 4.9,
    reviewCount: 128,
    experienceYears: 12,
    distanceKm: 1.2,
    profileImageUrl:
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&h=200&fit=crop&crop=face',
    availableSlots: ['09:00 AM', '10:30 AM', '11:00 AM', '02:00 PM'],
  ),
  Expert(
    id: 'expert-2',
    name: 'Dr. Marcus Rivera',
    designation: 'Veterinary Surgeon',
    specialty: 'Cat Orthopedics',
    rating: 4.7,
    reviewCount: 94,
    experienceYears: 8,
    distanceKm: 2.5,
    profileImageUrl:
        'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200&h=200&fit=crop&crop=face',
    availableSlots: ['09:00 AM', '10:00 AM', '11:30 AM', '03:00 PM'],
  ),
  Expert(
    id: 'expert-3',
    name: 'Lisa Nakamura',
    designation: 'Professional Cat Groomer',
    specialty: 'Persian & Longhair Breeds',
    rating: 4.8,
    reviewCount: 203,
    experienceYears: 6,
    distanceKm: 0.8,
    profileImageUrl:
        'https://images.unsplash.com/photo-1594744803329-e58b31de8bf5?w=200&h=200&fit=crop&crop=face',
    availableSlots: ['08:30 AM', '10:00 AM', '01:00 PM', '04:00 PM'],
  ),
  Expert(
    id: 'expert-4',
    name: 'Dr. Emily Watson',
    designation: 'Dermatology Specialist',
    specialty: 'Cat Skin & Allergy Care',
    rating: 4.9,
    reviewCount: 76,
    experienceYears: 10,
    distanceKm: 3.1,
    profileImageUrl:
        'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200&h=200&fit=crop&crop=face',
    availableSlots: ['09:30 AM', '11:00 AM', '02:30 PM', '05:00 PM'],
  ),
  Expert(
    id: 'expert-5',
    name: 'James Okafor',
    designation: 'Certified Feline Behaviorist',
    specialty: 'Anxiety & Behavioral Therapy',
    rating: 4.6,
    reviewCount: 158,
    experienceYears: 7,
    distanceKm: 1.9,
    profileImageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
    availableSlots: ['08:00 AM', '10:00 AM', '01:30 PM', '03:30 PM'],
  ),
];
