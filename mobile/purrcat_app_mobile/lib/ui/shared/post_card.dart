import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/feed_model.dart';
import '../../data/services/firestore_service.dart';
import '../core/theme.dart';
import 'report_modal.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLoginRequired;

  const PostCard({
    super.key,
    required this.post,
    this.onLoginRequired,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  StreamSubscription<bool>? _likeSub;
  StreamSubscription<bool>? _bookmarkSub;
  StreamSubscription<DocumentSnapshot>? _postDocSub;

  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _subscribeToFirestore();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _likeCount = widget.post.likes;
      _unsubscribe();
      _subscribeToFirestore();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _unsubscribe() {
    _likeSub?.cancel();
    _bookmarkSub?.cancel();
    _postDocSub?.cancel();
  }

  void _subscribeToFirestore() {
    final postId = widget.post.id;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Stream whether the current user has liked this post.
    _likeSub = FirestoreService()
        .isLikedStream(postId: postId, userId: userId)
        .listen((liked) {
      if (mounted) setState(() => _isLiked = liked);
    });

    // Stream whether the current user has bookmarked this post.
    _bookmarkSub = FirestoreService()
        .isBookmarkedStream(postId: postId, userId: userId)
        .listen((bookmarked) {
      if (mounted) setState(() => _isBookmarked = bookmarked);
    });

    // Stream the post document for real-time like count.
    _postDocSub = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .snapshots()
        .listen((doc) {
      if (mounted && doc.exists) {
        final count = (doc.data()?['likeCount'] as num?)?.toInt() ?? 0;
        setState(() => _likeCount = count);
      }
    });
  }

  void _handleLike() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      widget.onLoginRequired?.call();
      return;
    }
    FirestoreService().toggleLike(postId: widget.post.id, userId: userId);
  }

  void _handleBookmark() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      widget.onLoginRequired?.call();
      return;
    }
    FirestoreService()
        .toggleBookmark(postId: widget.post.id, userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final imageUrl = post.imageUrls.isNotEmpty
        ? post.imageUrls[0]
        : (post.images.isNotEmpty ? post.images[0] : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: post.userAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(post.userAvatar)
                  : null,
              child: post.userAvatar.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            title: Text(
              post.userName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            subtitle: Text(
              'Location',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: bodyColor,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: headingColor),
              onSelected: (value) {
                if (value == 'report') {
                  showReportModal(
                    context,
                    itemId: post.id,
                    itemType: 'feed',
                    itemPreview: post.content,
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 18, color: bodyColor),
                      SizedBox(width: 8),
                      Text('Report'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Media Card
          if (imageUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.grey[300]),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),

          // Interaction Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Like button
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : headingColor,
                  ),
                  onPressed: _handleLike,
                ),
                // Comment button (placeholder)
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: headingColor,
                  ),
                  onPressed: () {},
                ),
                const Spacer(),
                // Bookmark button
                IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked ? brandPink : headingColor,
                  ),
                  onPressed: _handleBookmark,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_likeCount Likes',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: headingColor,
                    ),
                    children: [
                      TextSpan(
                        text: '${post.userName} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: post.content),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
