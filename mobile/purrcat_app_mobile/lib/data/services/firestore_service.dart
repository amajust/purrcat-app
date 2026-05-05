import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/feed_model.dart';
import '../models/marketplace_model.dart';

/// Singleton service for all Firestore + Firebase Storage operations.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Convenience references ──────────────────────────────────────────

  /// Reference to the top-level posts collection.
  CollectionReference<Map<String, dynamic>> get posts =>
      _firestore.collection('posts');

  // ── Create post with image uploads ──────────────────────────────────

  /// Uploads [images] to Firebase Storage at `posts/{postId}/image_{i}.jpg`,
  /// collects download URLs, and writes the post document to Firestore.
  Future<void> createPost({
    required Post post,
    required List<File> images,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Must be authenticated to create a post');

    // Generate a new document reference so we have the ID upfront.
    final docRef = posts.doc();
    final postId = docRef.id;

    // Upload each image and collect download URLs.
    final List<String> imageUrls = [];
    for (int i = 0; i < images.length; i++) {
      try {
        final ref = _storage.ref('posts/$postId/image_$i.jpg');
        await ref.putFile(images[i]);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      } on FirebaseException catch (e) {
        throw Exception('Storage upload failed [${e.code}]: ${e.message}');
      }
    }

    // Write post document with the download URLs.
    try {
      await docRef.set({
        ...post.toFirestore(),
        'id': postId,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Firestore write failed [${e.code}]: ${e.message}');
    }
  }

  // ── Real-time posts feed ────────────────────────────────────────────

  /// Returns a stream of [Post] objects ordered by `createdAt` descending.
  Stream<List<Post>> getPosts() {
    return posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final currentUserId = _auth.currentUser?.uid;
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Also check the likes subcollection for the current user.
        // We'll handle isLiked separately via the stream method, but
        // we can do an initial read here. For simplicity we default to
        // false here; consumers should use isLikedStream for real-time.
        return Post.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  // ── Likes ───────────────────────────────────────────────────────────

  /// Toggles the like for [userId] on [postId].
  ///
  /// Uses the subcollection `posts/{postId}/likes/{userId}` and atomically
  /// updates the likeCount on the post document.
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final likeRef =
        _firestore.collection('posts').doc(postId).collection('likes').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);

      if (likeDoc.exists) {
        // Already liked → remove like.
        transaction.delete(likeRef);
        transaction.update(
          posts.doc(postId),
          {'likeCount': FieldValue.increment(-1)},
        );
      } else {
        // Not liked → add like.
        transaction.set(likeRef, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(
          posts.doc(postId),
          {'likeCount': FieldValue.increment(1)},
        );
      }
    });
  }

  /// Real-time stream indicating whether [userId] has liked [postId].
  Stream<bool> isLikedStream({
    required String postId,
    required String userId,
  }) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Returns the current like count for [postId] from the post document.
  Future<int> getLikeCount(String postId) async {
    final doc = await posts.doc(postId).get();
    if (!doc.exists) return 0;
    return (doc.data()?['likeCount'] as int?) ?? 0;
  }

  // ── Bookmarks ───────────────────────────────────────────────────────

  /// Toggles the bookmark for [userId] on [postId].
  ///
  /// Stores bookmarks in the user's subcollection:
  /// `users/{userId}/bookmarks/{postId}`.
  Future<void> toggleBookmark({
    required String postId,
    required String userId,
  }) async {
    final bookmarkRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(postId);

    final doc = await bookmarkRef.get();

    if (doc.exists) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({
        'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Real-time stream indicating whether [userId] has bookmarked [postId].
  Stream<bool> isBookmarkedStream({
    required String postId,
    required String userId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ── Marketplace ─────────────────────────────────────────────────────

  /// Reference to the marketplace collection.
  CollectionReference<Map<String, dynamic>> get marketplace =>
      _firestore.collection('marketplace');

  /// Uploads a product image to Storage and creates a marketplace listing
  /// document in Firestore.
  Future<void> addMarketplaceListing({
    required MarketplaceItem item,
    required File? image,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Must be authenticated to list a product');

    final docRef = marketplace.doc();
    final listingId = docRef.id;

    String imageUrl = '';
    if (image != null) {
      try {
        final ref = _storage.ref('marketplace/$listingId/image.jpg');
        await ref.putFile(image);
        imageUrl = await ref.getDownloadURL();
      } on FirebaseException catch (e) {
        throw Exception('Image upload failed [${e.code}]: ${e.message}');
      }
    }

    try {
      await docRef.set({
        'id': listingId,
        'name': item.name,
        'breed': item.breed,
        'price': item.price,
        'category': item.category,
        'sellerName': item.sellerName,
        'sellerId': user.uid,
        'type': item.type == ListingType.pet ? 'pet' : 'product',
        'imageUrl': imageUrl,
        'rating': 0.0,
        'reviewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        ..._statusBadgeToMap(item.statusBadge),
        ..._ageToMap(item.age),
      });
    } on FirebaseException catch (e) {
      throw Exception('Firestore write failed [${e.code}]: ${e.message}');
    }
  }

  Map<String, dynamic> _statusBadgeToMap(StatusBadge? badge) {
    if (badge == null) return {};
    return {'statusBadge': badge.name};
  }

  Map<String, dynamic> _ageToMap(String? age) {
    if (age == null) return {};
    return {'age': age};
  }

  /// Real-time stream of all marketplace listings ordered by newest first.
  Stream<List<MarketplaceItem>> getMarketplaceListings() {
    return marketplace
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketplaceItem.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Toggles a marketplace item in the user's favorites.
  Future<void> toggleMarketplaceFavorite({
    required String itemId,
    required String userId,
  }) async {
    final favRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(itemId);

    final doc = await favRef.get();
    if (doc.exists) {
      await favRef.delete();
    } else {
      await favRef.set({
        'itemId': itemId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Real-time stream of the current user's favorite item IDs.
  Stream<Set<String>> getFavoriteIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  // ── Configuration ───────────────────────────────────────────────────

  /// Reads the maximum number of images allowed per post from the remote
  /// config document `config/posting`. Defaults to 5 if the document or
  /// field is absent.
  Future<int> getMaxImagesPerPost() async {
    try {
      final doc = await _firestore.collection('config').doc('posting').get();
      if (doc.exists && doc.data()?['maxImages'] != null) {
        return (doc.data()!['maxImages'] as num).toInt();
      }
    } catch (_) {
      // Fall through to default on any error.
    }
    return 5;
  }
}
