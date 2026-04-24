import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/feed_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Mock data for demonstration
  final List<Post> _posts = [
    Post(
      id: '1',
      userId: 'user1',
      userName: 'Siska',
      userAvatar: '',
      content: 'Kucingku baru saja melahirkan 4 anak! Lucu banget semua 🐱❤️',
      images: [],
      likes: 124,
      comments: 23,
      shares: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isLiked: false,
    ),
    Post(
      id: '2',
      userId: 'user2',
      userName: 'Pak Iwan',
      userAvatar: '',
      content: 'Persian kitten available! Umur 3 bulan, sudah vaksin. Harga nego.',
      images: [],
      likes: 89,
      comments: 15,
      shares: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: true,
    ),
    Post(
      id: '3',
      userId: 'user3',
      userName: 'Bimo',
      userAvatar: '',
      content: 'Tips grooming kucing di rumah: Gunakan sikat lembut dan lakukan secara rutin!',
      images: [],
      likes: 256,
      comments: 34,
      shares: 28,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isLiked: false,
    ),
  ];

  void _toggleLike(int index) {
    setState(() {
      final post = _posts[index];
      _posts[index] = Post(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userAvatar: post.userAvatar,
        content: post.content,
        images: post.images,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        comments: post.comments,
        shares: post.shares,
        createdAt: post.createdAt,
        isLiked: !post.isLiked,
      );
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PurrCat Feed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index], index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create post
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Post post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange,
                child: Text(
                  post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatTime(post.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            post.content,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.grey,
                    count: post.likes,
                    onTap: () => _toggleLike(index),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    color: Colors.grey,
                    count: post.comments,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.share,
                    color: Colors.grey,
                    count: post.shares,
                    onTap: () {},
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
