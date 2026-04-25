import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/feed_model.dart';

// Global Theme Colors (corrected to match Figma design)
const Color brandPink = Color(0xFFA03A57);
const Color headingColor = Color(0xFF1A1A1A);
const Color bodyColor = Color(0xFF757575);
const Color backgroundColor = Colors.white;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _isLiked = false;

  final List<String> _stories = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
  ];

  final List<Post> _posts = [
    Post(
      id: '1',
      userId: '1',
      userName: 'Dr. Sarah Whiskers',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      content: 'Beautiful day at the park! My cat Luna loves the sunshine 🌞',
      images: ['https://picsum.photos/400/500?random=1'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 1284,
      comments: 45,
      shares: 12,
      isLiked: false,
    ),
    Post(
      id: '2',
      userId: '2',
      userName: 'Tommy Paws',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      content: 'Just adopted this cute kitten! Meet Milo 🐱 #kitten #adoptdontshop',
      images: ['https://picsum.photos/400/500?random=2'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 2341,
      comments: 89,
      shares: 23,
      isLiked: false,
    ),
    Post(
      id: '3',
      userId: '3',
      userName: 'Whiskers & Co',
      userAvatar: 'https://i.pravatar.cc/150?img=3',
      content: 'Cat grooming tips for summer! Keep your feline friend cool and comfortable 💕',
      images: ['https://picsum.photos/400/500?random=3'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 892,
      comments: 34,
      shares: 8,
      isLiked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Top App Bar
          SliverAppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: Text(
              'Purrfect',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brandPink,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: headingColor),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: headingColor),
                onPressed: () {},
              ),
            ],
            pinned: true,
          ),

          // Stories Section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _stories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Add Story Button
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          DottedBorder(
                            color: brandPink,
                            strokeWidth: 2,
                            dashPattern: const [6, 3],
                            radius: const Radius.circular(50),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: backgroundColor,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: brandPink,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ADD',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: bodyColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // User Story Item
                  final storyIndex = index - 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: brandPink,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: CachedNetworkImageProvider(
                              _stories[storyIndex],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'USER${storyIndex + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: bodyColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Posts Section
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostCard(
                  post: _posts[index],
                  onLike: () {
                    setState(() {
                      _posts[index].isLiked = !_posts[index].isLiked;
                      _posts[index].likes += _posts[index].isLiked ? 1 : -1;
                    });
                  },
                );
              },
              childCount: _posts.length,
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 40),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: brandPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

// Post Card Widget
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
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
              backgroundImage: CachedNetworkImageProvider(post.userAvatar),
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
            trailing: const Icon(Icons.more_horiz, color: headingColor),
          ),

          // Media Card
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
                  imageUrl: post.images.isNotEmpty ? post.images[0] : '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.grey[300],
                    ),
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
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? brandPink : headingColor,
                  ),
                  onPressed: onLike,
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: headingColor),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: headingColor),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: headingColor),
                  onPressed: () {},
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
                  '${post.likes} Likes',
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
