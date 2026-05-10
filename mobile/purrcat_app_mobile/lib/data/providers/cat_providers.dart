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

/// Real-time stream of a specific cat's details using collectionGroup.
final catDetailProvider = StreamProvider.family<CatModel?, String>((ref, catId) {
  return FirebaseFirestore.instance
      .collectionGroup('cats')
      .where('id', isEqualTo: catId)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        final doc = snapshot.docs.first;
        return CatModel.fromFirestore(doc.id, doc.data());
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
