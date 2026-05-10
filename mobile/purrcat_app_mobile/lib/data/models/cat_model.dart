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
    };
  }
}
