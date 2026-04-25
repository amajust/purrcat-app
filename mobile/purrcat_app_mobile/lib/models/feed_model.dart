import 'package:flutter/material.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.images,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? images,
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
      images: images ?? this.images,
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
