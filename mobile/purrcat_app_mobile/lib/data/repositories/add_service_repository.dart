import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/provider_service_model.dart';

class AddServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<bool> checkVerificationStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['isVerified'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking verification status: $e');
      return false;
    }
  }

  Future<String?> getUserEntity(String userId) async {
     try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['entityType'];
      }
      return null;
    } catch (e) {
      print('Error getting user entity: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  Future<void> submitVerificationFiles({
    required String userId,
    required String entityType,
    File? ktpFile,
    File? nibFile,
  }) async {
    try {
      String? ktpUrl;
      String? nibUrl;

      if (ktpFile != null) {
        final ktpRef = _storage.ref().child('verifications/$userId/ktp_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ktpRef.putFile(ktpFile);
        ktpUrl = await ktpRef.getDownloadURL();
      }

      if (nibFile != null) {
         final nibRef = _storage.ref().child('verifications/$userId/nib_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await nibRef.putFile(nibFile);
        nibUrl = await nibRef.getDownloadURL();
      }

      await _firestore.collection('private_verifications').doc(userId).set({
        'ktpUrl': ktpUrl,
        'nibUrl': nibUrl,
        'entityType': entityType,
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      
      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': 'pending'
      });

    } catch (e) {
       print('Error submitting verification files: $e');
       rethrow;
    }
  }

  Future<void> submitServiceListing(ProviderServiceModel model) async {
    try {
      await _firestore.collection('services').add(model.toFirestore());
    } catch (e) {
      print('Error submitting service listing: $e');
      rethrow;
    }
  }
}
