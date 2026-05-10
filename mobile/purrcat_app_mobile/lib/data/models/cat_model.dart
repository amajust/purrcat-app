import 'package:cloud_firestore/cloud_firestore.dart';

class CatModel {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String description;
  final String imageUrl;
  final bool isPedigreeVerified;
  final String pedigreeCertUrl;
  final String ownerId;
  final DateTime createdAt;
  
  // Extended lineage & detailed attributes
  final String gender;
  final String category;
  final String sireId;
  final String sireName;
  final String damId;
  final String damName;

  CatModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.description,
    required this.imageUrl,
    required this.isPedigreeVerified,
    required this.pedigreeCertUrl,
    required this.ownerId,
    required this.createdAt,
    this.gender = 'Unknown',
    this.category = 'Pedigree',
    this.sireId = '',
    this.sireName = 'Unknown Sire',
    this.damId = '',
    this.damName = 'Unknown Dam',
  });

  factory CatModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CatModel(
      id: id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isPedigreeVerified: data['isPedigreeVerified'] ?? false,
      pedigreeCertUrl: data['pedigreeCertUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: data['gender'] ?? 'Unknown',
      category: data['category'] ?? 'Pedigree',
      sireId: data['sireId'] ?? '',
      sireName: data['sireName'] ?? 'Unknown Sire',
      damId: data['damId'] ?? '',
      damName: data['damName'] ?? 'Unknown Dam',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'description': description,
      'imageUrl': imageUrl,
      'isPedigreeVerified': isPedigreeVerified,
      'pedigreeCertUrl': pedigreeCertUrl,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'gender': gender,
      'category': category,
      'sireId': sireId,
      'sireName': sireName,
      'damId': damId,
      'damName': damName,
    };
  }
}
