import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cat_model.dart';
import '../models/feed_model.dart';

/// Real-time stream of the current user's registered cats.
final userCatsProvider = StreamProvider<List<CatModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('cats')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CatModel.fromFirestore(doc.id, doc.data()))
          .toList());
});

/// Real-time stream of a specific cat's details using direct root-collection snapshots and fallback migration.
final catDetailProvider = StreamProvider.family<CatModel?, String>((ref, arg) {
  final parts = arg.split('|');
  final catId = parts.last;
  final ownerId = parts.length > 1 ? parts.first : null;

  if (ownerId != null && ownerId.isNotEmpty) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(ownerId)
        .collection('cats')
        .doc(catId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.exists && snapshot.data() != null) {
            return CatModel.fromFirestore(snapshot.id, snapshot.data()!);
          }
          
          // Fallback to root cats collection
          final flatDoc = await FirebaseFirestore.instance.collection('cats').doc(catId).get();
          if (flatDoc.exists && flatDoc.data() != null) {
            return CatModel.fromFirestore(flatDoc.id, flatDoc.data()!);
          }

          // Fallback to collectionGroup
          try {
            final groupSnapshot = await FirebaseFirestore.instance
                .collectionGroup('cats')
                .where('id', isEqualTo: catId)
                .get();
            if (groupSnapshot.docs.isNotEmpty) {
              final doc = groupSnapshot.docs.first;
              return CatModel.fromFirestore(doc.id, doc.data());
            }
          } catch (e) {
            print('Fallback collectionGroup query failed: $e');
          }
          return null;
        });
  }

  return FirebaseFirestore.instance
      .collection('cats')
      .doc(catId)
      .snapshots()
      .asyncMap((snapshot) async {
        if (snapshot.exists && snapshot.data() != null) {
          return CatModel.fromFirestore(snapshot.id, snapshot.data()!);
        }

        // Fallback: If not found in root 'cats' collection, try collectionGroup query.
        try {
          final groupSnapshot = await FirebaseFirestore.instance
              .collectionGroup('cats')
              .where('id', isEqualTo: catId)
              .get();

          if (groupSnapshot.docs.isNotEmpty) {
            final doc = groupSnapshot.docs.first;
            final data = doc.data();

            // Auto-migrate to root collection so future fetches are instant and index-free
            await FirebaseFirestore.instance.collection('cats').doc(catId).set(data);

            return CatModel.fromFirestore(doc.id, data);
          }
        } catch (e) {
          print('Root fetch returned null, and fallback collectionGroup query failed (index might be missing): $e');
        }
        return null;
      });
});

/// Real-time stream of posts where a specific cat is tagged.
final catRelatedPostsProvider = StreamProvider.family<List<Post>, String>((ref, catId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('taggedCatIds', arrayContains: catId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Post.fromFirestore(doc.id, doc.data()))
          .toList());
});

/// Dynamic list of all photo URLs associated with a specific cat (profile photo + tagged post photos).
final catGalleryImagesProvider = Provider.family<List<String>, String>((ref, catId) {
  final catAsync = ref.watch(catDetailProvider(catId));
  final postsAsync = ref.watch(catRelatedPostsProvider(catId));
  
  final List<String> images = [];
  
  catAsync.whenData((cat) {
    if (cat != null && cat.imageUrl.isNotEmpty) {
      images.add(cat.imageUrl);
    }
  });
  
  postsAsync.whenData((posts) {
    for (final post in posts) {
      images.addAll(post.imageUrls);
    }
  });
  
  return images.toSet().toList(); // Keep unique images
});
