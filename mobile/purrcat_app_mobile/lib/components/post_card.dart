import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/feed_model.dart';
import '../providers/auth_provider.dart';
import 'login_popup.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final int index;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const PostCard({
    super.key,
    required this.post,
    required this.index,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _requireAuth(BuildContext context, VoidCallback action) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      action();
    } else {
      final loggedIn = await LoginPopup.show(context);
      if (loggedIn) {
        action();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: const Color(0xFFA03A57),
                child: Text(
                  post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
                    onTap: () => _requireAuth(context, onLike),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    color: Colors.grey,
                    count: post.comments,
                    onTap: () => _requireAuth(context, onComment),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.share,
                    color: Colors.grey,
                    count: post.shares,
                    onTap: onShare,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.grey),
                onPressed: onSave,
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
