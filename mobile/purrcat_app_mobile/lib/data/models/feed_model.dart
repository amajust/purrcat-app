import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;

  /// Remote download URLs populated after upload.
  final List<String> imageUrls;

  /// Local file paths used for preview before upload.
  final List<String> localImagePaths;

  // ── Legacy / compat ─────────────────────────────────────────────────
  /// Kept for backwards compatibility with UI code that references
  /// [images]. Use [imageUrls] for remote URLs.
  final List<String> images;

  final List<String> taggedCatIds;
  final DateTime createdAt;
  int likes;
  final int comments;
  final int shares;
  bool isLiked;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.imageUrls = const [],
    this.localImagePaths = const [],
    this.images = const [],
    this.taggedCatIds = const [],
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
  });

  // ── Firestore serialisation ─────────────────────────────────────────

  /// Creates a [Post] from a Firestore document snapshot.
  ///
  /// [docId] is the Firestore document ID.
  /// [data] is the document's `data()` map.
  factory Post.fromFirestore(String docId, Map<String, dynamic> data) {
    return Post(
      id: docId,
      userId: (data['userId'] as String?) ?? '',
      userName: (data['userName'] as String?) ?? 'Unknown',
      userAvatar: (data['userAvatar'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      imageUrls: _listFromDynamic(data['imageUrls']) ?? const [],
      localImagePaths: _listFromDynamic(data['localImagePaths']) ?? const [],
      images: _listFromDynamic(data['images']) ?? const [],
      taggedCatIds: _listFromDynamic(data['taggedCatIds']) ?? const [],
      createdAt: _toDateTime(data['createdAt']),
      likes: (data['likeCount'] as num?)?.toInt() ?? 0,
      comments: (data['commentCount'] as num?)?.toInt() ?? 0,
      shares: (data['shareCount'] as num?)?.toInt() ?? 0,
      isLiked: (data['isLiked'] as bool?) ?? false,
    );
  }

  /// Converts this [Post] into a map suitable for `set()` / `update()` in
  /// Cloud Firestore. Does **not** include fields that are managed
  /// separately (e.g. `isLiked` is a local-only flag, `likes` is the
  /// likeCount Firestore field).
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'imageUrls': imageUrls,
      'images': images,
      'taggedCatIds': taggedCatIds,
      'createdAt': createdAt,
      'likeCount': likes,
      'commentCount': comments,
      'shareCount': shares,
    };
  }

  // ── Helper ──────────────────────────────────────────────────────────

  static List<String>? _listFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.cast<String>();
    return null;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  // ── copyWith ────────────────────────────────────────────────────────

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? imageUrls,
    List<String>? localImagePaths,
    List<String>? images,
    List<String>? taggedCatIds,
    DateTime? createdAt,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      images: images ?? this.images,
      taggedCatIds: taggedCatIds ?? this.taggedCatIds,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PetStory {
  final String name;
  final Color color;

  PetStory({
    required this.name,
    required this.color,
  });
}

class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final String category;
  final String sellerId;
  final String sellerName;
  final int stock;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.stock,
    required this.rating,
    required this.reviewCount,
  });
}
